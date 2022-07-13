from collections import OrderedDict
import re

enum_re = re.compile(r'([A-Z]\w*)\.([A-Z]\w*)')
def get_enum_prologue(text, generator, registry):
	prologue = []
	found_comps = OrderedDict()
	for m in enum_re.finditer(text):
		found_comps[m.group(1)] = None
	for comp in found_comps.keys():
		try:
			component = registry.find_component(generator.package, comp)
			prologue.append("%s = _globals.%s.prototype" %(comp, component))
		except Exception as ex:
			pass
	return prologue

id_re = re.compile(r'(\w+\s*)(\.\s*\w+\s*)*', re.I | re.M)
def process(text, generator, registry, args):
	args = set(args)
	id_set = registry.id_set
	used_ids = OrderedDict()
	for m in id_re.finditer(text):
		found = m.group(1)
		if found in id_set and found not in args:
			used_ids[found] = None

	scope_pos = text.index('{') #raise exception, should be 0 actually
	scope_pos += 1
	prologue = []
	if used_ids:
		prologue += ["%s = this._get('%s', true)" %(x, x) for x in used_ids.keys()]

	prologue += get_enum_prologue(text, generator, registry)

	if prologue:
		prologue = '\n\tvar ' + ', '.join(prologue) + '\n'
		text = text[:scope_pos] + prologue + text[scope_pos:]

	#print text
	return text

def mangle_path(path, transform, lookup_parent=False):
	path = [transform(path[0], lookup_parent=lookup_parent)] + path[1:]
	return '.'.join(path)

def path_or_parent(path, parent, transform):
	if path == 'parent':
		return '%s.parent' %parent
	return mangle_path(path.split('.'), transform) if path else parent

gets_re = re.compile(r'\${(.*?)}')
tr_re = re.compile(r'\W(qsTr|qsTranslate|tr)\(')

def parse_deps(parent, text, transform):
	deps = OrderedDict()

	for m in tr_re.finditer(text):
		deps[(parent + '._context', 'language')] = None
		break

	def sub(m):
		path = m.group(1).split('.')
		target = path[-1]
		gets = path[:-1]

		#if the path is only a single component, try hierarchical scoping
		if len(path) == 1 and path[0] != 'model' and path[0] != 'modelData':
			tpath = mangle_path(path, transform, lookup_parent=True)
			tpath_v = tpath.split('.')
			if target != 'parent':
				tdep = parent + "." + '.'.join(tpath_v[:-1]) if len(tpath_v)>1 else parent
				deps[(tdep, target)] = None
			return parent + '.' + tpath

		if len(path) > 1 and path[0] == 'manifest':
			return '$' + '$'.join(path)
		if len(path) > 1 and (path[0] == 'model' or path[0] == 'modelData'):
			signal = '_row' if path[1] != 'index' else '_rowIndex'
			deps[("%s._get('_delegate')" %parent, signal)] = None
		else:
			if len(path) > 1 and path[0] == 'this':
				return '.'.join([parent] + path[1:])
			dep_parent = parent + '.' + mangle_path(gets, transform) if gets else parent
			if target != 'parent': #parent property is special - it's not property per se, and is not allowed to change
				deps[(dep_parent, target)] = None

		return parent + '.' + mangle_path(path, transform)

	text = gets_re.sub(sub, text)
	return text, deps.keys()

def generate_accessors(parent, target, transform):
	path = target.split('.')
	get = parent + '.' + mangle_path(path[:-1], transform) if path[:-1] else parent
	return get, path[-1]
