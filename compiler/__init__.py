import compiler.doc.json
import compiler.pyparsing
import compiler.grammar
import compiler.manifest
from compiler.manifest import merge_properties
import compiler.js
import compiler.lang
import os, os.path
import hashlib
import cPickle
import json
from multiprocessing import Pool, cpu_count
import sys

compiler.grammar.source.parseWithTabs()

try:
	import inspect
	data = ""
	data += inspect.getsource(compiler.grammar)
	data += inspect.getsource(compiler.lang)
	data += inspect.getsource(compiler.pyparsing)
	grammar_digest = hashlib.sha1(data).hexdigest()
	del data
except:
	grammar_digest = '0000000000000000000000000000000000000000'

class Cache(object):
	def __init__(self, dir = '.cache'):
		self.dir = dir
		try:
			os.mkdir(dir)
		except:
			pass

	def read(self, name, hashkey):
		cached_path = os.path.join(self.dir, name)
		try:
			with open(cached_path) as f:
				if f.readline().strip() != hashkey:
					raise Exception("invalid hash")
				return cPickle.load(f)
		except:
			return

	def write(self, name, hashkey, data):
		cached_path = os.path.join(self.dir, name)
		with open(cached_path, "w") as f:
			f.write(hashkey + "\n")
			cPickle.dump(data, f)

def parse_qml_file(cache, com, path):
	with open(path) as f:
		data = f.read()
		h = hashlib.sha1(grammar_digest + data).hexdigest()

	cached = cache.read(com, h)
	if cached:
		return cached, data
	else:
		print "parsing", path, "...", com
		try:
			tree = compiler.grammar.parse(data)
			cache.write(com, h, tree)
			return tree, data
		except Exception as ex:
			ex.filename = path
			raise

class Compiler(object):
	def process_file(self, pool, generator, package, dirpath, filename):
		name, ext = os.path.splitext(filename)
		if name[0] == '.':
			return

		com = "%s.%s" %(package, name)
		path = os.path.join(dirpath, filename)
		if ext == ".qml":
			if name[0].islower():
				if self.app != name:
					#print "skipping", name
					return

			if pool is not None:
				return (com, name[0].isupper(), pool.apply_async(parse_qml_file, (self.cache, com, path)))
			else:
				tree, data = parse_qml_file(self.cache, com, path)
				self.finalize_qml_file(generator, com, name[0].isupper(), tree, data)
		elif ext == ".js":
			with open(path) as f:
				data = f.read()
			if self.verbose:
				print "including js file...", path
			generator.add_js(com, data)
		elif ext == '.ts':
			generator.add_ts(path)

	def finalize_qml_file(self, generator, name, is_component, tree, text):
		assert len(tree) == 1
		if self.documentation and is_component:
			self.documentation.add(name, tree[0])
		generator.add_component(name, tree[0], is_component)
		generator.scan_using(text)

	def process_files(self, pool, generator):
		promises = []
		root_manifest = self.root_manifest

		for project_dir in self.project_dirs:
			path = project_dir.split(os.path.sep)
			package_dir = project_dir
			package_name = path[-1]
			if root_manifest and root_manifest.package and len(path) <= 1: #root component
				package_name = str(root_manifest.package)

			for dirpath, dirnames, filenames in os.walk(project_dir, topdown = True):
				dirnames[:] = filter(lambda name: not name[:6].startswith("build.") and name != "dist", dirnames)
				if '.nocompile' in filenames:
					dirnames[:] = []
					continue

				if '.manifest' in filenames:
					with open(os.path.join(dirpath, '.manifest')) as f:
						manifest = compiler.manifest.load(f)
						if manifest.package:
							package_name = manifest.package.encode('utf-8')
							package_dir = dirpath
						if manifest.export_module:
							generator.module |= manifest.export_module
						if not manifest.strict:
							self.strict = False
						merge_properties(self.root_manifest_props, manifest.properties)

				for filename in filenames:
					relpath = os.path.relpath(dirpath, package_dir)
					if relpath.startswith('..'):
						#files in current dir, reset to initial state
						package_dir = project_dir
						package_name = project_dir.split(os.path.sep)[-1]
						relpath = os.path.relpath(dirpath, package_dir)

					if relpath == '.':
						relpath = []
					else:
						relpath = relpath.split(os.path.sep)

					package = ".".join([package_name] + relpath)
					self.component_path_map[filename] = dirpath
					promise = self.process_file(pool, generator, package, dirpath, filename)
					if promise is not None:
						promises.append(promise)

		for name, is_component, promise in promises:
			self.finalize_qml_file(generator, name, is_component, *promise.get())

	def generate(self):
		namespace = "qml"
		partner = self.root_manifest.partner
		if partner not in self.partners:
			raise parser.error('\n\nInvalid client id \'%s\'. Consider become our partner! You will be advertised on our site (and change splash screen lol).\n\n*** WARNING: Using counterfeit id is a hanging offense, you will be reported to KGB immediately. ***\n' %partner)
		generator = compiler.js.generator(namespace, 'Powered by PureQML ' + self.partners.get(partner).get('engine') + ' Edition Engine')

		self.root_manifest_props = {}
	#reading .core.js files to bootstrap platform specific initialization
		init_js = ''
		for project_dir in self.project_dirs:
			init_path = os.path.join(project_dir, '.core.js')
			if os.path.exists(init_path):
				if self.verbose:
					print 'including platform initialisation file at %s' %init_path
				with open(init_path) as f:
					init_js += f.read()

		init_js = generator.replace_args(init_js)

		def init_worker():
			import signal
			signal.signal(signal.SIGINT, signal.SIG_IGN)

		if self.jobs != 1:
			try:
				pool = Pool(self.jobs, init_worker)
				self.process_files(pool, generator)
			except KeyboardInterrupt:
				pool.terminate()
				pool.join()
				sys.exit(1)
			else:
				pool.close()
				pool.join()
		else:
			self.process_files(None, generator)

		merge_properties(self.root_manifest_props, self.root_manifest.properties)

		if self.verbose:
			print "generating sources..."

		appcode = ""
		if self.strict:
			appcode += "'use strict'\n"
		if self.release:
			appcode += "var log = function() { }\n"
		else:
			appcode += "var log = null\n"

		def write_properties(prefix, props):
			r = ''
			for k, v in sorted(props.iteritems()):
				k = compiler.js.escape_id(k)
				if isinstance(v, dict):
					r += write_properties(prefix + '$' + k, v)
				else:
					r += "var %s$%s = %s\n" %(prefix, k, json.dumps(v))
			return r
		appcode += write_properties('$manifest', self.root_manifest_props).encode('utf-8')

		appcode += "/** @const @type {!CoreObject} */\n"
		appcode += "var " + generator.generate()
		appcode += generator.generate_startup(namespace, self.app)
		appcode = appcode.replace('/* ${init.js} */', init_js)

		with open(os.path.join(self.output_dir, namespace + "." + self.app + ".js"), "wt") as f:
			f.write(appcode.encode('utf-8'))

		if self.documentation:
			self.documentation.generate(self.component_path_map)

		print "done"

	def __init__(self, output_dir, root, project_dirs, root_manifest, app, doc = None, release = False, verbose = False, jobs = 1):
		self.cache = Cache()
		self.root = root
		self.output_dir = output_dir
		self.project_dirs = project_dirs
		self.root_manifest = root_manifest
		self.app = app
		self.documentation = None
		self.strict = root_manifest.strict
		self.release = release
		self.verbose = verbose
		self.jobs = int(jobs) if jobs is not None else cpu_count()
		self.component_path_map = {}

		if self.verbose:
			print 'running using %d jobs' %self.jobs

		with open(os.path.join(root, 'partners.json')) as f:
			self.partners = json.load(f)

		self.documentation = compiler.doc.json.Documentation(doc) if doc else None


def compile_qml(output_dir, root, project_dirs, root_manifest, app, wait = False, doc = None, release = False, verbose = False, jobs = 1):
	if wait:
		try:
			import pyinotify

			class EventHandler(pyinotify.ProcessEvent):
				def __init__(self):
					self.modified = False

				def check_file(self, filename):
					if not filename or filename[0] == '.':
						return False
					root, ext = os.path.splitext(filename)
					return ext in set([".qml", ".js"])

				def check_event(self, event):
					if self.check_file(event.name):
						self.modified = True

				def process_IN_MODIFY(self, event):
					self.check_event(event)
				def process_IN_CREATE(self, event):
					self.check_event(event)
				def process_IN_DELETE(self, event):
					self.check_event(event)

				def pop(self):
					r = self.modified
					self.modified = False
					return r
		except:
			raise Exception("seems that you don't have pyinotify module installed, you can't use -w without it")

	c = Compiler(output_dir, root, project_dirs, root_manifest, app, doc=doc, release=release, verbose=verbose, jobs=jobs)

	notifier = None

	if wait:
		from pyinotify import WatchManager
		wm = WatchManager()
		mask = pyinotify.IN_MODIFY | pyinotify.IN_CREATE | pyinotify.IN_DELETE
		for dir in project_dirs:
			wm.add_watch(dir, mask)

		event_handler = EventHandler()
		notifier = pyinotify.Notifier(wm, event_handler)

	while True:
		try:
			c.generate()
		except Exception as ex:
			if not wait:
				if hasattr(ex, 'filename'):
					if hasattr(ex, 'lineno'):
						loc = '%s:%d:%d: ' %(ex.filename, ex.lineno, ex.col)
					else:
						loc = '%s: ' %ex.filename
				else:
					loc = ''
				msg = '%serror: %s' %(loc, ex)
				if hasattr(ex, 'line'):
					msg += '\n' + ex.line
				print msg
				if verbose:
					raise
				sys.exit(1)

			import time, traceback
			traceback.print_exc()
			time.sleep(1)
			continue

		if not wait:
			break

		while True:
			if notifier.check_events():
				notifier.read_events()
				notifier.process_events()
				modified = event_handler.pop()
				if not modified:
					continue
				else:
					break
