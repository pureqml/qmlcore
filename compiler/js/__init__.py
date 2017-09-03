import re

def split_name(name):
	dot = name.rfind('.')
	if dot >= 0:
		return name[:dot], name[dot + 1:]
	else:
		return '', name

def get_package(name):
	return split_name(name)[0]

_escape_re = re.compile('\W')
def escape(name):
	return _escape_re.sub('_', name)

_id_re = re.compile(r'[^a-zA-Z0-9_]')

def escape_id(name):
	return _id_re.sub('_', name)

def escape_package(name):
	package = name.split('.')
	package = map(escape_id, package)
	return ".".join(package)

from compiler.js.component import component_generator
from compiler.js.generator import generator
