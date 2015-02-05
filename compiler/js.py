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
		self.package = get_package(name)
		self.base_type = None
		for child in component.children:
			self.add_child(child)

	def assign(self, target, value):
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
		else:
			print "unhandled", child

	def generate_properties(self):
		r = []
		for name, type in self.properties.iteritems():
			r.append("\tcore.add_property(this, '%s', '%s');" %(type, name))
		return "\n".join(r)

	def generate_ctor(self):
		return "\texports.%s.%s.call(this);" %(self.package, self.component.name)

	def generate(self, registry):
		base_type = registry.find_component(self.package, self.component.name)
		code = "";
		code += "\texports.%s = function() {\n%s\n%s\n}\n" %(self.name, self.generate_ctor(), self.generate_properties())
		code += "\texports.%s.prototype = Object.create(exports.%s.prototype);\n" %(self.name, base_type)
		code += "\texports.%s.prototype.constructor = exports.%s;\n" %(self.name, self.name)
		return code

class generator(object):
	def __init__(self):
		self.components = {}
		self.imports = {}
		self.packages = {}

	def add_component(self, name, component, declaration):
		if name in self.components:
			raise Exception("duplicate component " + name)

		package, component_name = split_name(name)

		if not declaration:
			name += ".Ui%s" %(component_name[0].upper() + component_name[1:])

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
		for package, components in self.packages.iteritems():
			if name in components:
				return "%s.%s" %(package, name)
		raise Exception("component %s was not found" %name)

	def generate_components(self):
		r = []
		for package in sorted(self.packages.keys()):
			r.append("if (!exports.%s) exports.%s = {};" %(package, package))

		for name, gen in self.components.iteritems():
			code = "//=====[component %s]=====================\n\n" %name
			code += gen.generate(self)
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
		return "%s = %s();\n" %(ns, self.wrap(text))
