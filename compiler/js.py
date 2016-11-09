import lang
import json
import re
from code import process, parse_deps, generate_accessors, replace_enums

root_type = 'core.CoreObject'

def get_package(name):
	return ".".join(name.split(".")[:-1])

def split_name(name):
	r = name.split(".")
	return ".".join(r[:-1]), r[-1]

def escape(name):
	return name.replace('.', '__')

id_re = re.compile(r'[^a-zA-Z0-9_]')

def escape_id(name):
	return id_re.sub('_', name)

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

class generator(object):
	def __init__(self):
		self.components = {}
		self.used_packages = set()
		self.used_components = set()
		self.imports = {}
		self.packages = {}
		self.startup = []
		self.l10n = {}

	def add_component(self, name, component, declaration):
		if name in self.components:
			raise Exception("duplicate component " + name)

		package, component_name = split_name(name)
		package = escape_id(package)

		if not declaration:
			name = "%s.Ui%s" %(package, component_name[0].upper() + component_name[1:])
			self.used_components.add(name)
			self.used_packages.add(package)
			self.startup.append("\tqml._context.start(qml.%s)" %name)
		else:
			name = package + '.' + component_name

		if package not in self.packages:
			self.packages[package] = set()
		self.packages[package].add(component_name)

		gen = component_generator(name, component, True)
		self.components[name] = gen

	def add_js(self, name, data):
		if name in self.imports:
			raise Exception("duplicate js name " + name)
		self.imports[name] = data

	def wrap(self, code, use_globals = False):
		return "(function() {/** @const */\nvar exports = %s;\n%s\nreturn exports;\n} )" %("_globals" if use_globals else "{}", code)

	def find_component(self, package, name):
		if name == "CoreObject":
			return root_type

		dot = name.rfind('.')
		if dot >= 0:
			package = name[:dot]
			name = name[dot + 1:]

		if package in self.packages and name in self.packages[package]:
			self.used_components.add(package + '.' + name)
			return "%s.%s" %(package, name)

		candidates = []
		for package_name, components in self.packages.iteritems():
			if name in components:
				candidates.append(package_name)

		if not candidates:
			raise Exception("component %s was not found" %name)

		if len(candidates) > 1:
			raise Exception("ambigous component, you have to specify one of the packages explicitly: %s" % " ".join(map(lambda p: "%s.%s" %(p, name), candidates)))

		package_name = candidates[0]
		self.used_components.add(package_name + '.' + name)
		return "%s.%s" %(package_name, name)

	def generate_component(self, gen):
		name = gen.name

		self.id_set = set(['context'])
		gen.collect_id(self.id_set)
		self.used_packages.add(gen.package)

		code = ''
		code += "//=====[component %s]=====================\n\n" %name
		code += gen.generate(self)

		base_type = self.find_component(gen.package, gen.component.name)

		code += "\texports.%s.prototype = Object.create(exports.%s.prototype);\n" %(name, base_type)
		code += "\texports.%s.prototype.constructor = exports.%s;\n" %(name, name)

		code += gen.generate_prototype(self)
		return code


	def generate_components(self):
		generated = set([root_type])
		queue = ['core.Context']
		code, base_class = {}, {}

		while queue or self.used_components:
			for component in self.used_components:
				if component not in generated:
					queue.append(component)
			self.used_components = set()

			if queue:
				name = queue.pop(0)
				component = self.components[name]
				base_type = self.find_component(component.package, component.component.name)
				base_class[name] = base_type

				code[name] = self.generate_component(component)
				generated.add(name)

		r = ''
		order = []
		visited = set([root_type])
		def visit(type):
			if type in visited:
				return
			visit(base_class[type])
			order.append(type)
			visited.add(type)

		for type in base_class.iterkeys():
			visit(type)

		for type in order:
			r += code[type]

		return r

	def generate_prologue(self):
		for name in self.imports.iterkeys():
			self.used_packages.add(get_package(name))

		r = []
		packages = {}
		for package in sorted(self.used_packages):
			path = package.split(".")
			ns = packages
			for p in path:
				if p not in ns:
					ns[p] = {}
				ns = ns[p]

		path = "exports"
		def check(path, packages):
			for ns in packages.iterkeys():
				package = path + "." + ns
				r.append("if (!%s) /** @const */ %s = {}" %(package, package))
				check(package, packages[ns])
		check(path, packages)

		if 'core.core' in self.imports:
			r.append(self.generate_import('core.core', self.imports['core.core']))
		return '\n'.join(r)

	def generate_import(self, name, code):
		r = []
		safe_name = name
		if safe_name.endswith(".js"):
			safe_name = safe_name[:-3]
		safe_name = safe_name.replace('/', '.')
		code = "//=====[import %s]=====================\n\n" %name + code
		r.append("_globals.%s = %s()" %(safe_name, self.wrap(code, name == "core.core"))) #hack: core.core use _globals as its exports
		return "\n".join(r)


	def generate_imports(self):
		r = ''
		for name, code in self.imports.iteritems():
			if name != 'core.core':
				r += self.generate_import(name, code) + '\n'
		return r

	def generate(self, ns):
		code = self.generate_components() + '\n' #must be called first, generates used_packages/components sets
		text = ""
		text += "/** @const */\n"
		text += "var _globals = exports\n"
		text += "%s\n" %self.generate_prologue()
		text += "//========================================\n\n"
		text += "/** @const @type {!CoreObject} */\n"
		text += "var core = _globals.core.core\n"
		text += code
		text += "%s\n" %self.generate_imports()
		return "%s = %s();\n" %(ns, self.wrap(text))

	def generate_startup(self, ns, app, prefix):
		r = ""
		r += "try {\n"
		startup = []
		startup.append('\tvar l10n = %s\n' %json.dumps(self.l10n))
		startup.append("\t%s._context = new qml.core.Context()" %ns)
		startup.append("\t%s._context.init({id: 'qml-context-%s', prefix: '%s', l10n: l10n})" %(ns, app, prefix))
		startup += self.startup
		r += "\n".join(startup)
		r += "\n} catch(ex) { log(\"%s initialization failed: \", ex, ex.stack) }\n" %ns
		return r

	def add_ts(self, path):
		from ts import Ts
		ts = Ts(path)
		lang = ts.language
		if lang is None: #skip translation without target language (autogenerated base)
			print 'WARNING: no language in %s, translation ignored' %path
			return
		data = {}
		for ctx in ts:
			for msg in ctx:
				source, type, text = msg.source, msg.translation.type, msg.translation.text
				if type == 'just-obsoleted':
					texts = data.setdefault(source, {})
					texts[ctx.name] = text
		if data:
			self.l10n[lang] = data
