import os
import os.path

class Component(object):
	def __init__(self, package, name, component):
		self.package = package
		self.name = name
		self.component = component

	def generate(self, documentation):
		r = []
		package, name = self.package, self.name
		r.append('#%s.%s' %(package, name))
		return '\n'.join(r)

class Documentation(object):
	def __init__(self, root):
		self.root = root
		self.packages = {}

	def add(self, name, component):
		package, name = self.split_name(name)
		components = self.packages.setdefault(package, {})
		components[name] = Component(package, name, component)

	def split_name(self, name):
		idx = name.rfind('.')
		return name[:idx], name[idx + 1:]

	def generate_component(self, package, name, component):
		#print package, name, component
		with open(os.path.join(self.root, package, name + '.md'), 'wt') as f:
			f.write(component.generate(self))

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
