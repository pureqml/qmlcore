import re
from collections import OrderedDict
import compiler.lang as lang

doc_next = None
doc_prev_component = None
doc_root_component = None

class CustomParser(object):
	def match(self, next):
		raise Exception("Expression should implement match method")

escape_re = re.compile(r"[\0\n\r\v\t\b\f]")
escape_map = {
	'\0': '\\0',
	'\n': '\\n',
	'\r': '\\r',
	'\v': '\\v',
	'\t': '\\t',
	'\b': '\\b',
	'\f': '\\f'
}
def escape(str):
	return escape_re.sub(lambda m: escape_map[m.group(0)], str)

class StringParser(CustomParser):
	def match(self, next):
		n = len(next)
		if n < 2:
			return

		quote = next[0]
		if quote != "'" and quote != "\"":
			return
		pos = 1
		while next[pos] != quote:
			if next[pos] == "\\":
				pos += 2
			else:
				pos += 1
			if pos >= n:
				raise Exception("Unexpected EOF while parsing string")
		return next[:pos + 1]

skip_re = re.compile(r'(?:\s+|/\*.*?\*/|//[^\n]*(?:$|\n))', re.DOTALL)
COMPONENT_NAME = r'(?:[a-z][a-zA-Z0-9._]*\.)?[A-Z][A-Za-z0-9]*'
component_name = re.compile(COMPONENT_NAME)
component_name_lookahead = re.compile(COMPONENT_NAME + r'\s*{')
identifier_re = re.compile(r'[a-z_][A-Za-z0-9_]*')
property_type_re = re.compile(r'[a-z][a-z0-9]*', re.IGNORECASE)
nested_identifier_re = re.compile(r'[a-z_][A-Za-z0-9_\.]*')
function_name_re = re.compile(r'[a-z_][a-z0-9_\.]*', re.IGNORECASE)
string_re = StringParser()
kw_re = re.compile(r'(?:true|false|null)')
NUMBER_RE = r"(?:\d+\.\d+(e[+-]?\d+)?|(?:0x)?[0-9]+)"
number_re = re.compile(NUMBER_RE, re.IGNORECASE)
percent_number_re = re.compile(NUMBER_RE + r'%', re.IGNORECASE)
scale_number_re = re.compile(NUMBER_RE + r's', re.IGNORECASE)
rest_of_the_line_re = re.compile(r".*$", re.MULTILINE)
json_object_value_delimiter_re = re.compile(r"[,;]")
dep_var = re.compile(r"\${(.*?)}")

class Expression(object):
	__slots__ = ('op', 'args')
	def __init__(self, op, *args):
		self.op, self.args = op, args

	def __repr__(self):
		return "Expression %s { %s }" %(self.op, ", ".join(map(repr, self.args)))

	def __str__(self):
		args = self.args
		n = len(args)
		if n == 1:
			return "(%s %s)" %(self.op, args[0])
		elif n == 2:
			return "(%s %s %s)" %(args[0], self.op, args[1])
		elif n == 3:
			op = self.op
			return "(%s %s %s %s %s)" %(args[0], op[0], args[1], op[1], args[2])
		else:
			raise Exception("invalid argument counter")

class Call(object):
	__slots__ = ('func', 'args')
	def __init__(self, func, args):
		self.func = func
		self.args = args

	def __repr__(self):
		return "Call %s { %s }" %(self.func, self.args)

	def __str__(self):
		if isinstance(self.func, Literal):
			name = self.func.term
			if name[0].islower():
				if '.' in name:
					name = '${%s}' %name
				else:
					name = '$this._context.%s' %name
		else:
			name = str(self.func)
			#if lhs is not an literal, than we can't process deps, removing ${xxx}
			name = dep_var.sub(lambda m: m.group(1), name)

		return "%s(%s)" %(name, ",".join(map(str, self.args)))

class Dereference(object):
	__slots__ = ('array', 'index')
	def __init__(self, array, index):
		self.array = array
		self.index = index

	def __str__(self):
		return "(%s[%s])" %(self.array, self.index)

class Literal(object):
	__slots__ = ('lbp', 'term', 'identifier')
	def __init__(self, term, string = False, identifier = False):
		self.term = escape(term) if string else term
		self.lbp = 0
		self.identifier = identifier

	def nud(self, state):
		return self

	def __repr__(self):
		return "Literal { %s }" %self.term

	def __str__(self):
		return "${%s}" %self.term if self.identifier and self.term[0].islower() else self.term

class PrattParserState(object):
	def __init__(self, parent, parser, token):
		self.parent, self.parser, self.token = parent, parser, token


class PrattParser(object):
	def __init__(self, ops):
		symbols = [(x.term, x) for x in ops]
		symbols.sort(key=lambda x: len(x[0]), reverse=True)
		self.symbols = symbols

	def next(self, parser):
		parser._skip()
		next = parser.next
		next_n = len(next)
		for term, sym in self.symbols:
			n = len(term)
			if n > next_n:
				continue

			keyword = term[-1].isalnum()
			if next.startswith(term):
				if keyword and n < next_n and next[n].isalnum():
					continue
				parser.advance(len(term))
				return sym

		next = parser.maybe(kw_re)
		if next:
			return Literal(next)
		next = parser.maybe(percent_number_re)
		if next:
			next = next[:-1]
			return Literal("((%s) / 100 * ${parent.<property-name>})" %next) if next != 100 else "(${parent.<property-name>})"
		next = parser.maybe(scale_number_re)
		if next:
			next = next[:-1]
			return Literal("((%s) * ${context.<scale-property-name>})" %next)
		next = parser.maybe(number_re)
		if next:
			return Literal(next)
		next = parser.maybe(function_name_re)
		if next:
			return Literal(next, identifier=True)
		next = parser.maybe(string_re)
		if next:
			return Literal(next, string=True)
		return None

	def advance(self, state, expect = None):
		if expect is not None:
			state.parser.read(expect, "Expected %s in expression" %expect)
		state.token = self.next(state.parser)

	def expression(self, state, rbp = 0):
		parser = state.parser
		t = state.token
		state.token = self.next(parser)
		if state.token is None:
			return t
		left = t.nud(state)
		while state.token is not None and rbp < state.token.lbp:
			t = state.token
			self.advance(state)
			left = t.led(state, left)
		return left

	def parse(self, parser):
		token = self.next(parser)
		if token is None:
			parser.error("Unexpected expression")
		state = PrattParserState(self, parser, token)
		return self.expression(state)

class UnsupportedOperator(object):
	__slots__ = ('term', 'lbp', 'rbp')

	def __init__(self, term, lbp = 0, rbp = 0):
		self.term, self.lbp, self.rbp = term, lbp, rbp

	def nud(self, state):
		state.parser.error("Unsupported prefix operator %s" %self.term)

	def led(self, state, left):
		state.parser.error("Unsupported postfix operator %s" %self.term)

	def __repr__(self):
		return "UnsupportedOperator { %s %s }" %(self.term, self.lbp)


class Operator(object):
	__slots__ = ('term', 'lbp', 'rbp')
	def __init__(self, term, lbp = 0, rbp = None):
		self.term, self.lbp, self.rbp = term, lbp, rbp

	def nud(self, state):
		if self.rbp is not None:
			return Expression(self.term, state.parent.expression(state, self.rbp))
		state.parser.error("Unexpected token in infix expression: '%s'" %self.term)

	def led(self, state, left):
		if self.lbp is not None:
			return Expression(self.term, left, state.parent.expression(state, self.lbp))
		else:
			state.parser.error("No left-associative operator defined")

	def __repr__(self):
		return "Operator { %s %s %s }" %(self.term, self.lbp, self.rbp)

class Conditional(object):
	__slots__ = ('term', 'lbp')
	def __init__(self, lbp):
		self.term = '?'
		self.lbp = lbp

	def nud(self, state):
		state.parser.error("Conditional operator can't be used as unary")

	def led(self, state, left):
		true = state.parent.expression(state)
		state.parent.advance(state, ':')
		false = state.parent.expression(state)
		return Expression(('?', ':'), left, true, false)

	def __repr__(self):
		return "Conditional { }"

class LeftParenthesis(object):
	__slots__ = ('term', 'lbp')
	def __init__(self, lbp):
		self.term = '('
		self.lbp = lbp

	def nud(self, state):
		expr = state.parent.expression(state)
		state.parent.advance(state, ')')
		return expr

	def led(self, state, left):
		args = []
		next = state.token
		if next.term != ')':
			while True:
				args.append(state.parent.expression(state))
				if state.token is not None:
					state.parser.error("Unexpected token %s" %state.token)
				if not state.parser.maybe(','):
					break
				state.parent.advance(state)
			state.parent.advance(state, ')')

		return Call(left, args)

	def __repr__(self):
		return "LeftParenthesis { %d }" %self.lbp

class LeftSquareBracket(object):
	__slots__ = ('term', 'lbp')
	def __init__(self, lbp):
		self.term = '['
		self.lbp = lbp

	def nud(self, state):
		state.parser.error("Invalid [] expression")

	def led(self, state, left):
		arg = state.parent.expression(state)
		if state.token is not None:
			state.parser.error("Unexpected token %s" %state.token)
		state.parent.advance(state, ']')
		return Dereference(left, arg)

	def __repr__(self):
		return "LeftSquareBracket { %d }" %self.lbp


infix_parser = PrattParser([
	Operator('.', 19),
	LeftParenthesis(19),
	LeftSquareBracket(19),

	UnsupportedOperator('++', 17, 16),
	UnsupportedOperator('--', 17, 16),
	UnsupportedOperator('void', None, 16),
	UnsupportedOperator('delete', None, 16),
	UnsupportedOperator('await', None, 16),
	Operator('typeof', None, 16),

	Operator('!', None, 16),
	Operator('~', None, 16),
	Operator('+', 13, 16),
	Operator('-', 13, 16),
	Operator('typeof', None, 16),

	Operator('**', 15),

	Operator('*', 14),
	Operator('/', 14),
	Operator('%', 14),

	Operator('<<', 12),
	Operator('>>', 12),
	Operator('>>>', 12),

	Operator('<', 11),
	Operator('<=', 11),
	Operator('>', 11),
	Operator('>=', 11),
	Operator('in', 11),
	Operator('instanceof', 11),

	Operator('==', 10),
	Operator('!=', 10),
	Operator('===', 10),
	Operator('!==', 10),

	Operator('&', 9),
	Operator('^', 8),
	Operator('|', 7),

	Operator('&&', 6),
	Operator('||', 5),

	Conditional(4),
])

class Parser(object):
	def __init__(self, text):
		self.__text = text
		self.__pos = 0
		self.__lineno = 1
		self.__colno = 1
		self.__last_object = None
		self.__next_doc = None

	@property
	def at_end(self):
		return self.__pos >= len(self.__text)

	@property
	def next(self):
		return self.__text[self.__pos:]

	@property
	def current_line(self):
		text = self.__text
		pos = self.__pos
		begin = text.rfind('\n', 0, pos)
		end = text.find('\n', pos)
		if begin < 0:
			begin = 0
		else:
			begin += 1
		if end < 0:
			end = len(text)
		return text[begin:end]

	def advance(self, n):
		text = self.__text
		pos = self.__pos
		for i in range(n):
			if text[pos] == '\n':
				self.__lineno += 1
				self.__colno = 1
			else:
				self.__colno += 1
			pos += 1

		self.__pos = pos

	def __docstring(self, text, prev):
		if prev:
			if self.__last_object:
				if self.__last_object.doc is not None:
					self.__last_object.doc = lang.DocumentationString(self.__last_object.doc.text + " " + text)
				else:
					self.__last_object.doc = lang.DocumentationString(text)
			else:
				self.error("Found docstring without previous object")
		else:
			if self.__next_doc is not None:
				self.__next_doc += " " + text
			else:
				self.__next_doc = text

	def __get_next_doc(self):
		if self.__next_doc is None:
			return
		doc = lang.DocumentationString(self.__next_doc)
		self.__next_doc = None
		return doc

	def __return(self, object, doc):
		if doc:
			if object.doc:
				object.doc = lang.DocumentationString(object.doc.text + " " + doc.text)
			else:
				object.doc = doc
		self.__last_object = object
		return object

	def _skip(self):
		while True:
			m = skip_re.match(self.next)
			if m is not None:
				text = m.group(0).strip()
				if text.startswith('///<'):
					self.__docstring(text[4:], True)
				elif text.startswith('///'):
					self.__docstring(text[3:], False)
				elif text.startswith('/**'):
					end = text.rfind('*/')
					self.__docstring(text[3:end], False)
				self.advance(m.end())
			else:
				break

	def error(self, msg):
		lineno, col, line = self.__lineno, self.__colno, self.current_line
		pointer = re.sub(r'\S', ' ', line)[:col - 1] + '^-- ' + msg
		raise Exception("at line %d:%d:\n%s\n%s" %(lineno, col, self.current_line, pointer))

	def lookahead(self, exp):
		if self.at_end:
			return

		self._skip()
		next = self.next

		if isinstance(exp, str):
			keyword = exp[-1].isalnum()
			n, next_n = len(exp), len(next)
			if n > next_n:
				return

			if next.startswith(exp):
				#check that exp ends on word boundary
				if keyword and n < next_n and next[n].isalnum():
					return
				else:
					return exp
		elif isinstance(exp, CustomParser):
			return exp.match(next)
		else:
			m = exp.match(next)
			if m:
				return m.group(0)

	def maybe(self, exp):
		value = self.lookahead(exp)
		if value is not None:
			self.advance(len(value))
			return value

	def read(self, exp, error):
		value = self.maybe(exp)
		if value is None:
			self.error(error)
		return value

	def __read_statement_end(self):
		self.read(';', "Expected ; at the end of the statement")

	def __read_list(self, exp, delimiter, error):
		result = []
		result.append(self.read(exp, error))
		while self.maybe(delimiter):
			result.append(self.read(exp, error))
		return result

	def __read_nested(self, begin, end, error):
		begin_off = self.__pos
		self.read(begin, error)
		counter = 1
		while not self.at_end:
			if self.maybe(begin):
				counter += 1
			elif self.maybe(end):
				counter -= 1
				if counter == 0:
					end_off = self.__pos
					value = self.__text[begin_off: end_off]
					return value
			else:
				if not self.maybe(string_re):
					self.advance(1)

	def __read_code(self):
		return self.__read_nested('{', '}', "Expected code block")

	def __read_expression(self, terminate = True):
		if self.maybe('['):
			values = []
			while not self.maybe(']'):
				values.append(self.__read_expression(terminate = False))
				if self.maybe(']'):
					break
				self.read(',', "Expected ',' as an array delimiter")
			if terminate:
				self.__read_statement_end()
			return "[%s]" % (",".join(map(str, values)))
		else:
			value = infix_parser.parse(self)
			if terminate:
				self.__read_statement_end()
			return str(value)

	def __read_property(self):
		if self.lookahead(':'):
			return self.__read_rules_with_id(["property"])
		doc = self.__get_next_doc()
		type = self.read(property_type_re, "Expected type after property keyword")
		if type == 'enum':
			type = self.read(identifier_re, "Expected type after enum keyword")
			self.read('{', "Expected { after property enum")
			values = self.__read_list(component_name, ',', "Expected capitalised enum element")
			self.read('}', "Expected } after enum element declaration")
			if self.maybe(':'):
				def_value = self.read(component_name, "Expected capitalised default enum value")
			else:
				def_value = None
			self.__read_statement_end()
			return self.__return(lang.EnumProperty(type, values, def_value), doc)
		if type == 'const':
			name = self.read(identifier_re, "Expected const property name")
			self.read(':', "Expected : before const property code")
			code = self.__read_code()
			return self.__return(lang.Property("const", [(name, code)]), doc)
		if type == 'alias':
			name = self.read(identifier_re, "Expected alias property name")
			self.read(':', "Expected : before alias target")
			target = self.read(nested_identifier_re, "Expected identifier as an alias target")
			self.__read_statement_end()
			return self.__return(lang.AliasProperty(name, target), doc)
		names = self.__read_list(identifier_re, ',', "Expected identifier in property list")
		if len(names) == 1:
			#Allow initialisation for the single property
			def_value = None
			if self.maybe(':'):
				if self.lookahead(component_name_lookahead):
					def_value = self.__read_comp()
				else:
					def_value = self.__read_expression()
			else:
				self.__read_statement_end()
			name = names[0]
			return self.__return(lang.Property(type, [(name, def_value)]), doc)
		else:
			self.read(';', 'Expected ; at the end of property declaration')
			return self.__return(lang.Property(type, map(lambda name: (name, None), names)), doc)

	def __read_rules_with_id(self, identifiers):
		args = []
		doc = self.__get_next_doc()
		if self.maybe('('):
			if not self.maybe(')'):
				args = self.__read_list(identifier_re, ',', "Expected argument list")
			self.read(')', "Expected () as an argument list")

		if self.maybe(':'):
			if self.lookahead('{'):
				code = self.__read_code()
				return self.__return(lang.Method(identifiers, args, code, True, False), doc)

			if len(identifiers) > 1:
				self.error("Multiple identifiers are not allowed in assignment")

			if self.lookahead(component_name_lookahead):
				return self.__return(lang.Assignment(identifiers[0], self.__read_comp()), doc)

			value = self.__read_expression()
			return self.__return(lang.Assignment(identifiers[0], value), doc)
		elif self.maybe('{'):
			if len(identifiers) > 1:
				self.error("Multiple identifiers are not allowed in assignment scope")
			values = []
			while not self.maybe('}'):
				name = self.read(nested_identifier_re, "Expected identifier in assignment scope")
				self.read(':', "Expected : after identifier in assignment scope")
				value = self.__read_expression()
				values.append(lang.Assignment(name, value))
			return self.__return(lang.AssignmentScope(identifiers[0], values), doc)
		else:
			self.error("Unexpected identifier(s): %s" %",".join(identifiers))


	def __read_function(self, async_f = False):
		doc = self.__get_next_doc()
		name = self.read(identifier_re, "Expected identifier")
		args = []
		self.read('(', "Expected (argument-list) in function declaration")
		if not self.maybe(')'):
			args = self.__read_list(identifier_re, ',', "Expected argument list")
			self.read(')', "Expected ) at the end of argument list")
		code = self.__read_code()
		return self.__return(lang.Method([name], args, code, False, async_f), doc)


	def __read_json_value(self):
		value = self.maybe(kw_re)
		if value is not None:
			return value
		value = self.maybe(number_re)
		if value is not None:
			return value
		value = self.maybe(string_re)
		if value is not None:
			return lang.unescape_string(value[1:-1])
		if self.lookahead('{'):
			return self.__read_json_object()
		if self.lookahead('['):
			return self.__read_json_list

	def __read_json_list(self):
		self.read('[', "Expect JSON list starts with [")
		result = []
		while not self.maybe(']'):
			result.append(self.__read_json_value)
			if self.maybe(']'):
				break
			self.read(',', "Expected , as a JSON list delimiter")

		return result

	def __read_json_object(self):
		self.read('{', "Expected JSON object starts with {")
		object = OrderedDict()
		while not self.maybe('}'):
			name = self.maybe(identifier_re)
			if not name:
				name = self.read(string_re, "Expected string or identifier as property name")
			self.read(':', "Expected : after property name")
			value = self.__read_json_value()
			object[name] = value
			self.maybe(json_object_value_delimiter_re)
		return object


	def __read_scope_decl(self):
		if self.maybe('ListElement'):
			doc = self.__get_next_doc()
			return self.__return(lang.ListElement(self.__read_json_object()), doc)
		elif self.maybe('Behavior'):
			self.read("on", "Expected on keyword after Behavior declaration")
			doc = self.__get_next_doc()
			targets = self.__read_list(nested_identifier_re, ",", "Expected identifier list after on keyword")
			self.read("{", "Expected { after identifier list in behavior declaration")
			comp = self.__read_comp()
			self.read("}", "Expected } after behavior animation declaration")
			return self.__return(lang.Behavior(targets, comp), doc)
		elif self.maybe('signal'):
			doc = self.__get_next_doc()
			name = self.read(identifier_re, "Expected identifier in signal declaration")
			self.__read_statement_end()
			return self.__return(lang.Signal(name), doc)
		elif self.maybe('property'):
			return self.__read_property()
		elif self.maybe('id'):
			doc = self.__get_next_doc()
			self.read(':', "Expected : after id keyword")
			name = self.read(identifier_re, "Expected identifier in id assignment")
			self.__read_statement_end()
			return self.__return(lang.IdAssignment(name), doc)
		elif self.maybe('const'):
			doc = self.__get_next_doc()
			type = self.read(property_type_re, "Expected type after const keyword")
			name = self.read(component_name, "Expected Capitalised const name")
			self.read(':', "Expected : after const identifier")
			value = self.__read_json_value()
			self.__read_statement_end()
			return self.__return(lang.Const(type, name, value), doc)
		elif self.maybe('async'):
			self.error("async fixme")
		elif self.maybe('function'):
			return self.__read_function()
		elif self.maybe('async'):
			self.read('function', "Expected function after async")
			return self.__read_function(async_f = True)
		elif self.lookahead(component_name_lookahead):
			return self.__read_comp()
		else:
			identifiers = self.__read_list(nested_identifier_re, ",", "Expected identifier (or identifier list)")
			return self.__read_rules_with_id(identifiers)

	def __read_comp(self):
		doc = self.__get_next_doc()
		comp_name = self.read(component_name, "Expected component name")
		self.read(r'{', "Expected {")
		children = []
		while not self.maybe('}'):
			children.append(self.__read_scope_decl())
		return self.__return(lang.Component(comp_name, children), doc)

	def parse(self, parse_all = True):
		while self.maybe('import'):
			self.read(rest_of_the_line_re, "Skip to the end of the line failed")

		r = [self.__read_comp()]
		self._skip()
		if parse_all:
			if self.__pos < len(self.__text):
				self.error("Extra text after component declaration")
		return r

def parse(data):
	global doc_root_component
	doc_root_component = None
	parser = Parser(data)
	return parser.parse()

