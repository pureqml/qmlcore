import os
import os.path

class Documentation(object):
	def __init__(self, root):
		self.root = root
		self.packages = {}

	def add(self, name, component):
		package, name = self.split_name(name)
		components = self.packages.setdefault(package, {})
		components[name] = component

	def split_name(self, name):
		idx = name.rfind('.')
		return name[:idx], name[idx + 1:]

	def generate_component(self, package, name, component):
		#print package, name, component
		pass

	def generate_package(self, package, components):
		path = os.path.join(self.root, package)
		if not os.path.exists(path):
			os.mkdir(path)
		for name, component in components.iteritems():
			self.generate_component(package, name, component)

	def generate(self):
		if not os.path.exists(self.root):
			os.mkdir(self.root)
		for name, components in self.packages.iteritems():
			self.generate_package(name, components)
