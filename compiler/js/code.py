import re

enum_re = re.compile(r'([A-Z]\w*)\.([A-Z]\w*)')
def replace_enums(text, generator, registry):
	def replace_enum(m):
		try:
			component = registry.find_component(generator.package, m.group(1))
			return "_globals.%s.prototype.%s" %(component, m.group(2))
		except:
			return m.group(0)

	text = enum_re.sub(replace_enum, text)
	#print text
	return text


id_re = re.compile(r'(\w+\s*)(\.\s*\w+\s*)*', re.I | re.M)
def process(text, generator, registry, args):
	args = set(args)
	id_set = registry.id_set
	used_ids = set()
	for m in id_re.finditer(text):
		found = m.group(1)
		if found in id_set and found not in args:
			used_ids.add(found)

	if used_ids:
		scope_pos = text.index('{') #raise exception, should be 0 actually
		scope_pos += 1
		prologue = ["%s = this._get('%s', true)" %(x, x) for x in used_ids]
		prologue = '\n\tvar ' + ', '.join(prologue) + '\n'
		text = text[:scope_pos] + prologue + text[scope_pos:]

	text = replace_enums(text, generator, registry)
	#print text
	return text

def mangle_path(path, transform):
	path = [transform(path[0])] + path[1:]
	return '.'.join(path)

def path_or_parent(path, parent, transform):
	return mangle_path(path.split('.'), transform) if path else parent

gets_re = re.compile(r'\${(.*?)}')
tr_re = re.compile(r'\W(qsTr|qsTranslate|tr)\(')

def parse_deps(parent, text, transform):
	deps = set()

	for m in tr_re.finditer(text):
		deps.add((parent + '._context', 'language'))

	def sub(m):
		path = m.group(1).split('.')
		target = path[-1]
		gets = path[:-1]
		if len(path) > 1 and path[0] == 'manifest':
			return '$' + '$'.join(path)
		if len(path) > 1 and path[0] == 'model':
			signal = '_row' if path[1] != 'index' else '_rowIndex'
			deps.add(("%s._get('_delegate')" %parent, signal))
		else:
			dep_parent = parent + '.' + mangle_path(gets, transform) if gets else parent
			if target != 'parent': #parent property is special - it's not property per se, and is not allowed to change
				deps.add((dep_parent, target))

		return parent + '.' + mangle_path(path, transform)

	text = gets_re.sub(sub, text)
	return text, deps

def generate_accessors(parent, target, transform):
	path = target.split('.')
	get = parent + '.' + mangle_path(path[:-1], transform) if path[:-1] else parent
	return get, path[-1]
