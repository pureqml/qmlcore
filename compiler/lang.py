from __future__ import unicode_literals
from builtins import object, str
from past.builtins import basestring

import re

trivial_value_re = re.compile(r'\$\{manifest\.[a-zA-Z0-9\$\.]+\}\Z')

def value_is_trivial(value):
	if isinstance(value, bool):
		return True

	if value is None or not isinstance(value, (str, basestring)):
		return False

	value = str(value)

	if value[0] == '(' and value[-1] == ')':
		value = value[1:-1]

	if value == 'true' or value == 'false' or value == 'null' or value == 'undefined' or value == 'this':
		return True

	if trivial_value_re.match(value):
		return True

	try:
		float(value)
		return True
	except:
		pass
	if value[0] == '"' and value[-1] == '"':
		if value.count('"') == value.count('\\"') + 2:
			return True
	#print "?trivial", value
	return False

class Entity(object):
	__slots__ = ('doc', 'loc')
	def __init__(self, doc = None, loc = None):
		self.doc, self.loc = doc, loc

def to_string(value):
	if isinstance(value, (str, basestring)):
		return value
	elif isinstance(value, bool):
		return 'true' if value else 'false'
	elif isinstance(value, Entity):
		return value
	else:
		return str(value)

re_x = re.compile(r'\\x([0-9a-f]{2})', re.I)
re_u = re.compile(r'\\u([0-9a-f]{4})', re.I)
re_o = re.compile(r'\\([0-7]{3})')
re_u2 = re.compile(r'\\([0-9][0-9a-f]{0,3})', re.I) #old js unicode stuff, try \07f
re_esc = re.compile(r'\\(.)')

def unescape_string(value):
	value = re_x.sub(lambda m: chr(int(m.group(1), 16)), value)
	value = re_u.sub(lambda m: chr(int(m.group(1), 16)), value)
	value = re_o.sub(lambda m: chr(int(m.group(1), 8)), value)
	value = re_u2.sub(lambda m: chr(int(m.group(1), 16)), value)

	def unescape(m):
		c = m.group(1)
		return {
			'0': '\0',
			'n': '\n',
			'r': '\r',
			'v': '\v',
			't': '\t',
			'b': '\b',
			'f': '\f',
		}.get(c, c)

	value = re_esc.sub(unescape, value)
	return value

def handle_property_path(t):
	return '${%s}' %t

class DocumentationString(object):
	__slots__ = 'text'
	def __init__(self, text):
		self.text = text

class Component(Entity):
	__slots__ = 'name', 'children'
	def __init__(self, name, children, **kw):
		super(Component, self).__init__(**kw)
		self.name = name
		self.children = children

class Property(Entity):
	__slots__ = 'lazy', 'const', 'type', 'properties'
	def __init__(self, type, properties, **kw):
		super(Property, self).__init__(**kw)
		self.lazy = type == 'lazy'
		self.const = type == 'const'
		self.type = type
		self.properties = properties

class Const(Entity):
	__slots__ = 'type', 'name', 'value'
	def __init__(self, type, name, value, **kw):
		super(Const, self).__init__(**kw)
		self.type, self.name, self.value = type, name, value

class AliasProperty(Entity):
	__slots__ = 'name', 'target'
	def __init__(self, name, target, **kw):
		super(AliasProperty, self).__init__(**kw)
		self.name = name
		self.target = target

class EnumProperty(Entity):
	__slots__ = 'name', 'values', 'default'
	def __init__(self, name, values, default, **kw):
		super(EnumProperty, self).__init__(**kw)
		self.name = name
		self.values = values
		self.default = default

class Method(Entity):
	__slots__ = 'name', 'args', 'code', 'event', 'async_'
	def __init__(self, name, args, code, event, async_, **kw):
		super(Method, self).__init__(**kw)
		self.name = name
		self.args = args
		self.code = code
		self.event = event
		self.async_ = async_

class IdAssignment(Entity):
	__slots__ = 'name'
	def __init__(self, name, **kw):
		super(IdAssignment, self).__init__(**kw)
		self.name = name

class Assignment(Entity):
	__slots__ = 'target', 'value'
	def __init__(self, target, value, **kw):
		super(Assignment, self).__init__(**kw)
		self.target = target
		if not isinstance(value, (str, basestring)):
			value = to_string(value)
		self.value = value

	def is_trivial(self):
		return value_is_trivial(self.value)

class AssignmentScope(Entity):
	__slots__ = 'target', 'values'
	def __init__(self, target, values, **kw):
		super(AssignmentScope, self).__init__(**kw)
		self.target = target
		self.values = values

class Behavior(Entity):
	__slots__ = 'target', 'animation'
	def __init__(self, target, animation, **kw):
		super(Behavior, self).__init__(**kw)
		self.target = target
		self.animation = animation

class Signal(Entity):
	__slots__ = 'name'
	def __init__(self, name, **kw):
		super(Signal, self).__init__(**kw)
		self.name = name

class ListElement(Entity):
	__slots__ = 'data'
	def __init__(self, data, **kw):
		super(ListElement, self).__init__(**kw)
		self.data = data
