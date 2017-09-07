import json
import re
from compiler.js import split_name, escape_package, get_package
from compiler.js.component import component_generator
from collections import OrderedDict

root_type = 'core.CoreObject'

class generator(object):
	def __init__(self, ns, bid):
		self.ns, self.bid = ns, bid
		self.components = {}
		self.used_packages = set()
		self.used_components = set()
		self.imports = OrderedDict()
		self.packages = {}
		self.startup = []
		self.l10n = {}
		self.id_set = set(['context', 'model'])

	def add_component(self, name, component, declaration):
		if name in self.components:
			raise Exception("duplicate component " + name)

		package, component_name = split_name(name)
		package = escape_package(package)

		if not declaration:
			name = "%s.Ui%s" %(package, component_name[0].upper() + component_name[1:])
			self.used_components.add(name)
			self.used_packages.add(package)
			self.startup.append("\tcontext.start(new qml.%s(context))" %name)
			self.startup.append("\tcontext.run()")
		else:
			name = package + '.' + component_name

		if package not in self.packages:
			self.packages[package] = set()
		self.packages[package].add(component_name)

		gen = component_generator(self.ns, name, component, True)
		self.components[name] = gen

	def add_js(self, name, data):
		if name in self.imports:
			raise Exception("duplicate js name " + name)
		self.imports[name] = data

	def wrap(self, code, use_globals = False):
		return "(function() {/** @const */\nvar exports = %s;\nexports._get = function(name) { return exports[name] }\n%s\nreturn exports;\n} )" %("_globals" if use_globals else "{}", code)

	def find_component(self, package, name, register_used = True):
		if name == "CoreObject":
			return root_type

		original_name = name
		name_package, name = split_name(name)

		if register_used and package in self.packages and name in self.packages[package]:
			self.used_components.add(package + '.' + name)
			return "%s.%s" %(package, name)

		candidates = []
		for package_name, components in self.packages.iteritems():
			if name in components:
				if name_package:
					#match package/subpackage
					if package_name != name_package and not package_name.endswith('.' + name_package):
						continue
				candidates.append(package_name)

		if not candidates:
			raise Exception("component %s was not found" %(original_name))

		if len(candidates) > 1:
			raise Exception("ambiguous component %s, you have to specify one of the packages explicitly: %s" \
				%(name, " ".join(map(lambda p: "%s.%s" %(p, name), candidates))))

		package_name = candidates[0]
		if register_used:
			self.used_components.add(package_name + '.' + name)
		return "%s.%s" %(package_name, name)

	def generate_component(self, gen):
		name = gen.name

		gen.collect_id(self.id_set)
		self.used_packages.add(gen.package)

		code = ''
		code += "\n\n//=====[component %s]=====================\n\n" %name
		code += gen.generate(self)

		code += gen.generate_prototype(self)
		return code

	used_re = re.compile(r'@using\s*{(.*?)}')

	def scan_using(self, code):
		for m in generator.used_re.finditer(code):
			name = m.group(1).strip()
			package, component_name = split_name(name)
			package = escape_package(package)
			self.used_components.add(name)
			self.used_packages.add(package)

	def generate_components(self):
		#finding explicit @using declarations in code
		for name, code in self.imports.iteritems():
			self.scan_using(code)

		context_type = self.find_component('core', 'Context')
		context_gen = self.components[context_type]
		for i, pi in enumerate(context_gen.properties):
			for j, nv in enumerate(pi.properties):
				if nv[0] == 'buildIdentifier':
					bid = '"' + self.bid + '"'
					pi.properties[j] = (nv[0], bid.encode('utf-8'))
					break

		generated = set([root_type])
		queue = ['core.Context']
		code, base_class = {}, {}

		for gen in self.components.itervalues():
			gen.pregenerate(self)

		while queue or self.used_components:
			for component in self.used_components:
				if component not in generated:
					queue.append(component)
			self.used_components = set()

			if queue:
				name = queue.pop(0)
				component = self.components[name]
				base_type = self.find_component(component.package, component.component.name)
				base_class[name] = base_type

				code[name] = self.generate_component(component)
				generated.add(name)

		r = ''
		order = []
		visited = set([root_type])
		def visit(type):
			if type in visited:
				return
			visit(base_class[type])
			order.append(type)
			visited.add(type)

		for type in base_class.iterkeys():
			visit(type)

		for type in order:
			r += code[type]

		return r

	def generate_prologue(self):
		for name in self.imports.iterkeys():
			self.used_packages.add(get_package(name))

		r = []
		packages = {}
		for package in sorted(self.used_packages):
			path = package.split(".")
			ns = packages
			for p in path:
				if p not in ns:
					ns[p] = {}
				ns = ns[p]

		path = "_globals"
		def check(path, packages):
			for ns in packages.iterkeys():
				if not ns:
					raise Exception('internal bug, empty name in packages')
				package = escape_package(path + "." + ns)
				r.append("if (!%s) /** @const */ %s = {}" %(package, package))
				check(package, packages[ns])
		check(path, packages)

		if 'core.core' in self.imports:
			r.append(self.generate_import('core.core', self.imports['core.core']))
		return '\n'.join(r)

	def generate_import(self, name, code):
		r = []
		safe_name = name
		if safe_name.endswith(".js"):
			safe_name = safe_name[:-3]
		safe_name = escape_package(safe_name.replace('/', '.'))
		code = "//=====[import %s]=====================\n\n" %name + code
		r.append("_globals.%s = %s()" %(safe_name, self.wrap(code, name == "core.core"))) #hack: core.core use _globals as its exports
		return "\n".join(r)


	def generate_imports(self):
		r = ''
		for name, code in self.imports.iteritems():
			if name != 'core.core':
				r += self.generate_import(name, code) + '\n'
		return r

	re_copy_args = re.compile(r'COPY_ARGS\w*\((.*?),(.*?)(?:,(.*?))?\)')

	def generate(self):
		code = self.generate_components() + '\n' #must be called first, generates used_packages/components sets
		text = ""
		text += "/** @const */\n"
		text += "var _globals = exports\n"
		text += "var __prototype$ctors = []\n"
		text += "%s\n" %self.generate_prologue()
		text += "//========================================\n\n"
		text += "/** @const @type {!CoreObject} */\n"
		text += "var core = _globals.core.core\n"
		text += code
		text += "%s\n" %self.generate_imports()

		text = "%s = %s();\n" %(self.ns, self.wrap(text))
		return self.replace_args(text)

	def replace_args(self, text):
		self.scan_using(text)
		#COPY_ARGS optimization
		def copy_args(m):
			def expr(var, op, idx):
				if idx != 0:
					return "%s %s %d" %(var, op, idx)
				else:
					return var

			name, idx, prefix = m.group(1).strip(), int(m.group(2).strip()), m.group(3)
			if prefix is not None:
				prefix = prefix.strip()
				return """
		/* %s */
		var $n = arguments.length
		var %s = new Array(%s)
		%s[0] = %s
		for(var $i = %d; $i < $n; ++$i) {
			%s[%s] = arguments[$i]
		}
""" %(m.group(0), name, expr('$n', '+', 1 - idx), name, prefix, idx, name, expr('$i', '+', 1 - idx)) #format does not work well here, because of { }
			else:
				return """
		/* %s */
		var $n = arguments.length
		var %s = new Array(%s)
		var $d = 0, $s = %d;
		while($s < $n) {
			%s[$d++] = arguments[$s++]
		}
""" %(m.group(0), name, expr('$n', '-', idx), idx, name)

		text = generator.re_copy_args.sub(copy_args, text)
		return text

	def generate_startup(self, ns, app, prefix):
		r = ""
		r += "try {\n"

		context_type = self.find_component('core', 'Context')

		startup = []
		startup.append('\tvar l10n = %s\n' %json.dumps(self.l10n))
		startup.append("\tvar context = %s._context = new qml.%s(null, false, {id: 'qml-context-%s', prefix: '%s', l10n: l10n})" %(ns, context_type, app, prefix))
		startup.append('\tvar closure = {}\n')
		startup.append('\tcontext.__create(closure)')
		startup.append('\tcontext.__setup(closure)')
		startup.append('\tclosure = undefined')
		startup.append('\tcontext.init()')
		startup += self.startup
		r += "\n".join(startup)
		r += "\n} catch(ex) { log(\"%s initialization failed: \", ex, ex.stack) }\n" %ns
		return r

	def add_ts(self, path):
		from compiler.ts import Ts
		ts = Ts(path)
		lang = ts.language
		if lang is None: #skip translation without target language (autogenerated base)
			print 'WARNING: no language in %s, translation ignored' %path
			return
		data = {}
		for ctx in ts:
			for msg in ctx:
				source, type, text = msg.source, msg.translation.type, msg.translation.text
				if type == 'just-obsoleted':
					texts = data.setdefault(source, {})
					texts[ctx.name] = text
		if data:
			self.l10n[lang] = data
