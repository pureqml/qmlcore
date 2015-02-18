#!/usr/bin/env python

import lang
from code import process, parse_deps, generate_accessors

def get_package(name):
	return ".".join(name.split(".")[:-1])

def split_name(name):
	r = name.split(".")
	return ".".join(r[:-1]), r[-1]

class component_generator(object):
	def __init__(self, name, component):
		self.name = name
		self.component = component
		self.aliases = {}
		self.properties = {}
		self.assignments = {}
		self.animations = {}
		self.package = get_package(name)
		self.base_type = None
		self.children = []
		self.methods = {}
		self.event_handlers = {}
		self.changed_handlers = {}
		self.key_handlers = {}
		self.events = set()
		self.id = None

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
		self.assignments[target] = value

	def add_child(self, child):
		t = type(child)
		if t is lang.Property:
			if child.name in self.properties or child.name in self.aliases:
				raise Exception("duplicate property " + child.name)
			self.properties[child.name] = child.type
			if child.value is not None:
				self.assign(child.name, child.value)
		elif t is lang.AliasProperty:
			if child.name in self.properties or child.name in self.aliases:
				raise Exception("duplicate property " + child.name)
			self.aliases[child.name] = child.target
		elif t is lang.Assignment:
			self.assign(child.target, child.value)
		elif t is lang.IdAssignment:
			self.id = child.name
			self.assign("id", child.name)
		elif t is lang.Component:
			self.children.append(component_generator(self.package + ".<anonymous>", child))
		elif t is lang.Behavior:
			if child.target in self.animations:
				raise Exception("duplicate animation on property " + child.target);
			self.animations[child.target] = component_generator(self.package + ".<anonymous-animation>", child.animation)
		elif t is lang.Method:
			name, code = child.name, child.code
			if len(name) > 2 and name.startswith("on") and name[2].isupper(): #onXyzzy
				name = name[2].lower() + name[3:]
				if name.endswith("Pressed"):
					name = name[0].upper() + name[1:-7]
					if name in self.key_handlers:
						raise Exception("duplicate key handler " + child.name)
					self.key_handlers[name] = code
				elif name.endswith("Changed"):
					name = name[:-7]
					if name in self.changed_handlers:
						raise Exception("duplicate event handler " + child.name)
					self.changed_handlers[name] = code
				else:
					if name in self.event_handlers:
						raise Exception("duplicate event handler " + child.name)
					self.event_handlers[name] = code
			else:
				if name in self.methods:
					raise Exception("duplicate method " + name)
				self.methods[name] = code
		elif t is lang.Event:
			name = child.name
			if name in self.events:
				raise Exception("duplicate event " + name)
			self.events.add(name)
		else:
			print "unhandled", child

	def generate_properties(self):
		r = []
		for name, type in self.properties.iteritems():
			r.append("\tcore.addProperty(this, '%s', '%s');" %(type, name))
		return "\n".join(r)

	def generate_ctor(self, registry):
		return "\texports.%s.apply(this, arguments);\n" %(registry.find_component(self.package, self.component.name))

	def generate(self, registry):
		ctor  = "\texports.%s = function() {\n%s\n%s\n%s\n%s\n\tcore._bootstrap(this, '%s');\n}\n" %(self.name, self.generate_ctor(registry), self.generate_properties(), "\n".join(self.generate_creators(registry, "this")), self.generate_setup_code(registry, "this"), self.name)
		return ctor

	def generate_animations(self, registry, parent):
		r = []
		for name, animation in self.animations.iteritems():
			var = "behavior_on_" + name
			r.append("\tvar %s = new _globals.%s(%s);" %(var, registry.find_component(self.package, animation.component.name), parent))
			r.append(self.wrap_creator("create", var, "\n".join(animation.generate_creators(registry, var, 2))))
			r.append(self.wrap_creator("setup", var, animation.generate_setup_code(registry, var, 2)))
			r.append("\tthis.setAnimation('%s', %s);\n" %(name, var))
		return "\n".join(r)

	def wrap_creator(self, prefix, var, code):
		if not code.strip():
			return ""
		safe_var = var.replace('.', '__')
		return "\tfunction %s_%s () {\n%s\n\t}\n\t%s_%s.call(%s)" %(prefix, safe_var, code, prefix, safe_var, var)

	def generate_creators(self, registry, parent, ident_n = 1):
		prologue = []
		r = []
		ident = "\t" * ident_n

		for name in self.events:
			r.append("%sthis.%s = (function() { var args = Array.prototype.slice.call(arguments); args.splice(0, 0, '%s'); this._emitEvent.apply(this, args);/*fixme*/ }).bind(this)" %(ident, name, name))

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
			if target == "id":
				if "." in value:
					raiseException("expected identifier, not expression")
				r.append("%sthis._setId('%s')" %(ident, value))
			elif target.endswith(".id"):
				raise Exception("setting id of the remote object is prohibited")

			if isinstance(value, component_generator):
				var = "%s_%s" %(parent, target.replace('.', '__'))
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

	def generate_setup_code(self, registry, parent, ident_n = 1):
		r = []
		ident = "\t" * ident_n
		for name, target in self.aliases.iteritems():
			get, pname = generate_accessors(target)
			r.append("""\
	core.addAliasProperty(this, '%s',
		(function() { return %s; }).bind(this),
		(function() { return %s.get('%s'); }).bind(this),
		(function(value) { %s.%s = value; }).bind(this));
""" %(name, get, get, pname, get, pname))
		for target, value in self.assignments.iteritems():
			if target == "id":
				continue
			t = type(value)
			#print self.name, target, value
			if t is str:
				deps = parse_deps(value)
				if deps:
					suffix = "_var_%s__%s" %(parent.replace('.', '_'), target.replace('.', '_'))
					var = "_update" + suffix
					r.append("%svar %s = (function() { this.%s = %s; }).bind(this);" %(ident, var, target, value))
					r.append("%s%s();" %(ident, var))
					undep = []
					for path, dep in deps:
						r.append("%s%s.onChanged('%s', %s);" %(ident, path, dep, var))
						undep.append("%s.removeOnChanged('%s', _update%s)" %(path, dep, suffix))
					r.append("%sthis._removeUpdater('%s', (function() { %s }).bind(this));" %(ident, target, ";".join(undep)))
				else:
					r.append("%sthis._removeUpdater('%s'); this.%s = %s;" %(ident, target, target, value))

			elif t is component_generator:
				if target == "delegate":
					continue
				var = "%s_%s" %(parent, target.replace('.', '__'))
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
		for name, code in self.methods.iteritems():
			code = process(code, registry)
			r.append("%sthis.%s = (function() %s ).bind(this);" %(ident, name, code))
		for name, code in self.event_handlers.iteritems():
			code = process(code, registry)
			if name != "completed":
				r.append("%sthis.on('%s', (function() %s ).bind(this));" %(ident, name, code))
			else:
				r.append("%sqml._context._onCompleted((function() %s ).bind(this));" %(ident, code))
		for name, code in self.changed_handlers.iteritems():
			code = process(code, registry)
			r.append("%sthis.onChanged('%s', (function() %s ).bind(this));" %(ident, name, code))
		for name, code in self.key_handlers.iteritems():
			code = process(code, registry)
			r.append("%sthis.onPressed('%s', (function() %s ).bind(this));" %(ident, name, code))
		r.append(self.generate_animations(registry, parent))
		return "\n".join(r)

class generator(object):
	def __init__(self):
		self.components = {}
		self.imports = {}
		self.packages = {}
		self.startup = []
		self.id_set = set(['renderer'])
		self.startup.append("qml.core.core._setup();")
		self.startup.append("qml._context = new qml.core.core.Context();")

	def add_component(self, name, component, declaration):
		if name in self.components:
			raise Exception("duplicate component " + name)

		package, component_name = split_name(name)

		if not declaration:
			name = "%s.Ui%s" %(package, component_name[0].upper() + component_name[1:])
			self.startup.append("qml._context.start(qml.%s)" %name)

		if package not in self.packages:
			self.packages[package] = set()
		self.packages[package].add(component_name)

		gen = component_generator(name, component)
		self.components[name] = gen

	def add_js(self, name, data):
		if name in self.imports:
			raise Exception("duplicate js name " + name)
		self.imports[name] = data

	def add_components(self, name, components, declaration):
		for component in components:
			self.add_component(name, component, declaration)

	def wrap(self, code):
		return "(function() {\nvar exports = {};\n%s\nreturn exports;\n} )" %code

	def find_component(self, package, name):
		if name == "Object":
			return "core.Object"

		if package in self.packages and name in self.packages[package]:
			return "%s.%s" %(package, name)
		for package_name, components in self.packages.iteritems():
			if name in components:
				return "%s.%s" %(package_name, name)
		raise Exception("component %s was not found" %name)

	def generate_components(self):
		r, base_class = [], {}

		for gen in self.components.itervalues():
			gen.collect_id(self.id_set)

		for name, gen in self.components.iteritems():
			code = "//=====[component %s]=====================\n\n" %name
			code += gen.generate(self)
			base_type = self.find_component(gen.package, gen.component.name)

			base_class[name] = base_type
			r.append(code)

		deps = []
		visited = set(['core.Object'])
		def visit(type):
			if type in visited:
				return
			visit(base_class[type])
			deps.append(type)
			visited.add(type)

		for type in base_class.iterkeys():
			visit(type)

		for type in deps:
			code = ""
			code += "\texports.%s.prototype = Object.create(exports.%s.prototype);\n" %(type, base_class[type])
			code += "\texports.%s.prototype.constructor = exports.%s;\n" %(type, type)
			r.append(code)

		return "\n".join(r)

	def generate_imports(self):
		r = []
		for package in sorted(self.packages.keys()):
			r.append("if (!exports.%s) exports.%s = {};" %(package, package))

		for name, code in self.imports.iteritems():
			safe_name = name
			if safe_name.endswith(".js"):
				safe_name = safe_name[:-3]
			safe_name = safe_name.replace('/', '.')
			code = "//=====[import %s]=====================\n\n" %name + code
			r.append("_globals.%s = %s()" %(safe_name, self.wrap(code)))
		return "\n".join(r)

	def generate(self, ns):
		text = ""
		text += "var _globals = exports;\n"
		text += "%s\n" %self.generate_imports()
		text += "//========================================\n\n"
		text += "var core = _globals.core.core;\n"
		text += "%s\n" %self.generate_components()
		return "%s = %s();\n" %(ns, self.wrap(text))

	def generate_startup(self):
		return "\n".join(self.startup)
