import os
import os.path
import compiler.lang as lang

class Component(object):
	def __init__(self, package, name, component):
		self.package = package
		self.name = name
		self.component = component

	def generate_section(self, r, type, title, data):
		if type not in data:
			return

		values = data[type]
		r.append('## %s' %title)
		r.append('')
		for value in values:
			r.append('### %s' %value.name)
			if value.doc is not None:
				r.append(value.doc.text)
				r.append('')

		r.append('')

	def process_children(self, r):
		component = self.component

		children = {}

		for child in component.children:
			category = child.__class__.__name__
			values = children.setdefault(category, [])
			values.append(child)

		self.generate_section(r, 'Property', 'Properties', children)
		self.generate_section(r, 'AliasProperty', 'Alias Properties', children)
		self.generate_section(r, 'Method', 'Methods', children)
		return r

	def document(self, r, component):
		print component.name, component.doc
		if component.doc:
			r.append(component.doc)

	def generate(self, documentation):
		r = []
		package, name = self.package, self.name
		r.append('# %s.%s Component' %(package, name))
		r.append('')
		self.process_children(r)
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

	def generate(self):
		if not os.path.exists(self.root):
			os.mkdir(self.root)

		with open(os.path.join(self.root, '.nocompile'), 'wt') as f:
			pass

		toc = []

		toc.append('site_name: QML Documentation')
		toc.append('use_directory_urls: false')
		toc.append('docs_dir: .')
		toc.append('site_dir: html')
		toc.append('repo_url: https://github.com/pureqml/qmlcore/')

		toc.append('pages:')

		for package, components in sorted(self.packages.iteritems()):
			toc.append("- '%s': '%s.md'" %(package, package))

			package_toc = []
			path = os.path.join(self.root, package)
			if not os.path.exists(path):
				os.mkdir(path)

			for name, component in components.iteritems():
				package_toc.append('- [%s.%s](%s/%s.md)' %(package, name, package, name))
				toc.append("- '%s.%s': '%s/%s.md'" %(package, name, package, name))
				self.generate_component(package, name, component)

			with open(os.path.join(self.root, package + '.md'), 'wt') as f:
				f.write('\n'.join(package_toc))

		with open(os.path.join(self.root, 'mkdocs.yml'), 'wt') as f:
			f.write('\n'.join(toc))
