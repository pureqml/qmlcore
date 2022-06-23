from builtins import map

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
	return ".".join(map(escape_id, package))

def mangle_package(name):
	package = name.split('.')
	package = list(map(escape_id, package))
	if package[0] == '_globals':
		package.pop(0)
	package = [''] + package
	return "$".join(package)

class Error(Exception):
	def __init__(self, message, loc):
		if loc:
			super(Error, self).__init__("{}: {}".format(loc, message))
		else:
			super(Error, self).__init__(message)

from compiler.js.component import component_generator
from compiler.js.generator import generator
