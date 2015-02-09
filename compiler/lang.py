class Component(object):
	def __init__(self, name, children):
		self.name = name
		self.children = children

class Property(object):
	def __init__(self, type, name, value = None):
		self.type = type
		self.name = name
		self.value = value

class Method(object):
	def __init__(self, name, code):
		self.name = name
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

class Event(object):
	def __init__(self, name):
		self.name = name
