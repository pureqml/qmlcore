class Component(object):
	def __init__(self, name):
		self.name = name

class Property(object):
	def __init__(self, type, name, value = None):
		self.type = type
		self.name = name
		self.value = value

class Method(object):
	def __init__(self, name, code):
		self.name = name
		self.code = code

class Assignment(object):
	def __init__(self, target, value):
		self.target = target
		self.value = value

class AssignmentScope(object):
	def __init__(self, target, values):
		self.target = target
		self.values = values
