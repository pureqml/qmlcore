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

gets_re = re.compile(r'(this)((?:\._get\(\'.*?\'\))+)(?:\.([a-zA-Z0-9\.]+))?')
tr_re = re.compile(r'\W(qsTr|qsTranslate|tr)\(')

def parse_deps(parent, text):
	deps = set()
	for m in gets_re.finditer(text):
		gets = (m.group(1) + m.group(2)).split('.')
		gets = map(lambda x: parent if x == 'this' else x, gets)
		#refactor this mess, remove _get from IL
		target = gets[-1]
		target = target[target.index('\'') + 1:target.rindex('\'')]
		gets = gets[:-1]
		if target == 'model' and len(gets) == 1:
			signal = '_row' if m.group(3) != 'index' else '_rowIndex'
			deps.add(("%s._get('_delegate')" %parent, signal))
		else:
			path = ".".join(gets)
			deps.add((path, target))

	for m in tr_re.finditer(text):
		deps.add((parent + '._context', 'language'))
	return deps

def mangle_path(path):
	return ["this"] + ["_get('%s')"%name for name in path ]

def generate_accessors(target):
	path = target.split('.')
	get = ".".join(mangle_path(path[:-1]))
	return get, path[-1]
