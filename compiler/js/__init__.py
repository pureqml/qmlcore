import re

def get_package(name):
	return ".".join(name.split(".")[:-1])

def split_name(name):
	r = name.split(".")
	return ".".join(r[:-1]), r[-1]

_escape_re = re.compile('\W')
def escape(name):
	return _escape_re.sub('_', name)

_id_re = re.compile(r'[^a-zA-Z0-9_]')

def escape_id(name):
	return _id_re.sub('_', name)

from compiler.js.component import component_generator
from compiler.js.generator import generator
