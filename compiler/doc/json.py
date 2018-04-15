import re
import os
import os.path


class Component(object):
	def __init__(self, package, name, component):
		self.package = package
		self.name = name
		self.component = component


	def generate_section(self, r, title, values, comma):
		if not hasattr(values[-1], "name"):
			return

		last = values[-1].name
		r.append('\t\t"%s": {' % title)

		for value in values:
			localComma = "" if last == value.name else ","
			docText = value.doc.text if value.doc is not None else ""
			docLines = docText.splitlines()
			docText = docText.replace("\n", " ")

			category = value.__class__.__name__

			forceInternal = category == 'Method' and (re.match("^on.*Changed$", value.name[0]) or \
													  value.name[0] == "onCompleted" or \
													  value.name[0] == "constructor")

			internal = bool(forceInternal) or ((value.doc is not None) and ("@private" in value.doc.text or "@internal" in value.doc.text))
			internal = str(internal).lower()

			ref = '"ref": "' + value.ref + '", ' if hasattr(value, 'ref') else ""

			if category == 'Property':
				r.append('\t\t\t"%s": { "text": "%s", %s"internal": %s, "type": "%s", "defaultValue": "%s" }%s' %
						 (value.name, docText, ref, internal, value.type, value.defaultValue, localComma))
			elif category == 'Method' and docText:
				argText = ""
				argText += '"params": ['
				paramCount = 0
				descriptionAtLastLine = True
				for line in docLines:
					m = re.match(r'^.*@param\s+(?P<b>{)?(?P<t1>\w+)(?(b)} |:)(?P<t2>\w+)(?(b)\s*-\s*|\s*)(?P<text>.*)$',
								 line.strip())
					if not m:
						continue
					descriptionAtLastLine = descriptionAtLastLine and not m.group('b')
					paramName, paramType = (m.group('t2'), m.group('t1')) if m.group('b') else (m.group('t1'), m.group('t2'))
					paramText = m.group('text').strip()

					argText += '{ "name": "' + paramName + '", "type": "' + paramType + '", "text": "' + paramText + '" }'
					argText += ", "
					paramCount += 1
				if paramCount > 0:
					argText = argText[0:-2]
				argText += "], "

				docText = (docLines[-1] if descriptionAtLastLine else docLines[0]).strip(' *').lstrip()
				r.append('\t\t\t"%s": { "text": "%s", %s"internal": %s }%s' %(value.name[0], docText, argText, internal, localComma))
			else:
				itemName = value.name if isinstance(value.name, basestring) else value.name[0]
				r.append('\t\t\t"%s": { "text": "%s", "internal": %s }%s' %(itemName, docText, internal, localComma))

		if comma:
			r.append('\t\t},')
			r.append('')
		else:
			r.append('\t\t}')


	def process_children(self, r, component_path_map):
		component = self.component

		children = {}

		for child in component.children:
			category = child.__class__.__name__

			if (category == "Assignment"):
				continue
			values = children.setdefault(category, [])
			if (category == "Property"):
				child.name = child.properties[0][0]
				if hasattr(child.properties[0][1], "children"):
					component_file_name = child.type + ".qml"
					if component_path_map.has_key(component_file_name):
						component_dir = component_path_map[component_file_name][2:]
						component_dir = component_dir.replace("/", ".")
						child.ref = component_dir + "/" + component_file_name[:-4]
					child.defaultValue = child.properties[0][1].name
				else:
					child.defaultValue = child.properties[0][1][1:-1] if child.properties[0][1] is not None else ""
					if child.defaultValue is not None and len(child.defaultValue) > 1:
						if child.defaultValue[0] == '"':
							child.defaultValue = child.defaultValue[1:]
						if child.defaultValue[-1] == '"':
							child.defaultValue = child.defaultValue[:-1]

			values.append(child)

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

		lastName = data[-1][0]
		for d in data:
			self.generate_section(r, d[1], children[d[0]], False if lastName == d[0] else True)

		return r

	def document(self, r, component):
		print component.name, component.doc
		if component.doc:
			r.append(component.doc)

	def generate(self, documentation, package, component_path_map):
		r = []
		package, name = self.package, self.name
		r.append('{' )
		r.append('\t"name": "%s.%s",' %(package, name))
		comp = self.component
		r.append('\t"text": "%s",' %(comp.doc.text.replace("\n", " ") if hasattr(comp, "doc") and hasattr(comp.doc, "text") else ""))
		r.append('')
		r.append('\t"content": {')
		self.process_children(r, component_path_map)
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
			f.write(component.generate(self, package, self.component_path_map))

	def generate(self, component_path_map):
		self.component_path_map = component_path_map

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

				self.add(name, component)
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
