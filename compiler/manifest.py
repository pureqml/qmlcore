import json

def __pair_hook(pairs):
	obj = {}
	for k, v in pairs:
		if '.' in k:
			path = k.split('.')
			current = obj
			for p in path[:-1]:
				current = current.setdefault(p, {})
			current[path[-1]] = v
		else:
			obj[k] = v
	return obj

def merge_properties(dst, src):
	src = __pair_hook(src.iteritems())
	for key, value in src.iteritems():
		if key.find('.') >= 0:
			raise Exception('dot found in key')
		if isinstance(value, dict):
			node = dst.setdefault(key, {})
			merge_properties(node, value)
		else:
			dst[key] = value

	return dst

class Manifest(object):
	def __init__(self, data = None):
		if data is None:
			data = {}
		self.data = data

	@property
	def source_dir(self):
		return self.data.get('sources', 'src')

	@property
	def web_prefix(self):
		return self.data.get('web-prefix', '')

	@property
	def strict(self):
		return self.data.get('strict', True)

	@property
	def standalone(self):
		return self.data.get('standalone', True)

	@property
	def requires(self):
		return self.data.get('requires', [])

	@property
	def minify(self):
		return self.data.get('minify', False)

	@property
	def templater(self):
		return self.data.get('templater', 'simple')

	@property
	def languages(self):
		return self.data.get('languages', [])

	@property
	def platforms(self):
		return self.data.get('platforms', [])

	@property
	def package(self):
		return self.data.get('package', '')

	@property
	def public(self):
		return self.data.get('public', False)

	@property
	def templates(self):
		return self.data.get('templates', ['*.html'])

	@property
	def properties(self):
		return self.data.setdefault('properties', {})

	@property
	def partner(self):
		return self.data.get('partner', 'free')

	@property
	def export_module(self):
		return self.data.get('export_module', False)

def load(f):
	return Manifest(json.load(f, object_pairs_hook = __pair_hook))

def loads(s):
	return Manifest(json.loads(s, object_pairs_hook = __pair_hook))
