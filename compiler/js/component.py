from builtins import filter, object, range, str
from past.builtins import basestring
from collections import OrderedDict

from compiler.js import get_package, split_name, escape, mangle_package, Error
from compiler.js.code import ParseDepsContext
from compiler.js.code import process, parse_deps, generate_accessors, get_enum_prologue, path_or_parent, mangle_path
from compiler import lang
import json
from functools import partial
import re

class component_generator(object):
	def __init__(self, ns, parent, name, component, prototype = False):
		self.ns = ns
		self.name = name
		self.parent = parent
		self.component = component
		self.aliases = OrderedDict()
		self.declared_properties = OrderedDict()
		self.lazy_properties = OrderedDict()
		self.const_properties = OrderedDict()
		self.properties = []
		self.enums = OrderedDict()
		self.consts = OrderedDict()
		self.assignments = OrderedDict()
		self.animations = OrderedDict()
		self.package = get_package(name)
		self.base_type = None
		self.children = []
		self.methods = OrderedDict()
		self.signals = OrderedDict()
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
		return escape(self.name[idx + 1:] if idx >= 0 else self.name)

	@property
	def mangled_name(self):
		return mangle_package(get_package(self.name)) + '.' + self.class_name

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

	@property
	def loc(self):
		return self.component.loc

	def collect_id(self, id_set):
		if self.id is not None:
			id_set.add(self.id)
		for g in self.generators:
			g.collect_id(id_set)

	def create_component_generator(self, component, suffix = '<anonymous>'):
		value = component_generator(self.ns, self, self.package + "." + suffix, component)
		self.generators.append(value)
		return value

	def assign(self, target, value, loc):
		t = type(value)
		if t is lang.Component:
			value = self.create_component_generator(value)
			#print("dep %s:%s.%s -> %s:%s" % (hex(id(self)),self.component.name, target, hex(id(value)),value.component.name))
		if isinstance(value, (str, basestring)): #and value[0] == '"' and value[-1] == '"':
			value = str(value.replace("\\\n", "")) #multiline continuation \<NEWLINE>
		if target in self.assignments:
			raise Error("double assignment to '%s' in %s of type %s" %(target, self.name, self.component.name), loc)
		self.assignments[target] = value

	def has_property(self, name):
		return (name in self.declared_properties) or (name in self.aliases) or (name in self.enums)

	def add_child(self, child):
		t = type(child)
		if t is lang.Property:
			self.properties.append(child)
			for name, default_value in child.properties:
				if name == 'modelData':
					raise Error("modelData property is reserved for model row disambiguation and cannot be declared", child.loc)
				if self.has_property(name):
					raise Error("duplicate property %s.%s" %(self.name, name), child.loc)

				#print self.name, name, default_value, lang.value_is_trivial(default_value)
				if child.lazy:
					if not isinstance(default_value, lang.Component):
						raise Error("lazy property must be declared with component as value", child.loc)
					if len(child.properties) != 1:
						raise Error("property %s is lazy, hence should be declared alone" %name, child.loc)
					value = self.create_component_generator(default_value, '<lazy:%s>' %name)
					#print("dep %s:%s.%s -> %s:%s" % (hex(id(self)),self.component.name, name, hex(id(value)),value.component.name))
					self.lazy_properties[name] = value

				if child.const:
					if len(child.properties) != 1:
						raise Error("property %s is const, hence should be declared alone" %name, child.loc)
					self.const_properties[name] = default_value #string code

				self.declared_properties[name] = child
				if default_value is not None and not child.const:
					if not child.lazy and not lang.value_is_trivial(default_value):
						self.assign(name, default_value, child.loc)
		elif t is lang.AliasProperty:
			if self.has_property(child.name):
				raise Error("duplicate property " + child.name, child.loc)
			self.aliases[child.name] = child.target
		elif t is lang.EnumProperty:
			if self.has_property(child.name):
				raise Error("duplicate property " + child.name, child.loc)
			self.enums[child.name] = child
		elif t is lang.Assignment:
			if child.target == 'id':
				raise Error('assigning non-id for id', child.loc)
			self.assign(child.target, child.value, child.loc)
		elif t is lang.IdAssignment:
			if child.name == "modelData":
				raise Error("modelData property is reserved for model row disambiguation and cannot be an id of the component", child.loc)
			if child.name == "model":
				raise Error("id: model breaks model/delegate relationship and overrides current model row", child.loc)
			self.id = child.name
			self.assign("id", child.name, child.loc)
		elif t is lang.Component:
			value = self.create_component_generator(child)
			#print("dep %s:%s.<anonymous> -> %s:%s" % (hex(id(self)), self.component.name, hex(id(value)),value.component.name))
			self.children.append(value)
		elif t is lang.Behavior:
			for target in child.target:
				if target in self.animations:
					raise Error("duplicate animation on property " + target, child.loc)
				value = self.create_component_generator(child.animation, "<anonymous-animation>")
				#print("dep %s:%s.%s -> %s:%s" % (hex(id(self)), self.component.name, target, hex(id(value)),value.component.name))
				self.animations[target] = value
		elif t is lang.Method:
			for name in child.name:
				if name == 'constructor':
					if self.ctor != '':
						raise Error("duplicate constructor", child.loc)
					self.ctor = "\t//custom constructor:\n\t" + child.code + "\n"
				elif name == 'prototypeConstructor':
					if not self.prototype:
						raise Error('prototypeConstructor can be used only in prototypes', child.loc)
					if self.prototype_ctor != '':
						raise Error("duplicate constructor", child.loc)
					self.prototype_ctor = child.code
				else:
					fullname, args, code = split_name(name), child.args, child.code
					if fullname in self.methods:
						raise Error("duplicate method " + name, child.loc)
					self.methods[fullname] = args, code, child.event, child.async_ #fixme: fix code duplication here
		elif t is lang.Signal:
			name = child.name
			if name in self.signals:
				raise Error("duplicate signal " + name, child.loc)
			self.signals[name] = None
		elif t is lang.ListElement:
			self.elements.append(child.data)
		elif t is lang.AssignmentScope:
			for assign in child.values:
				self.assign(child.target + '.' + assign.target, assign.value, child.loc)
		elif t is lang.Const:
			if child.name in self.consts:
				raise Error("duplicate static property " + child.name, child.loc)
			self.consts[child.name] = child
		else:
			raise Error("unhandled element: %s" %child, child.loc)

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

	def get_base_type(self, registry, *args, **kw):
		kw['loc'] = self.loc
		return registry.find_component(self.package, self.component.name, *args, **kw)

	def generate(self, registry):
		base_type = self.get_base_type(registry, mangle = True)
		r = []
		r.append("\tvar %s = %s" %(self.base_local_name, base_type))
		r.append("\tvar %s = %s.prototype" %(self.base_proto_name, self.base_local_name))
		r.append("")
		r.append("/**\n * @constructor")
		r.append(" * @extends {%s}" %base_type)
		r.append(" */")
		r.append("\tvar %s = %s.%s = function(parent, row) {" %(self.local_name, mangle_package(self.package), self.class_name))
		r.append("\t\t%s.apply(this, arguments)" % self.base_local_name)
		r.append(self.ctor)
		r.append("\t}")
		r.append("")
		return "\n".join(r)

	def generate_animations(self, registry, parent):
		r = []
		for name, animation in self.animations.items():
			var = "behavior_%s_on_%s" %(escape(parent), escape(name))
			r.append("\tvar %s = new %s(%s)" %(var, registry.find_component(self.package, animation.component.name, mangle = True), parent))
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
		self.methods = OrderedDict()
		self.changed_handlers = OrderedDict()
		self.signal_handlers = OrderedDict()
		self.key_handlers = OrderedDict()
		#print 'pregenerate', self.name
		base_type = self.get_base_type(registry, register_used = False)
		base_gen = registry.components[base_type] if base_type != 'core.CoreObject' else None

		for (path, name), (args, code, event, async_) in methods.items():
			oname = name
			fullname = path, name

			is_on = event and len(name) > 2 and name != 'onCompleted' and name != "onChanged" and name.startswith("on") and (name[2].isupper() or name[2].isdigit) #onXyzzy
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
						raise Error("duplicate key handler " + oname, self.loc)
					self.key_handlers[fullname] = ('key', 'event'), code, False
				elif is_changed:
					name = name[:-7]
					fullname = path, name
					if fullname in self.changed_handlers:
						raise Error("duplicate signal handler " + oname, self.loc)
					self.changed_handlers[fullname] = ('value', ), code, False
				else:
					if fullname in self.signal_handlers:
						raise Error("duplicate signal handler " + oname, self.loc)
					self.signal_handlers[fullname] = args, code, False
			else:
				if fullname in self.methods:
					raise Error("duplicate method " + oname, self.loc)
				if name == 'onCompleted':
					fullname = path, '__complete'
				self.methods[fullname] = args, code, async_

	def generate_lazy_property(self, registry, proto, type, name, value, ident_n = 1):
		ident = "\t" * ident_n
		var = 'lazy$' + name
		code = self.generate_creator_function(registry, var, value, ident_n + 1)
		return "%score.addLazyProperty(%s, '%s', %s)" %(ident, proto, name, code)

	def generate_const_property(self, registry, proto, name, code, ident_n = 1):
		ident = "\t" * ident_n
		return "%score.addConstProperty(%s, '%s', function() %s)" %(ident, proto, name, code)

	def transform_handlers(self, registry, blocks):
		result = OrderedDict()
		for (path, name), (args, code, async_) in blocks.items():
			if name == '__complete':
				code = code.strip()
				if code[0] == '{' and code[-1] == '}':
					code = '{ @super.__complete.call(this)\n' + code[1:-1].strip() + '\n}'
			code = process(code, self, registry, args)
			code = "%sfunction(%s) %s" %("async " if async_ else "",  ",".join(args), code)
			result.setdefault(code, []).append((path, name))
		return sorted(result.items())

	def generate_prototype(self, registry, ident_n = 1):
		assert self.prototype == True

		r = []
		ident = "\t" * ident_n

		r.append("%svar %s = %s.prototype = Object.create(%s)\n" %(ident, self.proto_name, self.local_name, self.base_proto_name))
		if self.prototype_ctor:
			r.append("\t%s\n" %(self.prototype_ctor))
		r.append("%s%s.constructor = %s\n" %(ident, self.proto_name, self.local_name))

		r.append("%s%s.componentName = '%s'" %(ident, self.proto_name, self.name))

		for name in self.signals.keys():
			r.append("%s%s.%s = $core.createSignal('%s')" %(ident, self.proto_name, name, name))

		parse_deps_ctx = ParseDepsContext(registry, self)

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
						default_value, deps = parse_deps('@error', default_value, parse_deps_ctx)
						if deps:
							raise Error('trivial value emits dependencies %s (default: %s)' %(deps, default_value), self.loc)
						args.append(default_value)
					r.append("%score.addProperty(%s)" %(ident, ", ".join(args)))

		for name, prop in self.enums.items():
			values = prop.values

			for i in range(0, len(values)):
				r.append("/** @const @type {number} */")
				r.append("%s%s.%s = %d" %(ident, self.proto_name, values[i], i))
				r.append("/** @const @type {number} */")
				r.append("%s%s.%s = %d" %(ident, self.local_name, values[i], i))

			args = [self.proto_name, "'enum'", "'%s'" %name]
			if prop.default is not None:
				args.append("%s.%s" %(self.local_name, prop.default))
			r.append("%score.addProperty(%s)" %(ident, ", ".join(args)))

		for name, prop in self.consts.items():
			r.append("/** @const */")
			r.append("%s%s.%s = %s.%s = $core.core.convertTo('%s', %s)" %(ident, self.proto_name, name, self.local_name, name, prop.type, json.dumps(prop.value)))

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
					raise Error('no <id> qualifiers (%s) allowed in prototypes %s (%s)' %(path, name, self.name), self.loc)
				code = code.replace('@super.', self.base_proto_name + '.')
				r.append("%s%s.%s = %s" %(ident, self.proto_name, name, code))

		for code, handlers in self.transform_handlers(registry, self.changed_handlers):
			handlers = list(filter(put_in_prototype, handlers))
			if not handlers:
				continue

			if len(handlers) > 1:
				code = next_codevar(r, code, code_index)
				code_index += 1

			for (path, name) in handlers:
				assert not path
				r.append("%s$core._protoOnChanged(%s, '%s', %s)" %(ident, self.proto_name, name, code))

		for code, handlers in self.transform_handlers(registry, self.signal_handlers):
			handlers = list(filter(put_in_prototype, handlers))
			if not handlers:
				continue

			if len(handlers) > 1:
				code = next_codevar(r, code, code_index)
				code_index += 1

			for path, name in handlers:
				r.append("%s$core._protoOn(%s, '%s', %s)" %(ident, self.proto_name, name, code))

		for code, handlers in self.transform_handlers(registry, self.key_handlers):
			handlers = list(filter(put_in_prototype, handlers))
			if not handlers:
				continue

			if len(handlers) > 1:
				code = next_codevar(r, code, code_index)
				code_index += 1

			for (path, name) in handlers:
				r.append("%s$core._protoOnKey(%s, '%s', %s)" %(ident, self.proto_name, name, code))


		generate = False

		code = self.generate_creators(registry, '$this', '$c', ident_n + 1).strip()
		if code:
			generate = True
		b = '\t%s%s.$c.call(this, $c.$b = { })' %(ident, self.base_proto_name)
		code = '%s%s.$c = function($c) {\n\t\tvar $this = this;\n%s\n%s\n%s}' \
			%(ident, self.proto_name, b, code, ident)

		setup_code = self.generate_setup_code(registry, '$this', '$c', ident_n + 2).strip()
		b = '%s%s.$s.call($this, $c.$b); delete $c.$b' %(ident, self.base_proto_name)
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

	def find_method(self, registry, name):
		key = ('', name)
		method = self.methods.get(key, None)
		if method:
			return method
		base = self.get_base_type(registry)
		if base != 'core.CoreObject':
			return registry.components[base].find_method(registry, name)

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
				raise Error('unknown property %s in %s (%s)' %(path[0], self.name, self.component.name), self.loc)
		else: #len(path) == 1
			if not self.find_property(registry, target):
				raise Error('unknown property %s in %s (%s)' %(target, self.name, self.component.name), self.loc)

	def generate_creator_function(self, registry, name, value, ident_n = 1):
		ident = "\t" * ident_n
		code = "%svar %s = new %s(__parent, __row)\n" %(ident, name, registry.find_component(value.package, value.component.name, mangle = True))
		code += "%svar $c = { %s : %s }\n" %(ident, name, name)
		code += self.call_create(registry, ident_n + 1, name, value, '$c') + '\n'
		code += self.call_setup(registry, ident_n + 1, name, value, '$c') + '\n'
		return "(function(__parent, __row) {\n%s\n%sreturn %s\n})" %(code, ident, name)


	def generate_creators(self, registry, parent, closure, ident_n = 1):
		r = []
		ident = "\t" * ident_n

		if not self.prototype:
			parse_deps_ctx = ParseDepsContext(registry, self)
			for name in self.signals.keys():
				r.append("%s%s.%s = $core.createSignal('%s').bind(%s)" %(ident, parent, name, name, parent))

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
							default_value, deps = parse_deps('@error', default_value, parse_deps_ctx)
							if deps:
								raise Error('trivial value emits dependencies %s (default: %s)' %(deps, default_value), self.loc)
							args.append(default_value)
						r.append("\tcore.addProperty(%s)" %(", ".join(args)))

			for name, prop in self.enums.items():
				raise Error('adding enums without prototype is not supported, consider putting this property (%s) in prototype' %name, self.loc)
			for name, prop in self.consts.items():
				raise Error('adding consts without prototype is not unsupported, consider putting this property (%s) in prototype' %name, self.loc)

		for idx, gen in enumerate(self.children):
			var = "%s$child%d" %(escape(parent), idx)
			component = registry.find_component(self.package, gen.component.name, mangle = True)
			r.append("%svar %s = new %s(%s)" %(ident, var, component, parent))
			r.append("%s%s.%s = %s" %(ident, closure, var, var))
			code = self.call_create(registry, ident_n, var, gen, closure)
			r.append(code)
			r.append("%s%s.addChild(%s)" %(ident, parent, var))

		for target, value in self.assignments.items():
			if target == "id":
				if "." in value:
					raise Error("expected identifier, not expression", self.loc)
				r.append("%s%s._setId('%s')" %(ident, parent, value))
			elif target.endswith(".id"):
				raise Error("setting id of the remote object is prohibited", self.loc)
			else:
				self.check_target_property(registry, target)

			if isinstance(value, component_generator):
				if target != "delegate":
					var = "%s$%s" %(escape(parent), escape(target))
					r.append("//creating component %s" %value.name)
					r.append("%svar %s = new %s(%s)" %(ident, var, registry.find_component(value.package, value.component.name, mangle = True), parent))
					r.append("%s%s.%s = %s" %(ident, closure, var, var))
					code = self.call_create(registry, ident_n, var, value, closure)
					r.append(code)
					r.append('%s%s.%s = %s' %(ident, parent, target, var))
				else:
					code = self.generate_creator_function(registry, 'delegate', value, ident_n)
					r.append("%s%s.%s = %s" %(ident, parent, target, code))

		for name, target in self.aliases.items():
			get, pname = generate_accessors(parent, target, partial(self.transform_root, registry, None))
			r.append("%score.addAliasProperty(%s, '%s', function() { return %s }, '%s')" \
				%(ident, parent, name, get, pname))

		return "\n".join(r)

	def transform_root(self, registry, parent, property, lookup_parent=False):
		if property == 'context':
			return ("%s._get('%s')" %(parent, property)) if parent else '_context'
		elif property == 'parent':
			return 'parent'
		elif property == 'this':
			return 'this'
		elif property == 'window':
			return 'window'
		elif property == 'modelData':
			return "%s_get('_delegate')._local.modelData" %(parent + '.' if parent else '')
		else:
			prop = self.find_property(registry, property)
			if prop:
				return property
			else:
				if lookup_parent:
					#try to find property in parent generators
					g = self.parent
					prefix = "parent."
					while g:
						prop = g.find_property(registry, property)
						if prop:
							return prefix + property
						prefix += "parent."
						g = g.parent

				if property in registry.id_set:
					return ("%s._get('%s')" %(parent, property)) if parent else ("_get('%s')" %property)
				else:
					raise Error("Property %s.%s could not be resolved" %(self.name, property), self.loc)


	def get_rvalue(self, registry, parent, target):
		path = target.split(".")
		return "%s.%s" % (parent, mangle_path(path, partial(self.transform_root, registry, None)))

	def get_lvalue(self, registry, parent, target):
		path = target.split(".")
		target_owner = [parent] + path[:-1]
		path = target_owner + [path[-1]]
		return ("%s" %".".join(target_owner), "%s" %".".join(path), path[-1])

	re_name = re.compile('<property-name>')
	re_scale_name = re.compile('<scale-property-name>')

	@staticmethod
	def replace_template_values(target, value):
		dot = target.rfind('.')
		property_name = target[dot + 1:] if dot >= 0 else target
		if property_name == 'x':
			property_name = 'width'
		elif property_name == 'y':
			property_name = 'height'

		value = component_generator.re_name.sub(property_name, value)
		return component_generator.re_scale_name.sub('virtualScale', value)

	def generate_setup_code(self, registry, parent, closure, ident_n = 1):
		prologue, r = [], []
		ident = "\t" * ident_n

		parse_deps_ctx = ParseDepsContext(registry, self)

		for target, value in self.assignments.items():
			if target == "id":
				continue
			t = type(value)
			#print self.name, target, value
			target_owner, target_lvalue, target_prop = self.get_lvalue(registry, parent, target)
			if isinstance(value, (str, basestring)):
				prologue += get_enum_prologue(value, self, registry)
				value = component_generator.replace_template_values(target_prop, value)
				r.append('//assigning %s to %s' %(target, value))
				value, deps = parse_deps(parent, value, parse_deps_ctx)
				if deps:
					undep = []
					for idx, _dep in enumerate(deps):
						path, dep = _dep
						undep.append(path)
						undep.append("'%s'" %dep)
					r.append("%s%s._replaceUpdater('%s', function() { %s = %s }, [%s])" %(ident, target_owner, target_prop, target_lvalue, value, ",".join(undep)))
				else:
					r.append("%s%s._removeUpdater('%s'); %s = %s;" %(ident, target_owner, target_prop, target_lvalue, value))

			elif t is component_generator:
				if target == "delegate":
					continue
				var = "%s$%s" %(escape(parent), escape(target))
				r.append(self.call_setup(registry, ident_n, var, value, closure))
			else:
				raise Error("skip assignment %s = %s" %(target, value), self.loc)

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
					path = path_or_parent(path, parent, partial(self.transform_root, registry, None))
					code = code.replace('@super.', self.get_base_type(registry, mangle = True) + '.prototype.')
					r.append("%s%s.%s = %s.bind(%s)" %(ident, path, name, code, parent))

		for code, handlers in self.transform_handlers(registry, self.signal_handlers):
			handlers = list(filter(put_in_instance, handlers))
			if not handlers:
				continue

			if len(handlers) > 1:
				code = next_codevar(r, code, code_index)
				code_index += 1

			for path, name in sorted(handlers):
				has_path = bool(path)
				path = path_or_parent(path, parent, partial(self.transform_root, registry, parent))
				if has_path:
					r.append("%s%s.connectOn(%s, '%s', %s.bind(%s))" %(ident, parent, path, name, code, parent))
				else:
					r.append("%s%s.on('%s', %s.bind(%s))" %(ident, path, name, code, parent))

		for code, handlers in self.transform_handlers(registry, self.changed_handlers):
			handlers = list(filter(put_in_instance, handlers))
			if not handlers:
				continue

			if len(handlers) > 1:
				code = next_codevar(r, code, code_index)
				code_index += 1

			for path, name in sorted(handlers):
				has_path = bool(path)
				path = path_or_parent(path, parent, partial(self.transform_root, registry, parent))
				if has_path:
					r.append("%s%s.connectOnChanged(%s, '%s', %s.bind(%s))" %(ident, parent, path, name, code, parent))
				else:
					r.append("%s%s.onChanged('%s', %s.bind(%s))" %(ident, path, name, code, parent))

		for code, handlers in self.transform_handlers(registry, self.key_handlers):
			handlers = list(filter(put_in_instance, handlers))
			if not handlers:
				continue

			if len(handlers) > 1:
				code = next_codevar(r, code, code_index)
				code_index += 1

			for path, name in sorted(handlers):
				path = path_or_parent(path, parent, partial(self.transform_root, registry, parent))
				r.append("%s%s.onPressed('%s', %s.bind(%s))" %(ident, path, name, code, parent))

		for idx, value in enumerate(self.children):
			var = '%s$child%d' %(escape(parent), idx)
			r.append(self.call_setup(registry, ident_n, var, value, closure))

		if self.elements:
			r.append("%s%s.assign(%s)" %(ident, parent, json.dumps(self.elements, sort_keys=True)))

		r.append(self.generate_animations(registry, parent))
		r.append('%s%s.completed()' %(ident, parent))
		if prologue:
			prologue = ["%svar %s;" %(ident, ", ".join(prologue))]
		return "\n".join(prologue + r)
