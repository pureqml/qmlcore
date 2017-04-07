import json

class Manifest(object):
	def __init__(self, data = None):
		if data is None:
			data = {}
		self.data = data

	@property
	def path(self):
		return self.data.get('path', [])

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
	def apps(self):
		return self.data.get('apps', {})

	@property
	def languages(self):
		return self.data.get('languages', [])

	@property
	def platforms(self):
		return self.data.get('platforms', [])

	@property
	def package(self):
		return self.data.get('package', '')


def load(f):
	return Manifest(json.load(f))

def loads(s):
	return Manifest(json.loads(s))
