from compiler.js import get_package, split_name, escape
from compiler.js.code import process, parse_deps, generate_accessors, replace_enums
from compiler import lang
import json

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
		self.elements = []
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
			if child.target == 'id':
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
		elif t is lang.ListElement:
			self.elements.append(child.data)
		elif t is lang.AssignmentScope:
			for assign in child.values:
				self.assign(child.target + '.' + assign.target, assign.value)
		else:
			raise Exception("unhandled element: %s" %child)

	def call_create(self, registry, ident_n, target, value):
		assert isinstance(value, component_generator)
		ident = '\t' * ident_n
		code = '\n//creating component %s\n' %value.component.name
		code += '%s%s.__create()\n' %(ident, target)
		if not value.prototype:
			p, c = value.generate_creators(registry, target, ident_n)
			code += c
		else:
			p = ''
		return p, code

	def call_setup(self, registry, ident_n, target, value):
		assert isinstance(value, component_generator)
		ident = '\t' * ident_n
		code = '\n//setting up component %s\n' %value.component.name
		code += '%s%s.__setup()' %(ident, target)
		if not value.prototype:
			code += '\n' + value.generate_setup_code(registry, target, ident_n)
		return code

	def generate_ctor(self, registry):
		return "\texports.%s.apply(this, arguments);\n" %(registry.find_component(self.package, self.component.name)) + self.ctor

	def get_base_type(self, registry):
		return registry.find_component(self.package, self.component.name)

	def generate(self, registry):
		base_type = self.get_base_type(registry)
		ctor  = "/**\n * @constructor\n"
		ctor += " * @extends {exports.%s}\n" %base_type
		ctor += " */\n"
		ctor += "\texports.%s = function(parent, _delegate) {\n%s\n}\n" %(self.name, self.generate_ctor(registry))
		return ctor

	def generate_animations(self, registry, parent):
		r = []
		for name, animation in self.animations.iteritems():
			var = "behavior_on_" + escape(name)
			r.append("%svar %s = new _globals.%s(%s)" %(ident, var, registry.find_component(self.package, animation.component.name), parent))
			r.append("\n".join(self.call_create(registry, 1, var, animation)))
			r.append(self.call_setup(registry, 1, var, animation))
			target_parent, target = split_name(name)
			if not target_parent:
				target_parent = parent
			else:
				target_parent = self.get_rvalue(parent, target_parent)
			r.append("\t%s.setAnimation('%s', %s);\n" %(target_parent, target, var))
		return "\n".join(r)

	def generate_prototype(self, registry, ident_n = 1):
		assert self.prototype == True

		#HACK HACK: make immutable
		registry.id_set = set(['context'])
		self.collect_id(registry.id_set)

		r = []
		ident = "\t" * ident_n

		r.append("%sexports.%s.prototype.componentName = '%s'" %(ident, self.name, self.name))

		for name in self.signals:
			r.append("%sexports.%s.prototype.%s = _globals.core.createSignal('%s')" %(ident, self.name, name, name))

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

		base_type = self.get_base_type(registry)

		prologue, code = self.generate_creators(registry, 'this', ident_n + 1)
		prologue, code = prologue.strip(), code.strip()
		if prologue or code:
			b = '%s_globals.%s.prototype.__create.apply(this)' %(ident, base_type)
			code = '%sexports.%s.prototype.__create = function() {\n%s\n%s\n}' \
				%(ident, self.name, b, code)

		setup_code = self.generate_setup_code(registry, 'this', ident_n + 2).strip()
		if setup_code:
			b = '%s_globals.%s.prototype.__setup.apply(this)' %(ident, base_type)
			setup_code = '%sexports.%s.prototype.__setup = function() {\n%s\n%s\n}' \
				%(ident, self.name, b, setup_code)

		if prologue or code or setup_code:
			r.append(";%s(function() {" %ident)
			if prologue:
				r.append(prologue)
			if code:
				r.append(code)
			if setup_code:
				r.append(setup_code)
			r.append("%s})();\n" %ident)

		r.append('')

		return "\n".join(r)

	def find_property(self, registry, property):
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
				raise Exception('unknown property %s in %s (%s)' %(path[0], self.name, self.component.name))
		else: #len(path) == 1
			if not self.find_property(registry, target):
				raise Exception('unknown property %s in %s (%s)' %(target, self.name, self.component.name))

	def generate_creators(self, registry, parent, ident_n = 1):
		prologue = []
		r = []
		ident = "\t" * ident_n

		if not self.prototype:
			for name in self.signals:
				r.append("%s%s.%s = _globals.core.createSignal('%s').bind(%s)" %(ident, parent, name, name, parent))

			for name, prop in self.properties.iteritems():
				args = [parent, "'%s'" %prop.type, "'%s'" %name]
				if prop.is_trivial():
					args.append(prop.value)
				r.append("\tcore.addProperty(%s)" %(", ".join(args)))

			for name, prop in self.enums.iteritems():
				raise Exception('adding enums in runtime is unsupported, consider putting this property (%s) in prototype' %name)

		for idx, gen in enumerate(self.children):
			var = "%s$child%d" %(escape(parent), idx)
			component = registry.find_component(self.package, gen.component.name)
			prologue.append("%svar %s" %(ident, var))
			r.append("%s%s = new _globals.%s(%s)" %(ident, var, component, parent))
			p, code = self.call_create(registry, ident_n, var, gen)
			prologue.append(p)
			r.append(code)

		for target, value in self.assignments.iteritems():
			if target == "id":
				if "." in value:
					raise Exception("expected identifier, not expression")
				r.append("%s%s._setId('%s')" %(ident, parent, value))
			elif target.endswith(".id"):
				raise Exception("setting id of the remote object is prohibited")
			else:
				self.check_target_property(registry, target)

			if isinstance(value, component_generator):
				var = "%s$%s" %(escape(parent), escape(target))
				if target != "delegate":
					prologue.append("%svar %s" %(ident, var))
					r.append("//creating component %s" %value.name)
					r.append("%s%s = new _globals.%s(%s)" %(ident, var, registry.find_component(value.package, value.component.name), parent))
					p, code = self.call_create(registry, ident_n, var, value)
					prologue.append(p)
					r.append(code)
					r.append('%s%s.%s = %s' %(ident, parent, target, var))
				else:
					code = "%svar %s = new _globals.%s(%s, true)\n" %(ident, var, registry.find_component(value.package, value.component.name), parent)
					code += "\n".join(self.call_create(registry, ident_n, var, value)) + '\n'
					code += self.call_setup(registry, ident_n, var, value) + '\n'
					r.append("%s%s.%s = (function() {\n%s\n%s\nreturn %s\n}).bind(%s)" %(ident, parent, target, code, ident, var, parent))

		for name, target in self.aliases.iteritems():
			get, pname = generate_accessors(target)
			r.append("%score.addAliasProperty(%s, '%s', (function() { return %s; }).bind(%s), '%s')" \
				%(ident, parent, name, get, parent, pname))

		return "\n".join(prologue), "\n".join(r)

	def get_rvalue(self, parent, target):
		path = target.split(".")
		path = ["_get('%s')" %x for x in path]
		return "%s.%s" % (parent, ".".join(path))

	def get_lvalue(self, parent, target):
		path = target.split(".")
		path = ["_get('%s')" %x for x in path[:-1]] + [path[-1]]
		return "%s.%s" % (parent, ".".join(path))


	def generate_setup_code(self, registry, parent, ident_n = 1):
		r = []
		ident = "\t" * ident_n


		for target, value in self.assignments.iteritems():
			if target == "id":
				continue
			t = type(value)
			#print self.name, target, value
			target_lvalue = self.get_lvalue(parent, target)
			if t is str:
				value = replace_enums(value, self, registry)
				deps = parse_deps(parent, value)
				if deps:
					var = "update$%s$%s" %(escape(parent), escape(target))
					r.append('//assigning %s to %s' %(target, value))
					r.append("%svar %s = (function() { %s = (%s); }).bind(%s)" %(ident, var, target_lvalue, value, parent))
					r.append("%s%s();" %(ident, var))
					undep = []
					for idx, _dep in enumerate(deps):
						path, dep = _dep
						if dep == 'model':
							path, dep = "%s._get('_delegate')" %parent, '_row'
						depvar = "dep$%s$%s$%d" %(escape(parent), escape(target), idx)
						r.append('%svar %s = %s' %(ident, depvar, path))
						r.append("%s%s.connectOnChanged(%s, '%s', %s)" %(ident, parent, depvar, dep, var))
						undep.append("[%s, '%s', %s]" %(depvar, dep, var))
					r.append("%s%s._removeUpdater('%s', [%s])" %(ident, parent, target, ",".join(undep)))
				else:
					r.append('//assigning %s to %s' %(target, value))
					r.append("%s%s._removeUpdater('%s'); %s = (%s);" %(ident, parent, target, target_lvalue, value))

			elif t is component_generator:
				if target == "delegate":
					continue
				var = "%s$%s" %(escape(parent), escape(target))
				r.append(self.call_setup(registry, ident_n, var, value))
			else:
				raise Exception("skip assignment %s = %s" %(target, value))

		if not self.prototype:
			for name, argscode in self.methods.iteritems():
				args, code = argscode
				code = process(code, self, registry)
				r.append("%s%s.%s = (function(%s) %s ).bind(%s)" %(ident, parent, name, ",".join(args), code, parent))

		for name, argscode in self.signal_handlers.iteritems():
			args, code = argscode
			code = process(code, self, registry)
			if name != "completed":
				r.append("%s%s.on('%s', (function(%s) %s ).bind(%s))" %(ident, parent, name, ",".join(args), code, parent))
			else:
				r.append("%s%s._context._onCompleted((function() %s ).bind(%s))" %(ident, parent, code, parent))
		for name, code in self.changed_handlers.iteritems():
			code = process(code, self, registry)
			r.append("%s%s.onChanged('%s', (function(value) %s ).bind(%s))" %(ident, parent, name, code, parent))
		for name, code in self.key_handlers.iteritems():
			code = process(code, self, registry)
			r.append("%s%s.onPressed('%s', (function(key, event) %s ).bind(%s))" %(ident, parent, name, code, parent))

		for name, target in self.aliases.iteritems():
			r.append("%s%s._update('%s', %s.%s)" \
				%(ident, parent, name, parent, name))

		r.append(self.generate_animations(registry, parent))

		for idx, value in enumerate(self.children):
			var = '%s$child%d' %(escape(parent), idx)
			r.append(self.call_setup(registry, ident_n, var, value))
			r.append("%s%s.addChild(%s)" %(ident, parent, var));

		if self.elements:
			r.append("\t%s.assign(%s)" %(parent, json.dumps(self.elements)))

		return "\n".join(r)
