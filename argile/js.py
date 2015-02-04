#!/usr/bin/env python

class generator(object):
	def __init__(self):
		self.components = {}
		self.imports = {}

	def add_component(self, name, component):
		if name in self.components:
			raise Exception("duplicate component " + name)

		self.components[name] = component
		for child in component.children:
			print child

	def add_js(self, name, data):
		if name in self.imports:
			raise Exception("duplicate js name " + name)
		self.imports[name] = data

	def add_components(self, name, components):
		for component in components:
			self.add_component(name, component)

	def wrap(self, code):
		return "(function() {\n%s\n} )" %code

	def generate_imports(self):
		r = []
		for name, code in self.imports.iteritems():
			r.append("'%s': %s()" %(name, self.wrap(code)))
		return ",".join(r)

	def generate(self, ns):
		text = "var imports = { %s };" %self.generate_imports()
		return "%s = %s();\n" %(ns, self.wrap(text))
