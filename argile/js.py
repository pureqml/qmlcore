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
		return ";\n".join(r)

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
		for name, gen in self.components.iteritems():
			r.append("'%s': %s" %(name, gen.generate()))
		return ", ".join(r)

	def generate_imports(self):
		r = []
		for name, code in self.imports.iteritems():
			r.append("'%s': %s()" %(name, self.wrap(code)))
		return ", ".join(r)

	def generate(self, ns):
		text = ""
		text += "var imports = { %s };\n" %self.generate_imports()
		text += "var components = { %s };\n" %self.generate_components()
		text += "return imports['core/core.js'].context;\n"
		return "%s = %s();\n" %(ns, self.wrap(text))
