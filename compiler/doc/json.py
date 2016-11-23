import os
import os.path
import compiler.lang as lang

class Component(object):
	def __init__(self, package, name, component):
		self.package = package
		self.name = name
		self.component = component

	def generate_section(self, r, type, title, data, comma):
		if type not in data:
			return

		values = data[type]
		r.append('\t\t"%s": {' %title)
		for value in values[:-1]:
			if value.doc is not None:
				r.append('\t\t\t"%s": "%s",' %(value.name, value.doc.text))
			else:
				r.append('\t\t\t"%s": "",' %value.name)

		last = values[-1]
		if last.doc is not None:
			r.append('\t\t\t"%s": "%s"' %(last.name, last.doc.text))
		else:
			r.append('\t\t\t"%s": ""' %last.name)

		if comma:
			r.append('\t\t},')
			r.append('')
		else:
			r.append('\t\t}')

	def process_children(self, r):
		component = self.component

		children = {}

		for child in component.children:
			category = child.__class__.__name__
			values = children.setdefault(category, [])
			values.append(child)

		self.generate_section(r, 'Property', 'Properties', children, True)
		self.generate_section(r, 'AliasProperty', 'Alias Properties', children, True)
		self.generate_section(r, 'Signal', 'Signals', children, True)
		self.generate_section(r, 'Method', 'Methods', children, False)
		return r

	def document(self, r, component):
		print component.name, component.doc
		if component.doc:
			r.append(component.doc)

	def generate(self, documentation):
		r = []
		package, name = self.package, self.name
		r.append('{' )
		r.append('\t"name": "%s.%s",' %(package, name))
		r.append('')
		r.append('\t"content": {')
		self.process_children(r)
		r.append('\t}')
		r.append('}')
		return '\n'.join(r)

class Documentation(object):
	def __init__(self, root):
		self.root = root
		self.jsonroot = os.path.join(root, 'json')
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
		with open(os.path.join(self.jsonroot, package, name + '.json'), 'wt') as f:
			f.write(component.generate(self))

	def generate(self):
		if not os.path.exists(self.jsonroot):
			os.makedirs(self.jsonroot)

		with open(os.path.join(self.root, '.nocompile'), 'wt') as f:
			pass

		toc = []

		toc.append('{')
		toc.append('\t"site_name": "QML Documentation",')
		toc.append('\t"use_directory_urls": false,')
		toc.append('\t"docs_dir": ".",')
		toc.append('\t"site_dir": "../html",')
		toc.append('\t"repo_url": "https://github.com/pureqml/qmlcore/",')

		toc.append('\t"pages": {')

		pack = sorted(self.packages.iteritems())
		lastPack = pack[-1][0]
		for package, components in pack:
			toc.append('\t\t"%s": {' %package)
			toc.append('\t\t\t"file": "%s.json",' %package)
			toc.append('\t\t\t"content": {')

			package_toc = ['{']
			package_toc.append('\t"%s": {' %package)
			path = os.path.join(self.jsonroot, package)
			if not os.path.exists(path):
				os.mkdir(path)

			lastComp = components.keys()[-1]
			for name, component in components.iteritems():
				comma = "" if lastComp == name else ","
				package_toc.append('\t\t"%s": "%s/%s.json"%s' %(name, package, name, comma))
				toc.append('\t\t\t\t"%s": "%s/%s.json"%s' %(name, package, name, comma))
				self.generate_component(package, name, component)
			package_toc.append('\t}')
			toc.append('\t\t\t}')

			with open(os.path.join(self.jsonroot, package + '.json'), 'wt') as f:
				f.write('\n'.join(package_toc))
                                f.write('\n}\n')

			comma = "" if lastPack == package else ","
			toc.append('\t\t}%s' %comma)

		toc.append('\t}')
		toc.append('}')

		with open(os.path.join(self.jsonroot, 'mkdocs.json'), 'wt') as f:
			f.write('\n'.join(toc))
