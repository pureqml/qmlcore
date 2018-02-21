import re

def value_is_trivial(value):
	if isinstance(value, bool):
		return True

	assert not isinstance(value, unicode)
	if value is None or not isinstance(value, str):
		return False

	if value[0] == '(' and value[-1] == ')':
		value = value[1:-1]

	if value == 'true' or value == 'false' or value == 'null':
		return True

	if value.startswith('${manifest.'):
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

def to_string(value):
	if isinstance(value, str):
		return value
	elif isinstance(value, bool):
		return 'true' if value else 'false'
	elif isinstance(value, object):
		return value
	else:
		return str(value)

def handle_property_path(t):
	return '${%s}' %t

class DocumentationString(object):
	def __init__(self, text):
		self.text = text

class Entity(object):
	def __init__(self):
		self.doc = None

class Component(Entity):
	def __init__(self, name, children):
		super(Component, self).__init__()
		self.name = name
		self.children = children

class Property(Entity):
	def __init__(self, type, properties):
		super(Property, self).__init__()
		self.lazy = type == 'lazy'
		self.const = type == 'const'
		self.type = type
		self.properties = properties

class AliasProperty(Entity):
	def __init__(self, name, target):
		super(AliasProperty, self).__init__()
		self.name = name
		self.target = target

class EnumProperty(Entity):
	def __init__(self, name, values, default):
		super(EnumProperty, self).__init__()
		self.name = name
		self.values = values
		self.default = default

class Method(Entity):
	def __init__(self, name, args, code, event):
		super(Method, self).__init__()
		self.name = name
		self.args = args
		self.code = code
		self.event = event

class IdAssignment(Entity):
	def __init__(self, name):
		super(IdAssignment, self).__init__()
		self.name = name

class Assignment(Entity):
	re_name = re.compile('<property-name>')

	def __init__(self, target, value):
		super(Assignment, self).__init__()
		self.target = target

		dot = target.rfind('.')
		property_name = target[dot + 1:] if dot >= 0 else target
		if property_name == 'x':
			property_name = 'width'
		elif property_name == 'y':
			property_name = 'height'

		if isinstance(value, str):
			self.value = Assignment.re_name.sub(property_name, value)
		else:
			self.value = to_string(value)

	def is_trivial(self):
		return value_is_trivial(self.value)

class AssignmentScope(Entity):
	def __init__(self, target, values):
		super(AssignmentScope, self).__init__()
		self.target = target
		self.values = values

class Behavior(Entity):
	def __init__(self, target, animation):
		super(Behavior, self).__init__()
		self.target = target
		self.animation = animation

class Signal(Entity):
	def __init__(self, name):
		super(Signal, self).__init__()
		self.name = name

class ListElement(Entity):
	def __init__(self, data):
		super(ListElement, self).__init__()
		self.data = data
