from compiler.js import get_package, split_name, escape
from compiler.js.code import process, parse_deps, generate_accessors, replace_enums, path_or_parent, mangle_path
from compiler import lang
import json
from functools import partial

class component_generator(object):
	def __init__(self, ns, name, component, prototype = False):
		self.ns = ns
		self.name = name
		self.component = component
		self.aliases = {}
		self.declared_properties = {}
		self.lazy_properties = {}
		self.const_properties = {}
		self.properties = []
		self.enums = {}
		self.assignments = {}
		self.animations = {}
		self.package = get_package(name)
		self.base_type = None
		self.children = []
		self.methods = {}
		self.signals = set()
		self.elements = []
		self.generators = []
		self.id = None
		self.prototype = prototype
		self.ctor = ''
		self.prototype_ctor = ''

		for child in component.children:
			self.add_child(child)

	@property
	def class_name(self):
		idx = self.name.rindex('.')
		return self.name[idx + 1:] if idx >= 0 else self.name

	@property
	def local_name(self):
		return self.class_name + 'Component'

	@property
	def base_local_name(self):
		return self.class_name + 'BaseComponent'

	@property
	def proto_name(self):
		return self.class_name + 'Prototype'

	@property
	def base_proto_name(self):
		return self.class_name + 'BasePrototype'

	def collect_id(self, id_set):
		if self.id is not None:
			id_set.add(self.id)
		for g in self.generators:
			g.collect_id(id_set)

	def create_component_generator(self, component, suffix = '<anonymous>'):
		value = component_generator(self.ns, self.package + "." + suffix, component)
		self.generators.append(value)
		return value

	def assign(self, target, value):
		t = type(value)
		if t is lang.Component:
			value = self.create_component_generator(value)
		if t is str: #and value[0] == '"' and value[-1] == '"':
			value = value.replace("\\\n", "") #multiline continuation \<NEWLINE>
		if target in self.assignments:
			raise Exception("double assignment to '%s' in %s of type %s" %(target, self.name, self.component.name))
		self.assignments[target] = value

	def has_property(self, name):
		return (name in self.declared_properties) or (name in self.aliases) or (name in self.enums)

	def add_child(self, child):
		t = type(child)
		if t is lang.Property:
			self.properties.append(child)
			for name, default_value in child.properties:
				if self.has_property(name):
					raise Exception("duplicate property " + name)

				#print self.name, name, default_value, lang.value_is_trivial(default_value)
				if child.lazy:
					if not isinstance(default_value, lang.Component):
						raise Exception("lazy property must be declared with component as value")
					if len(child.properties) != 1:
						raise Exception("property %s is lazy, hence should be declared alone" %name)
					self.lazy_properties[name] = self.create_component_generator(default_value, '<lazy:%s>' %name)

				if child.const:
					if len(child.properties) != 1:
						raise Exception("property %s is const, hence should be declared alone" %name)
					self.const_properties[name] = default_value #string code

				self.declared_properties[name] = child
				if default_value is not None and not child.const:
					if not child.lazy and not lang.value_is_trivial(default_value):
						self.assign(name, default_value)
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
			value = self.create_component_generator(child)
			self.children.append(value)
		elif t is lang.Behavior:
			for target in child.target:
				if target in self.animations:
					raise Exception("duplicate animation on property " + target)
				value = self.create_component_generator(child.animation, "<anonymous-animation>")
				self.animations[target] = value
		elif t is lang.Method:
			for name in child.name:
				if name == 'constructor':
					if self.ctor != '':
						raise Exception("duplicate constructor")
					self.ctor = "\t//custom constructor:\n\t" + child.code + "\n"
				elif name == 'prototypeConstructor':
					if not self.prototype:
						raise Exception('prototypeConstructor can be used only in prototypes')
					if self.prototype_ctor != '':
						raise Exception("duplicate constructor")
					self.prototype_ctor = child.code
				else:
					fullname, args, code = split_name(name), child.args, child.code
					if fullname in self.methods:
						raise Exception("duplicate method " + name)
					self.methods[fullname] = args, code, child.event #fixme: fix code duplication here
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

	def call_create(self, registry, ident_n, target, value, closure):
		assert isinstance(value, component_generator)
		ident = '\t' * ident_n
		code = '\n//creating component %s\n' %value.component.name
		code += '%s%s.$c(%s.$c$%s = { })\n' %(ident, target, closure, target)
		if not value.prototype:
			c = value.generate_creators(registry, target, closure, ident_n)
			code += c
		return code

	def call_setup(self, registry, ident_n, target, value, closure):
		assert isinstance(value, component_generator)
		ident = '\t' * ident_n
		code = '\n//setting up component %s\n' %value.component.name
		code += '%svar %s = %s.%s\n' %(ident, target, closure, target)
		code += '%s%s.$s(%s.$c$%s)\n' %(ident, target, closure, target)
		code += '%sdelete %s.$c$%s\n' %(ident, closure, target)
		if not value.prototype:
			code += '\n' + value.generate_setup_code(registry, target, closure, ident_n)
		return code

	def get_base_type(self, registry, register_used = True):
		return registry.find_component(self.package, self.component.name, register_used)

	def generate(self, registry):
		base_type = self.get_base_type(registry)
		r = []
		r.append("\tvar %s = _globals.%s" %(self.base_local_name, base_type))
		r.append("\tvar %s = %s.prototype" %(self.base_proto_name, self.base_local_name))
		r.append("")
		r.append("/**\n * @constructor")
		r.append(" * @extends {_globals.%s}" %base_type)
		r.append(" */")
		r.append("\tvar %s = _globals.%s = function(parent, row) {" %(self.local_name, self.name))
		r.append("\t\t%s.apply(this, arguments)" % self.base_local_name)
		r.append(self.ctor)
		r.append("\t}")
		r.append("")
		return "\n".join(r)

	def generate_animations(self, registry, parent):
		r = []
		for name, animation in self.animations.iteritems():
			var = "behavior_%s_on_%s" %(escape(parent), escape(name))
			r.append("\tvar %s = new _globals.%s(%s)" %(var, registry.find_component(self.package, animation.component.name), parent))
			r.append("\tvar %s$c = { %s: %s }" %(var, var, var))
			r.append(self.call_create(registry, 1, var, animation, var + '$c'))
			r.append(self.call_setup(registry, 1, var, animation, var + '$c'))
			target_parent, target = split_name(name)
			if not target_parent:
				target_parent = parent
			else:
				target_parent = self.get_rvalue(registry, parent, target_parent)
			r.append("\t%s.setAnimation('%s', %s);\n" %(target_parent, target, var))
		return "\n".join(r)

	#no cross-component access here
	def pregenerate(self, registry):
		self.collect_id(registry.id_set)

		for gen in self.generators:
			gen.pregenerate(registry)

		methods = self.methods
		self.methods = {}
		self.changed_handlers = {}
		self.signal_handlers = {}
		self.key_handlers = {}
		#print 'pregenerate', self.name
		base_type = self.get_base_type(registry, False)
		base_gen = registry.components[base_type] if base_type != 'core.CoreObject' else None

		for (path, name), (args, code, event) in methods.iteritems():
			oname = name
			fullname = path, name

			is_on = event and len(name) > 2 and name != "onChanged" and name.startswith("on") and name[2].isupper() #onXyzzy
			if is_on:
				signal_name = name[2].lower() + name[3:] #check that there's no signal with that name
			is_pressed = is_on and name.endswith("Pressed") and len(name) > (2 + 7) #skipping onPressed
			is_changed = is_on and name.endswith("Changed")
			if is_changed:
				if signal_name in base_gen.signals:
					is_changed = False
			if is_pressed:
				if signal_name in base_gen.signals:
					is_pressed = False

			if is_on:
				name = name[2].lower() + name[3:]
				fullname = path, name
				if is_pressed:
					name = name[0].upper() + name[1:-7]
					fullname = path, name
					if fullname in self.key_handlers:
						raise Exception("duplicate key handler " + oname)
					self.key_handlers[fullname] = (('key', 'event'), code)
				elif is_changed:
					name = name[:-7]
					fullname = path, name
					if fullname in self.changed_handlers:
						raise Exception("duplicate signal handler " + oname)
					self.changed_handlers[fullname] = (('value', ), code)
				else:
					if fullname in self.signal_handlers:
						raise Exception("duplicate signal handler " + oname)
					self.signal_handlers[fullname] = args, code
			else:
				if fullname in self.methods:
					raise Exception("duplicate method " + oname)
				self.methods[fullname] = args, code

	def generate_lazy_property(self, registry, proto, type, name, value, ident_n = 1):
		ident = "\t" * ident_n
		var = 'lazy$' + name
		code = self.generate_creator_function(registry, var, value, ident_n + 1)
		return "%score.addLazyProperty(%s, '%s', %s)" %(ident, proto, name, code)

	def generate_const_property(self, registry, proto, name, code, ident_n = 1):
		ident = "\t" * ident_n
		var = 'const$' + name
		return "%score.addConstProperty(%s, '%s', function() %s)" %(ident, proto, name, code)

	def transform_handlers(self, registry, blocks):
		result = {}
		for (path, name), (args, code) in blocks.iteritems():
			code = process(code, self, registry, args)
			code = "function(%s) %s" %(",".join(args), code)
			result.setdefault(code, []).append((path, name))
		return sorted(result.iteritems())

	def generate_prototype(self, registry, ident_n = 1):
		assert self.prototype == True

		r = []
		ident = "\t" * ident_n

		base_type = self.get_base_type(registry)

		r.append("%svar %s = %s.prototype = Object.create(%s)\n" %(ident, self.proto_name, self.local_name, self.base_proto_name))
		if self.prototype_ctor:
			r.append("\t%s\n" %(self.prototype_ctor))
		r.append("%s%s.constructor = %s\n" %(ident, self.proto_name, self.local_name))

		r.append("%s%s.componentName = '%s'" %(ident, self.proto_name, self.name))

		for name in self.signals:
			r.append("%s%s.%s = _globals.core.createSignal('%s')" %(ident, self.proto_name, name, name))

		for prop in self.properties:
			for name, default_value in prop.properties:
				if prop.lazy:
					gen = self.lazy_properties[name]
					r.append(self.generate_lazy_property(registry, self.proto_name, prop.type, name, gen, ident_n))
				elif prop.const:
					r.append(self.generate_const_property(registry, self.proto_name, name, self.const_properties[name]))
				else:
					args = ["%s" %self.proto_name, "'%s'" %prop.type, "'%s'" %name]
					if lang.value_is_trivial(default_value):
						default_value, deps = parse_deps('@error', default_value, partial(self.transform_root, registry))
						if deps:
							raise Exception('trivial value emits dependencies')
						args.append(default_value)
					r.append("%score.addProperty(%s)" %(ident, ", ".join(args)))

		for name, prop in self.enums.iteritems():
			values = prop.values

			for i in xrange(0, len(values)):
				r.append("/** @const @type {number} */")
				r.append("%s%s.%s = %d" %(ident, self.proto_name, values[i], i))
				r.append("/** @const @type {number} */")
				r.append("%s%s.%s = %d" %(ident, self.local_name, values[i], i))

			args = [self.proto_name, "'enum'", "'%s'" %name]
			if prop.default is not None:
				args.append("%s.%s" %(self.local_name, prop.default))
			r.append("%score.addProperty(%s)" %(ident, ", ".join(args)))

		def next_codevar(lines, code, index):
			var = "$code$%d" %index
			code = '%svar %s = %s' %(ident, var, code)
			lines.append(code)
			return var

		def put_in_prototype(handler):
			path, name = handler
			return not path and self.prototype

		code_index = 0

		for code, methods in self.transform_handlers(registry, self.methods):
			if len(methods) > 1:
				code = next_codevar(r, code, code_index)
				code_index += 1

			for path, name in methods:
				if path:
					raise Exception('no <id> qualifiers (%s) allowed in prototypes %s (%s)' %(path, name, self.name))
				r.append("%s%s.%s = %s" %(ident, self.proto_name, name, code))

		for code, handlers in self.transform_handlers(registry, self.changed_handlers):
			handlers = filter(put_in_prototype, handlers)
			if not handlers:
				continue

			if len(handlers) > 1:
				code = next_codevar(r, code, code_index)
				code_index += 1

			for (path, name) in handlers:
				assert not path
				r.append("%s_globals.core._protoOnChanged(%s, '%s', %s)" %(ident, self.proto_name, name, code))

		for code, handlers in self.transform_handlers(registry, self.signal_handlers):
			handlers = filter(lambda h: put_in_prototype(h) and h[1] != 'completed', handlers)
			if not handlers:
				continue

			if len(handlers) > 1:
				code = next_codevar(r, code, code_index)
				code_index += 1

			for path, name in handlers:
				r.append("%s_globals.core._protoOn(%s, '%s', %s)" %(ident, self.proto_name, name, code))

		for code, handlers in self.transform_handlers(registry, self.key_handlers):
			handlers = filter(put_in_prototype, handlers)
			if not handlers:
				continue

			if len(handlers) > 1:
				code = next_codevar(r, code, code_index)
				code_index += 1

			for (path, name) in handlers:
				r.append("%s_globals.core._protoOnKey(%s, '%s', %s)" %(ident, self.proto_name, name, code))


		generate = False

		code = self.generate_creators(registry, '$this', '$c', ident_n + 1).strip()
		if code:
			generate = True
		b = '\t%s%s.$c.call(this, $c.$b = { })' %(ident, self.base_proto_name)
		code = '%s%s.$c = function($c) {\n\t\tvar $this = this;\n%s\n%s\n%s}' \
			%(ident, self.proto_name, b, code, ident)

		setup_code = self.generate_setup_code(registry, '$this', '$c', ident_n + 2).strip()
		b = '%s%s.$s.call(this, $c.$b); delete $c.$b' %(ident, self.base_proto_name)
		if setup_code:
			generate = True
		setup_code = '%s%s.$s = function($c) {\n\t\tvar $this = this;\n%s\n%s\n}' \
			%(ident, self.proto_name, b, setup_code)

		if generate:
			r.append('')
			r.append(code)
			r.append(setup_code)
			r.append('')

		return "\n".join(r)

	def find_property(self, registry, property):
		if property in self.declared_properties:
			return self.declared_properties[property]
		if property in self.enums:
			return self.enums[property]
		if property in self.aliases:
			return self.aliases[property]

		base = self.get_base_type(registry)
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

	def generate_creator_function(self, registry, name, value, ident_n = 1):
		ident = "\t" * ident_n
		code = "%svar %s = new _globals.%s(__parent, __row)\n" %(ident, name, registry.find_component(value.package, value.component.name))
		code += "%svar $c = { %s : %s }\n" %(ident, name, name)
		code += self.call_create(registry, ident_n + 1, name, value, '$c') + '\n'
		code += self.call_setup(registry, ident_n + 1, name, value, '$c') + '\n'
		return "(function(__parent, __row) {\n%s\n%sreturn %s\n})" %(code, ident, name)


	def generate_creators(self, registry, parent, closure, ident_n = 1):
		r = []
		ident = "\t" * ident_n

		if not self.prototype:
			for name in self.signals:
				r.append("%s%s.%s = _globals.core.createSignal('%s').bind(%s)" %(ident, parent, name, name, parent))

			for prop in self.properties:
				for name, default_value in prop.properties:
					if prop.lazy:
						gen = self.lazy_properties[name]
						r.append(self.generate_lazy_property(registry, parent, prop.type, name, gen, ident_n))
					elif prop.const:
						r.append(self.generate_const_property(registry, parent, name, self.const_properties[name]))
					else:
						args = [parent, "'%s'" %prop.type, "'%s'" %name]
						if lang.value_is_trivial(default_value):
							default_value, deps = parse_deps('@error', default_value, partial(self.transform_root, registry))
							if deps:
								raise Exception('trivial value emits dependencies')
							args.append(default_value)
						r.append("\tcore.addProperty(%s)" %(", ".join(args)))

			for name, prop in self.enums.iteritems():
				raise Exception('adding enums in runtime is unsupported, consider putting this property (%s) in prototype' %name)

		for idx, gen in enumerate(self.children):
			var = "%s$child%d" %(escape(parent), idx)
			component = registry.find_component(self.package, gen.component.name)
			r.append("%svar %s = new _globals.%s(%s)" %(ident, var, component, parent))
			r.append("%s%s.%s = %s" %(ident, closure, var, var))
			code = self.call_create(registry, ident_n, var, gen, closure)
			r.append(code)
			r.append("%s%s.addChild(%s)" %(ident, parent, var));

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
				if target != "delegate":
					var = "%s$%s" %(escape(parent), escape(target))
					r.append("//creating component %s" %value.name)
					r.append("%svar %s = new _globals.%s(%s)" %(ident, var, registry.find_component(value.package, value.component.name), parent))
					r.append("%s%s.%s = %s" %(ident, closure, var, var))
					code = self.call_create(registry, ident_n, var, value, closure)
					r.append(code)
					r.append('%s%s.%s = %s' %(ident, parent, target, var))
				else:
					code = self.generate_creator_function(registry, 'delegate', value, ident_n)
					r.append("%s%s.%s = %s" %(ident, parent, target, code))

		for name, target in self.aliases.iteritems():
			get, pname = generate_accessors(parent, target, partial(self.transform_root, registry))
			r.append("%score.addAliasProperty(%s, '%s', function() { return %s }, '%s')" \
				%(ident, parent, name, get, pname))

		return "\n".join(r)

	def transform_root(self, registry, property):
		if property == 'context':
			return '_context'
		elif property == 'parent':
			return 'parent'
		else:
			prop = self.find_property(registry, property)
			if prop:
				return property
			else:
				return "_get('%s')" %property

	def get_rvalue(self, registry, parent, target):
		path = target.split(".")
		return "%s.%s" % (parent, mangle_path(path, partial(self.transform_root, registry)))

	def get_lvalue(self, registry, parent, target):
		path = target.split(".")
		target_owner = [parent] + path[:-1]
		path = target_owner + [path[-1]]
		return ("%s" %".".join(target_owner), "%s" %".".join(path), path[-1])

	def generate_setup_code(self, registry, parent, closure, ident_n = 1):
		r = []
		ident = "\t" * ident_n

		for target, value in self.assignments.iteritems():
			if target == "id":
				continue
			t = type(value)
			#print self.name, target, value
			target_owner, target_lvalue, target_prop = self.get_lvalue(registry, parent, target)
			if t is str:
				value = replace_enums(value, self, registry)
				r.append('//assigning %s to %s' %(target, value))
				value, deps = parse_deps(parent, value, partial(self.transform_root, registry))
				if deps:
					var = "update$%s$%s" %(escape(parent), escape(target))
					r.append("%svar %s = function() { %s = %s; }" %(ident, var, target_lvalue, value))
					undep = []
					for idx, _dep in enumerate(deps):
						path, dep = _dep
						undep.append("[%s, '%s']" %(path, dep))
					r.append("%s%s._replaceUpdater('%s', %s, [%s])" %(ident, target_owner, target_prop, var, ",".join(undep)))
				else:
					r.append("%s%s._removeUpdater('%s'); %s = %s;" %(ident, target_owner, target_prop, target_lvalue, value))

			elif t is component_generator:
				if target == "delegate":
					continue
				var = "%s$%s" %(escape(parent), escape(target))
				r.append(self.call_setup(registry, ident_n, var, value, closure))
			else:
				raise Exception("skip assignment %s = %s" %(target, value))

		def put_in_instance(handler):
			path, name = handler
			return path or not self.prototype

		code_index = 0
		def next_codevar(lines, code, index):
			var = "$code$%d" %index
			code = '%svar %s = %s' %(ident, var, code)
			lines.append(code)
			return var

		if not self.prototype:
			for code, methods in self.transform_handlers(registry, self.methods):
				if len(methods) > 1:
					code = next_codevar(r, code, code_index)
					code_index += 1

				for path, name in sorted(methods):
					path = path_or_parent(path, parent, partial(self.transform_root, registry))
					r.append("%s%s.%s = %s.bind(%s)" %(ident, path, name, code, parent))

		for code, handlers in self.transform_handlers(registry, self.signal_handlers):
			handlers = filter(lambda h: put_in_instance(h) or h[1] == 'completed', handlers)
			if not handlers:
				continue

			if len(handlers) > 1:
				code = next_codevar(r, code, code_index)
				code_index += 1

			for path, name in sorted(handlers):
				path = path_or_parent(path, parent, partial(self.transform_root, registry))
				if name != "completed":
					r.append("%s%s.on('%s', %s.bind(%s))" %(ident, path, name, code, parent))
				else:
					r.append("%s%s._context._onCompleted(%s, %s)" %(ident, path, parent, code))

		for code, handlers in self.transform_handlers(registry, self.changed_handlers):
			handlers = filter(put_in_instance, handlers)
			if not handlers:
				continue

			if len(handlers) > 1:
				code = next_codevar(r, code, code_index)
				code_index += 1

			for path, name in sorted(handlers):
				path = path_or_parent(path, parent, partial(self.transform_root, registry))
				r.append("%s%s.onChanged('%s', %s.bind(%s))" %(ident, path, name, code, parent))

		for code, handlers in self.transform_handlers(registry, self.key_handlers):
			handlers = filter(put_in_instance, handlers)
			if not handlers:
				continue

			if len(handlers) > 1:
				code = next_codevar(r, code, code_index)
				code_index += 1

			for path, name in sorted(handlers):
				path = path_or_parent(path, parent, partial(self.transform_root, registry))
				r.append("%s%s.onPressed('%s', %s.bind(%s))" %(ident, path, name, code, parent))

		for idx, value in enumerate(self.children):
			var = '%s$child%d' %(escape(parent), idx)
			r.append(self.call_setup(registry, ident_n, var, value, closure))

		if self.elements:
			r.append("\t%s.assign(%s)" %(parent, json.dumps(self.elements, sort_keys=True)))

		r.append(self.generate_animations(registry, parent))

		return "\n".join(r)
