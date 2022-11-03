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

id_re = re.compile(r'(\w+)\s*(?:\.\s*\w+\s*)*', re.I | re.M)

def get_ids_candidates(text, registry, args):
	id_set = registry.id_set
	used_ids = OrderedDict()
	for m in id_re.finditer(text):
		found = m.group(1)
		if found in id_set and found not in args:
			used_ids[found] = None
	return list(used_ids.keys())

def get_ids_prologue(text, registry, args):
	candidates = get_ids_candidates(text, registry, args)
	return ["%s = this._get('%s', true)" %(x, x) for x in candidates]

def process(text, generator, registry, args):
	args = set(args)

	scope_pos = text.index('{') #raise exception, should be 0 actually
	scope_pos += 1

	prologue = get_ids_prologue(text, registry, args)
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
func_re = re.compile(r'\$\((.*?)\)')
tr_re = re.compile(r'\$\(qsTr|qsTranslate|tr\)\(')

class ParseDepsContext:
	def __init__(self, registry, component):
		self.registry = registry
		self.component = component

	def transform(self, path, lookup_parent = False):
		return self.component.transform_root(self.registry, None, path, lookup_parent=lookup_parent)

	def find_method(self, name):
		return self.component.find_method(self.registry, name)


def parse_deps(parent, text, parse_ctx):
	deps = OrderedDict()

	for _ in tr_re.finditer(text):
		deps[(parent + '._context', 'language')] = None
		break

	def sub(m):
		path = m.group(1).split('.')
		target = path[-1]
		gets = path[:-1]

		#if the path is only a single component, try hierarchical scoping
		if len(path) == 1 and path[0] != 'model' and path[0] != 'modelData':
			tpath = mangle_path(path, parse_ctx.transform, lookup_parent=True)
			tpath_v = tpath.split('.')
			if target != 'parent':
				if path[0] not in parse_ctx.registry.id_set:
					tdep = parent + "." + '.'.join(tpath_v[:-1]) if len(tpath_v)>1 else parent
					deps[(tdep, target)] = None
			return parent + '.' + tpath

		if path[0] == "window":
			return ".".join(path)
		if len(path) > 1 and path[0] == 'manifest':
			return '$' + '$'.join(path)
		if len(path) > 1 and (path[0] == 'model' or path[0] == 'modelData'):
			signal = '_row' if path[1] != 'index' else '_rowIndex'
			deps[("%s._get('_delegate')" %parent, signal)] = None
		else:
			if len(path) > 1 and path[0] == 'this':
				return '.'.join([parent] + path[1:])
			dep_parent = parent + '.' + mangle_path(gets, parse_ctx.transform) if gets else parent
			if target != 'parent': #parent property is special - it's not property per se, and is not allowed to change
				deps[(dep_parent, target)] = None

		return parent + '.' + mangle_path(path, parse_ctx.transform)

	possible_ids = get_ids_candidates(text, parse_ctx.registry, set())

	def func(m):
		path = m.group(1).split('.')
		target, path = path[0], path[1:]
		if target == 'this':
			target = parent
		elif target == 'parent':
			return ".".join([parent, "parent"] + path)

		# function does not have any qualifiers and found in current component/prototype.
		if not path and parse_ctx.find_method(target):
			return ".".join([parent, target])

		# replace possible id match with _get(id)
		if target in possible_ids:
			target = "%s._get('%s')" %(parent, target)

		return ".".join([target] + path)

	text = gets_re.sub(sub, text)
	text = func_re.sub(func, text)
	return text, deps.keys()

def generate_accessors(parent, target, transform):
	path = target.split('.')
	get = parent + '.' + mangle_path(path[:-1], transform) if path[:-1] else parent
	return get, path[-1]
