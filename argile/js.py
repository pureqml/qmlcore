#!/usr/bin/env python

import lang

class component_generator(object):
	def __init__(self, component):
		self.properties = {}
		self.component = component

	def add_child(self, child):
		if type(child) is lang.Property:
			if child.name in self.properties:
				raise Exception("duplicate property " + child.name)
			self.properties[child.name] = (child.type, child.value)
		else:
			print "unhandled", child

	def generate_properties(self):
		r = []
		for name, property in self.properties.iteritems():
			r.append("this.%s = Property(value);" %(name));
		return "\n".join(r)

	def generate(self):
		return "function() {\n%s\n}" %self.generate_properties()

class generator(object):
	def __init__(self):
		self.components = {}
		self.imports = {}

	def add_component(self, name, component):
		if name in self.components:
			raise Exception("duplicate component " + name)

		gen = component_generator(component)
		self.components[name] = gen
		for child in component.children:
			gen.add_child(child)

	def add_js(self, name, data):
		if name in self.imports:
			raise Exception("duplicate js name " + name)
		self.imports[name] = data

	def add_components(self, name, components):
		for component in components:
			self.add_component(name, component)

	def wrap(self, code):
		return "(function() {\nvar exports = {};\n%s\nreturn exports;\n} )" %code

	def generate_components(self):
		r = []
		created = set()
		for name in self.components.iterkeys():
			path = name.split(".")[:-1]
			for i in xrange(len(path)):
				subpath = ".".join(path[0 : i + 1])
				if subpath in created:
					continue
				created.add(subpath)
				r.append("if (!exports.%s) exports.%s = {};" %(subpath, subpath))

		for name, gen in self.components.iteritems():
			code = "//=====[component %s]=====================\n\n" %name
			code += "exports.%s = %s" %(name, gen.generate())
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
		text += "var imports = { %s };\n" %self.generate_imports()
		text += "%s\n" %self.generate_components()
		return "%s = %s();\n" %(ns, self.wrap(text))
