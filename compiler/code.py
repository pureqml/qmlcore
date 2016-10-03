import re

def scan(text):
	str_context = False
	escape = False
	c_comment = False
	cpp_comment = False
	begin = 0
	invalid = []
	for i in xrange(0, len(text)):
		c = text[i]
		if escape:
			escape = False
			continue

		if cpp_comment:
			if c == "\n":
				cpp_comment = False
				end = i
				invalid.append((begin, end))
				#print "cpp-comment", (begin, end), text[begin:end]
			continue

		if c_comment:
			if text[i: i + 2] == "*/":
				end = i + 2
				c_comment = False
				invalid.append((begin, end))
				#print "c-comment", begin, end, text[begin:end]
			continue

		if str_context and c == "\\":
			escape = True
			continue

		if c == "\"" or c == "'":
			str_context = not str_context
			if str_context:
				begin = i
			else:
				end = i + 1
				invalid.append((begin, end))
				#print "string at %d:%d -> %s" %(begin, end, text[begin:end])
			continue

		if str_context:
			continue

		if text[i: i + 2] == "//":
			begin = i
			cpp_comment = True

		if text[i: i + 2] == "/*":
			c_comment = True
			begin = i


	return text, invalid

enum_re = re.compile(r'([A-Z]\w*)\.([A-Z]\w*)')
def replace_enums(text, generator, registry):
	def replace_enum(m):
		component = registry.find_component(generator.package, m.group(1))
		return "_globals.%s.prototype.%s" %(component, m.group(2))

	text = enum_re.sub(replace_enum, text)
	#print text
	return text


id_re = re.compile(r'([_a-z]\w*)\.')
def process(text, generator, registry):
	id_set = registry.id_set
	text, invalid = scan(text)
	def replace_id(m):
		pos = m.start(0)
		name = m.group(1)
		first = text[pos - 1] != "."
		if name in id_set:
			ok = True
			for b, e in invalid:
				if pos >= b and pos < e:
					ok = False
					break
			return ("this." if first else "") + "_get('%s')." %name
		return m.group(0)

	text = id_re.sub(replace_id, text)
	text = replace_enums(text, generator, registry)
	#print text
	return text

gets_re = re.compile(r'this(\._get\(\'.*?\'\))+')
tr_re = re.compile(r'\W(qsTr|qsTranslate|tr)\(')

def parse_deps(text):
	deps = []
	for m in gets_re.finditer(text):
		gets = m.group(0).split('.')
		target = gets[-1]
		target = target[target.index('\'') + 1:target.rindex('\'')]
		gets = gets[:-1]
		deps.append((".".join(gets), target))
	for m in tr_re.finditer(text):
		deps.append(('this._context', 'language'))
	return deps

def mangle_path(path):
	return ["this"] + ["_get('%s')"%name for name in path ]

def generate_accessors(target):
	path = target.split('.')
	get = ".".join(mangle_path(path[:-1]))
	return get, path[-1]
