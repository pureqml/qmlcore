import os

class Ts(object):
	def __init__(self):
		pass

	def load(self, path):
		pass

	def scan(self, dirs):
		for directory in dirs:
			for dirpath, dirname, files in os.walk(directory):
				dirname[:] = filter(lambda name: name[0] != '.' and not name.startswith('qml2js'), dirname)

			for file in files:
				_, ext = os.path.splitext(file)
				if ext != '.qml':
					continue
				path = os.path.join(dirpath, file)

