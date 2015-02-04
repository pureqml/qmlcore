#!/usr/bin/env python

class generator(object):
	def add_components(self, name, components):
		for component in components:
			self.add_component(name, component)

	def add_component(self, name, component):
		print name, component

	def add_js(self, name, data):
		print name, data

	def generate(self, ns):
		text = ""
		return "%s = (function() {\n%s\n} )();\n" %(ns, text)
