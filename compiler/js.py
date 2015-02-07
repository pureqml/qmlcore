#!/usr/bin/env python

import lang

def get_package(name):
	return ".".join(name.split(".")[:-1])

def split_name(name):
	r = name.split(".")
	return ".".join(r[:-1]), r[-1]

class component_generator(object):
	def __init__(self, name, component):
		self.name = name
		self.component = component
		self.properties = {}
		self.assignments = {}
		self.animations = {}
		self.package = get_package(name)
		self.base_type = None
		self.children = []

		for child in component.children:
			self.add_child(child)

	def assign(self, target, value):
		t = type(value)
		if t is lang.Component:
			value = component_generator(self.package + ".<anonymous>", value)
		self.assignments[target] = value

	def add_child(self, child):
		t = type(child)
		if t is lang.Property:
			if child.name in self.properties:
				raise Exception("duplicate property " + child.name)
			self.properties[child.name] = child.type
			if child.value is not None:
				self.assign(child.name, child.value)
		elif t is lang.Assignment:
			self.assign(child.target, child.value)
		elif t is lang.IdAssignment:
			self.assign("id", child.name)
		elif t is lang.Component:
			self.children.append(component_generator(self.package + ".<anonymous>", child))
		elif t is lang.Behavior:
			if child.target in self.animations:
				raise Exception("duplicate animation on property " + child.target);
			self.animations[child.target] = component_generator(self.package + ".<anonymous-animation>", child.animation)
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
		ctor  = "\texports.%s = function() {\n%s\n%s\n%s\n\tcore._bootstrap(this, '%s');\n}\n" %(self.name, self.generate_ctor(registry), self.generate_properties(), self.generate_creator(registry), self.name)
		return ctor

	def generate_animations(self, registry):
		r = []
		for name, animation in self.animations.iteritems():
			var = "behavior_on_" + name
			r.append("\tvar %s = new _globals.%s(%s);" %(var, registry.find_component(self.package, animation.component.name), "this"))
			r.append(animation.generate_creator(registry, var, 2))
			r.append("\tthis.setAnimation('%s', %s);\n" %(name, var))
		return "\n".join(r)

	def generate_creator(self, registry, target_object = "this", ident = 1):
		r = []
		ident = "\t" * ident
		for target, value in self.assignments.iteritems():
			t = type(value)
			#print self.name, target, value
			if target == "id":
				if "." in value:
					raiseException("expected identifier, not expression")
				r.append("%s%s._setId('%s')" %(ident, target_object, value))
			elif target.endswith(".id"):
				raise Exception("setting id of the remote object is prohibited")
			elif t is str:
				r.append("%s%s.%s = %s;" %(ident, target_object, target, value))
			elif t is component_generator:
				var = "this.%s" %target
				r.append("\t%s = new _globals.%s(this);" %(var, registry.find_component(value.package, value.component.name)))
				r.append(value.generate_creator(registry, var, 2))
			else:
				raise Exception("skip assignment %s = %s" %(target, value))
		idx = 0
		for gen in self.children:
			var = "child%d" %idx
			component = registry.find_component(self.package, gen.component.name)
			r.append("\tvar %s = new _globals.%s(%s);" %(var, component, target_object))
			r.append(gen.generate_creator(registry, var, 2))
			r.append("\tthis.children.push(%s);" %var);
			r.append("")
			idx += 1
		r.append(self.generate_animations(registry))
		return "\n".join(r)

class generator(object):
	def __init__(self):
		self.components = {}
		self.imports = {}
		self.packages = {}
		self.startup = []

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
		r, deps = [], []
		for package in sorted(self.packages.keys()):
			r.append("if (!exports.%s) exports.%s = {};" %(package, package))

		for name, gen in self.components.iteritems():
			code = "//=====[component %s]=====================\n\n" %name
			code += gen.generate(self)
			base_type = self.find_component(gen.package, gen.component.name)

			for i in xrange(0, len(deps)):
				t, b = deps[i]
				if base_type == t: #my base class, append after
					deps.insert(i + 1, (name, base_type))
					break
				if name == b: #me is base class, prepend before
					deps.insert(i, (name, base_type))
					break
			else:
				deps.append((name, base_type))

			r.append(code)

		for type, base_type in deps:
			code = ""
			code += "\texports.%s.prototype = Object.create(exports.%s.prototype);\n" %(type, base_type)
			code += "\texports.%s.prototype.constructor = exports.%s;\n" %(type, type)
			r.append(code)

		return "\n".join(r)

	def generate_imports(self):
		r = []
		for name, code in self.imports.iteritems():
			code = "//=====[import %s]=====================\n\n" %name + code
			r.append("'%s': %s()" %(name, self.wrap(code)))
		return ", ".join(r)

	def generate(self, ns):
		text = ""
		text += "var _globals = exports;\n"
		text += "var imports = { %s };\n" %self.generate_imports()
		text += "//========================================\n\n"
		text += "var core = imports['core/core.js'];\n"
		text += "%s\n" %self.generate_components()
		text += "_globals._context = new core.Context();\n"
		return "%s = %s();\n" %(ns, self.wrap(text))

	def generate_startup(self):
		return "\n".join(self.startup)
