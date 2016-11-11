from compiler.js import get_package, split_name, escape
from compiler.code import process, parse_deps, generate_accessors, replace_enums
from compiler import lang

class component_generator(object):
	def __init__(self, name, component, prototype = False):
		self.name = name
		self.component = component
		self.aliases = {}
		self.properties = {}
		self.enums = {}
		self.assignments = {}
		self.animations = {}
		self.package = get_package(name)
		self.base_type = None
		self.children = []
		self.methods = {}
		self.signal_handlers = {}
		self.changed_handlers = {}
		self.key_handlers = {}
		self.signals = set()
		self.id = None
		self.prototype = prototype
		self.ctor = ''

		for child in component.children:
			self.add_child(child)

	def collect_id(self, id_set):
		if self.id is not None:
			id_set.add(self.id)
		for g in self.assignments.itervalues():
			if type(g) is component_generator and g.id:
				g.collect_id(id_set)
		for g in self.animations.itervalues():
			if type(g) is component_generator and g.id:
				g.collect_id(id_set)
		for g in self.children:
			g.collect_id(id_set)

	def assign(self, target, value):
		t = type(value)
		if t is lang.Component:
			value = component_generator(self.package + ".<anonymous>", value)
		if t is str: #and value[0] == '"' and value[-1] == '"':
			value = value.replace("\\\n", "")
		self.assignments[target] = value

	def has_property(self, name):
		return (name in self.properties) or (name in self.aliases) or (name in self.enums)

	def add_child(self, child):
		t = type(child)
		if t is lang.Property:
			if self.has_property(child.name):
				raise Exception("duplicate property " + child.name)
			self.properties[child.name] = child
			if child.value is not None:
				if not child.is_trivial():
					self.assign(child.name, child.value)
		elif t is lang.AliasProperty:
			if self.has_property(child.name):
				raise Exception("duplicate property " + child.name)
			self.aliases[child.name] = child.target
		elif t is lang.EnumProperty:
			if self.has_property(child.name):
				raise Exception("duplicate property " + child.name)
			self.enums[child.name] = child
		elif t is lang.Assignment:
			if self.component.name != 'ListElement' and child.target == 'id':
				raise Exception('assigning non-id for id')
			self.assign(child.target, child.value)
		elif t is lang.IdAssignment:
			self.id = child.name
			self.assign("id", child.name)
		elif t is lang.Component:
			self.children.append(component_generator(self.package + ".<anonymous>", child))
		elif t is lang.Behavior:
			for target in child.target:
				if target in self.animations:
					raise Exception("duplicate animation on property " + target);
				self.animations[target] = component_generator(self.package + ".<anonymous-animation>", child.animation)
		elif t is lang.Method:
			name, args, code = child.name, child.args, child.code
			if child.event and len(name) > 2 and name != "onChanged" and name.startswith("on") and name[2].isupper(): #onXyzzy
				name = name[2].lower() + name[3:]
				if name.endswith("Pressed"):
					name = name[0].upper() + name[1:-7]
					if name in self.key_handlers:
						raise Exception("duplicate key handler " + child.name)
					self.key_handlers[name] = code
				elif name.endswith("Changed"):
					name = name[:-7]
					if name in self.changed_handlers:
						raise Exception("duplicate signal handler " + child.name)
					self.changed_handlers[name] = code
				else:
					if name in self.signal_handlers:
						raise Exception("duplicate signal handler " + child.name)
					self.signal_handlers[name] = args, code
			else:
				if name in self.methods:
					raise Exception("duplicate method " + name)
				self.methods[name] = args, code
		elif t is lang.Constructor:
			self.ctor = "\t//custom constructor:\n\t" + child.code + "\n"
		elif t is lang.Signal:
			name = child.name
			if name in self.signals:
				raise Exception("duplicate signal " + name)
			self.signals.add(name)
		else:
			raise Exception("unhandled element: %s" %child)

	def generate_ctor(self, registry):
		return "\texports.%s.apply(this, arguments);\n" %(registry.find_component(self.package, self.component.name)) + self.ctor

	def generate(self, registry):
		ctor  = "/**\n * @constructor\n"
		base_type = registry.find_component(self.package, self.component.name)
		ctor += " * @extends {exports.%s}\n" %base_type
		ctor += " */\n"
		ctor += "\texports.%s = function(parent) {\n%s\n%s\n%s\n}\n" %(self.name, self.generate_ctor(registry), "\n".join(self.generate_creators(registry, "this")), self.generate_setup_code(registry, "this"))
		return ctor

	def generate_animations(self, registry, parent):
		r = []
		for name, animation in self.animations.iteritems():
			var = "behavior_on_" + escape(name)
			r.append("\tvar %s = new _globals.%s(%s);" %(var, registry.find_component(self.package, animation.component.name), parent))
			r.append(self.wrap_creator("create", var, "\n".join(animation.generate_creators(registry, var, 2))))
			r.append(self.wrap_creator("setup", var, animation.generate_setup_code(registry, var, 2)))
			parent, target = split_name(name)
			if not parent:
				parent = 'this'
			else:
				parent = self.get_lvalue(parent)
			r.append("\t%s.setAnimation('%s', %s);\n" %(parent, target, var))
		return "\n".join(r)

	def wrap_creator(self, prefix, var, code):
		if not code.strip():
			return ""
		safe_var = escape(var)
		return "\tfunction %s_%s () {\n%s\n\t}\n\t%s_%s.call(%s)" %(prefix, safe_var, code, prefix, safe_var, var)

	def generate_prototype(self, registry, ident_n = 1):
		assert self.prototype == True

		#HACK HACK: make immutable
		registry.id_set = set(['context'])
		self.collect_id(registry.id_set)

		r = []
		ident = "\t" * ident_n

		r.append("%sexports.%s.prototype.componentName = '%s'" %(ident, self.name, self.name))

		for name in self.signals:
			r.append("%sexports.%s.prototype.%s = function() { var args = exports.core.copyArguments(arguments, 0, '%s'); this.emit.apply(this, args) }" %(ident, self.name, name, name))

		for name, argscode in self.methods.iteritems():
			args, code = argscode
			code = process(code, self, registry)
			r.append("%sexports.%s.prototype.%s = function(%s) %s" %(ident, self.name, name, ",".join(args), code))

		for name, prop in self.properties.iteritems():
			args = ["exports.%s.prototype" %self.name, "'%s'" %prop.type, "'%s'" %name]
			if prop.is_trivial():
				args.append(prop.value)
			r.append("%score.addProperty(%s)" %(ident, ", ".join(args)))

		for name, prop in self.enums.iteritems():
			values = prop.values

			for i in xrange(0, len(values)):
				r.append("/** @const @type {number} */")
				r.append("%sexports.%s.prototype.%s = %d" %(ident, self.name, values[i], i))
				r.append("/** @const @type {number} */")
				r.append("%sexports.%s.%s = %d" %(ident, self.name, values[i], i))

			args = ["exports.%s.prototype" %self.name, "'enum'", "'%s'" %name]
			if prop.default is not None:
				args.append("exports.%s.%s" %(self.name, prop.default))
			r.append("%score.addProperty(%s)" %(ident, ", ".join(args)))

		return "\n".join(r)

	def find_property(self, registry, property):
		if self.component.name == 'ListElement':
			return True
		if property in self.properties:
			return self.properties[property]
		if property in self.enums:
			return self.enums[property]
		if property in self.aliases:
			return self.aliases[property]

		base = registry.find_component(self.package, self.component.name)
		if base != 'core.CoreObject':
			return registry.components[base].find_property(registry, property)

	def check_target_property(self, registry, target):
		path = target.split('.')

		if len(path) > 1:
			if (path[0] in registry.id_set):
				return

			if not self.find_property(registry, path[0]):
				raise Exception('unknown property %s in %s (%s)' %(target, self.name, self.component.name))
		else: #len(path) == 1
			if not self.find_property(registry, target):
				raise Exception('unknown property %s in %s (%s)' %(target, self.name, self.component.name))


	def generate_creators(self, registry, parent, ident_n = 1):
		prologue = []
		r = []
		ident = "\t" * ident_n

		if not self.prototype:
			for name in self.signals:
				r.append("%score.addSignal(this, '%s')" %(ident, name))

		if not self.prototype:
			for name, prop in self.properties.iteritems():
				args = [parent, "'%s'" %prop.type, "'%s'" %name]
				if prop.is_trivial():
					args.append(prop.value)
				r.append("\tcore.addProperty(%s)" %(", ".join(args)))

		idx = 0
		for gen in self.children:
			var = "%s_child%d" %(parent, idx)
			component = registry.find_component(self.package, gen.component.name)
			prologue.append("\tvar %s;" %var)
			r.append("\t%s = new _globals.%s(%s);" %(var, component, parent))
			p, code = gen.generate_creators(registry, var, ident_n + 1)
			prologue.append(p)
			r.append(self.wrap_creator("create", var, code))
			idx += 1

		for target, value in self.assignments.iteritems():
			if target == "id" and self.component.name != 'ListElement':
				if "." in value:
					raise Exception("expected identifier, not expression")
				r.append("%sthis._setId('%s')" %(ident, value))
			elif target.endswith(".id"):
				raise Exception("setting id of the remote object is prohibited")
			# else:
			# 	self.check_target_property(registry, target)

			if isinstance(value, component_generator):
				var = "%s_%s" %(parent, escape(target))
				prologue.append("%svar %s;" %(ident, var))
				if target != "delegate":
					r.append("%s%s = new _globals.%s(%s);" %(ident, var, registry.find_component(value.package, value.component.name), parent))
					p, code = value.generate_creators(registry, var, ident_n + 1)
					prologue.append(p)
					r.append(self.wrap_creator("create", var, code))
					r.append("%sthis.%s = %s" %(ident, target, var))
				else:
					code = "var %s%s = new _globals.%s(%s);" %(ident, var, registry.find_component(value.package, value.component.name), parent)
					p, c = value.generate_creators(registry, var, ident_n + 1)
					code += self.wrap_creator("create", var, c)
					code += "\n"
					code += self.wrap_creator("setup", var, value.generate_setup_code(registry, var, ident_n + 1))
					r.append("%sthis.%s = (function() { %s\n%s\n%s\nreturn %s }).bind(this)" %(ident, target, p, code, ident, var))

		return "\n".join(prologue), "\n".join(r)

	def get_lvalue(self, target):
		path = target.split(".")
		path = ["_get('%s')" %x for x in path]
		return "this.%s" % ".".join(path)

	def get_target_lvalue(self, target):
		path = target.split(".")
		path = ["_get('%s')" %x for x in path[:-1]] + [path[-1]]
		return "this.%s" % ".".join(path)


	def generate_setup_code(self, registry, parent, ident_n = 1):
		r = []
		ident = "\t" * ident_n
		for name, target in self.aliases.iteritems():
			get, pname = generate_accessors(target)
			r.append("""\
	core.addAliasProperty(this, '%s', (function() { return %s; }).bind(this), '%s')
""" %(name, get, pname))
		for target, value in self.assignments.iteritems():
			if target == "id":
				continue
			t = type(value)
			#print self.name, target, value
			target_lvalue = self.get_target_lvalue(target)
			if t is str:
				value = replace_enums(value, self, registry)
				deps = parse_deps(value)
				if deps:
					suffix = "_var_%s__%s" %(escape(parent), escape(target))
					var = "_update" + suffix
					r.append("%svar %s = (function() { %s = (%s); }).bind(this);" %(ident, var, target_lvalue, value))
					r.append("%s%s();" %(ident, var))
					undep = []
					for path, dep in deps:
						r.append("%sthis.connectOnChanged(%s, '%s', %s);" %(ident, path, dep, var))
						undep.append("%s.removeOnChanged('%s', _update%s)" %(path, dep, suffix))
					r.append("%sthis._removeUpdater('%s', (function() { %s }).bind(this));" %(ident, target, ";".join(undep)))
				else:
					r.append("%sthis._removeUpdater('%s'); %s = (%s);" %(ident, target, target_lvalue, value))

			elif t is component_generator:
				if target == "delegate":
					continue
				var = "%s_%s" %(parent, escape(target))
				r.append(self.wrap_creator("setup", var, value.generate_setup_code(registry, var, ident_n + 1)))
			else:
				raise Exception("skip assignment %s = %s" %(target, value))

		idx = 0
		for gen in self.children:
			var = "%s_child%d" %(parent, idx)
			component = registry.find_component(self.package, gen.component.name)
			r.append(self.wrap_creator("setup", var, gen.generate_setup_code(registry, var, 2)))
			r.append("\t%s.addChild(%s);" %(parent, var));
			r.append("")
			idx += 1
		if not self.prototype:
			for name, argscode in self.methods.iteritems():
				args, code = argscode
				code = process(code, self, registry)
				r.append("%sthis.%s = (function(%s) %s ).bind(this);" %(ident, name, ",".join(args), code))

		for name, argscode in self.signal_handlers.iteritems():
			args, code = argscode
			code = process(code, self, registry)
			if name != "completed":
				r.append("%sthis.on('%s', (function(%s) %s ).bind(this));" %(ident, name, ",".join(args), code))
			else:
				r.append("%sthis._context._onCompleted((function() %s ).bind(this));" %(ident, code))
		for name, code in self.changed_handlers.iteritems():
			code = process(code, self, registry)
			r.append("%sthis.onChanged('%s', (function(value) %s ).bind(this));" %(ident, name, code))
		for name, code in self.key_handlers.iteritems():
			code = process(code, self, registry)
			r.append("%sthis.onPressed('%s', (function(key, event) %s ).bind(this));" %(ident, name, code))
		r.append(self.generate_animations(registry, parent))
		return "\n".join(r)
