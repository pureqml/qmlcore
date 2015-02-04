#!/usr/bin/env python

class generator(object):
	def __init__(self):
		self.components = {}

	def add_component(self, name, component):
		if name in self.components:
			raise Exception("duplicate component " + name)
		self.components[name] = component

	def add_js(self, name, data):
		print name, data

	def add_components(self, name, components):
		for component in components:
			self.add_component(name, component)

	def generate(self, ns):
		text = ""
		return "%s = (function() {\n%s\n} )();\n" %(ns, text)
