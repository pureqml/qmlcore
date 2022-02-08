from __future__ import print_function, absolute_import
from builtins import object, str
from past.builtins import basestring

import json
import re
import os
import os.path

class Value(object):
	def __init__(self, object):
		self.name = None
		self.ref = None
		self.defaultValue = None
		self.target = object

	@property
	def doc(self):
		return self.target.doc

class Component(object):
	def __init__(self, package, name, component):
		self.package = package
		self.name = name
		self.component = component


	def generate_section(self, values):
		if not values[-1].name:
			return

		r = {}

		for value in values:
			docText = value.doc.text if value.doc is not None else ""
			docLines = docText.splitlines()

			category = value.target.__class__.__name__

			forceInternal = category == 'Method' and (re.match("^on.*Changed$", value.name[0]) or \
													  value.name[0] == "onCompleted" or \
													  value.name[0] == "constructor")

			internal = bool(forceInternal) or ((value.doc is not None) and ("@private" in value.doc.text or "@internal" in value.doc.text))

			if category == 'Property':
				p = { "text": docText, "internal": internal, "type": value.target.type, "defaultValue": value.defaultValue }
				if value.ref:
					p['ref'] = value.ref
				r[value.name] = p
			elif category == 'Method' and docText:
				params = []
				descriptionAtLastLine = True
				for line in docLines:
					m = re.match(r'^.*@param\s+(?P<b>{)?(?P<t1>\w+)(?(b)} |:)(?P<t2>\w+)(?(b)\s*-\s*|\s*)(?P<text>.*)$',
								 line)
					if not m:
						continue
					descriptionAtLastLine = descriptionAtLastLine and not m.group('b')
					paramName, paramType = (m.group('t2'), m.group('t1')) if m.group('b') else (m.group('t1'), m.group('t2'))
					paramText = m.group('text')

					params.append({ "name": paramName, "type": paramType, "text": paramText })

				docText = (docLines[-1] if descriptionAtLastLine else docLines[0]).strip(' *')
				m = { "text": docText, "internal": internal, "params": params }
				r[value.name[0]] = m
			else:
				itemName = value.name if isinstance(value.name, (str, basestring)) else value.name[0]
				r[itemName] = { "text": docText, "internal": internal }

		return r


	def process_children(self, component_path_map):
		component = self.component

		r = {}
		children = {}

		for child in component.children:
			category = child.__class__.__name__

			if (category == "Assignment"):
				continue
			values = children.setdefault(category, [])
			doc = Value(child)
			if (category == "Property"):
				doc.name = child.properties[0][0]
				if hasattr(child.properties[0][1], "children"):
					component_file_name = child.type + ".qml"
					if component_file_name in component_path_map:
						component_dir = component_path_map[component_file_name][2:]
						if component_dir.startswith("qmlcore/"):
							component_dir = component_dir[8:]
						component_dir = component_dir.replace("/", ".")
						doc.ref = component_dir + "/" + component_file_name[:-4]
					doc.defaultValue = child.properties[0][1].name
				else:
					doc.defaultValue = child.properties[0][1][1:-1] if child.properties[0][1] is not None else ""
					if doc.defaultValue is not None and len(doc.defaultValue) > 1:
						if doc.defaultValue[0] == '"':
							doc.defaultValue = doc.defaultValue[1:]
						if doc.defaultValue[-1] == '"':
							doc.defaultValue = doc.defaultValue[:-1]
			if hasattr(child, 'name'):
				doc.name = child.name

			values.append(doc)

		data = []
		if 'Property' in children:
			data.append(('Property', 'Properties'))

		if 'AliasProperty' in children:
			data.append(('AliasProperty', 'Alias Properties'))

		if 'Signal' in children:
			data.append(('Signal', 'Signals'))

		if 'Method' in children:
			data.append(('Method', 'Methods'))

		if len(data) == 0:
			return r

		for category, name in data:
			r[name] = self.generate_section(children[category])

		return r

	def document(self, r, component):
		if component.doc:
			r.append(component.doc)

	def generate(self, documentation, package, component_path_map):
		r = {}
		package, name = self.package, self.name
		r['name'] = '%s.%s' %(package, name)
		comp = self.component
		r['text'] = comp.doc.text if hasattr(comp, "doc") and hasattr(comp.doc, "text") else ""
		r['content'] = self.process_children(component_path_map)
		return r

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
			r = component.generate(self, package, self.component_path_map)
			#print(r)
			json.dump(r, f, sort_keys = True, indent=4)

	def generate(self, component_path_map):
		self.component_path_map = component_path_map

		if not os.path.exists(self.jsonroot):
			os.makedirs(self.jsonroot)

		with open(os.path.join(self.root, '.nocompile'), 'wt') as f:
			pass

		toc = {}

		toc["site_name"] = "QML Documentation"
		toc["use_directory_urls"] = False
		toc["docs_dir"] = "."
		toc["site_dir"] = "../html"
		toc["repo_url"] = "https://github.com/pureqml/qmlcore/"

		pages = {}
		toc["pages"] = pages

		pack = sorted(self.packages.items())
		for package, components in pack:
			p = {}
			pages[package] = p

			path = os.path.join(self.jsonroot, package)
			if not os.path.exists(path):
				os.mkdir(path)

			p["file"] = "%s.json" %package
			content = {}
			p["content"] = content

			package_toc = {}
			package_data = {}
			package_toc[package] = package_data

			for name, component in components.items():
				package_data[name] = "%s/%s.json" %(package, name)
				content[name] = "%s/%s.json" %(package, name)

				self.add(name, component)
				self.generate_component(package, name, component)

			with open(os.path.join(self.jsonroot, package + '.json'), 'wt') as f:
				json.dump(package_toc, f, sort_keys = True, indent=4)

		with open(os.path.join(self.jsonroot, 'mkdocs.json'), 'wt') as f:
			json.dump(toc, f, sort_keys=True, indent=4)
