from compiler import lang

# 	else:
# 		return str(value)
# 		dot = target.rfind('.')
# 		property_name = target[dot + 1:] if dot >= 0 else target
# 		if property_name == 'x':
# 			property_name = 'width'
# 		elif property_name == 'y':
# 			property_name = 'height'
#
# 		re_name = re.compile('<property-name>')
#
# 		if isinstance(value, str):
# 			self.value = Assignment.re_name.sub(property_name, value)
# 		else:
# 			self.value = to_string(value)
# 	#return "(this.parent[<property-name>] * ((%s) / 100))" %lang.to_string(value)

def eval(value, context):
	t = type(value)
	if t is lang.Component:
		return context.component(value)
	elif t is lang.Reference:
		return context.reference(value.path)
	elif t is lang.Operator:
		tokens = value.tokens
		n = len(tokens)
		if n == 2: #unary
			return tokens[0] + _breval(tokens[1], context)

		r = []
		for idx, token in enumerate(tokens):
			if not (idx & 1):
				token = _breval(token, context)
			r.append(token)
		return ''.join(r)
	if t is lang.Percent:
		return '((%s) * (%s) / 100)' %(context.reference(['this', 'parent', context.percent_target()]), eval(value.value, context))
	if t is lang.FunctionCall:
		return '%s(%s)' %(value.name, ','.join([_breval(arg, context) for arg in value.args]))
	elif t is str:
		return value
	elif (t is int or t is float):
		return str(value)
	elif t is bool:
 		return 'true' if value else 'false'
	else:
		raise Exception("cannot eval unknown object of type %s" %t)

def _breval(value, context):
	return '(' + eval(value, context) + ')'
