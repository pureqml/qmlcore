class Component(object):
	def __init__(self, name, children, mixins = []):
		self.name = name
		self.children = children
		self.mixins = mixins

class Property(object):
	def __init__(self, type, name, value = None):
		self.type = type
		self.name = name
		self.value = value

	def is_trivial(self):
		value = self.value
		if value is None or not isinstance(value, str):
			return False
		if value[0] == '(' and value[-1] == ')':
			value = value[1:-1]
		if value == 'true' or value == 'false':
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

class AliasProperty(object):
	def __init__(self, name, target):
		self.name = name
		self.target = target

class EnumProperty(object):
	def __init__(self, name, values, default):
		self.name = name
		self.values = values
		self.default = default

class Constructor(object):
	def __init__(self, args, code):
		if len(args) != 0:
			raise Exception("no arguments for constructor allowed")
		self.code = code

class Method(object):
	def __init__(self, name, args, code):
		self.name = name
		self.args = args
		self.code = code

class IdAssignment(object):
	def __init__(self, name):
		self.name = name

class Assignment(object):
	def __init__(self, target, value):
		self.target = target
		self.value = value

class AssignmentScope(object):
	def __init__(self, target, values):
		self.target = target
		self.values = values

class Behavior(object):
	def __init__(self, target, animation):
		self.target = target
		self.animation = animation

class Signal(object):
	def __init__(self, name):
		self.name = name
