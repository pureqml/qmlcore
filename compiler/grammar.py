from pyparsing import *
import lang

ParserElement.setDefaultWhitespaceChars(" \t\r\f")
ParserElement.enablePackrat()

doc_next = None
doc_prev_component = None
doc_root_component = None

def component(com):
	global doc_next, doc_prev_component, doc_root_component

	if not doc_root_component:
		doc_root_component = doc_next

	if doc_next:
		com.doc = doc_next
		doc_next = None
	doc_prev_component = com
	return com


def document(text, line, prev):
	text = text.strip()
	if not text:
		print 'WARNING: empty documentation string at line %d' %line
		return

	global doc_next, doc_prev_component
	if prev:
		if doc_prev_component:
			doc_prev_component.doc = lang.DocumentationString(text)
		else:
			print 'WARNING: unused documentation string %s at line %d' %(text, line)
	else:
		doc_next = lang.DocumentationString(text)

def handle_component_declaration(s, l, t):
	#print "component>", t
	type = t[0]
	idx = type.rfind('.')
	if idx >= 0:
		type = type[idx + 1:]
	if type[0].islower():
		raise ParseException(s, l, 'lowercase component name')
	return component(lang.Component(t[0], t[1]))

def handle_assignment(s, l, t):
	#print "assignment>", t
	return component(lang.Assignment(t[0], t[1]))

def handle_property_declaration(s, l, t):
	#print "property>", t
	properties = map(lambda x: (x[0], None) if len(x) < 2 else (x[0], x[1]), t[1])
	return component(lang.Property(t[0], properties))

def handle_alias_property_declaration(s, l, t):
	return component(lang.AliasProperty(t[0], t[1]))

def handle_enum_property_declaration(s, l, t):
	return component(lang.EnumProperty(t[0], t[1], t[2] if len(t) > 2 else None))

def handle_method_declaration(s, l, t):
	event_handler = t[0] != 'function'
	if event_handler:
		names, args, code = t[0], t[1], t[2]
	else:
		names, args, code = t[1], t[2], t[3]

	return component(lang.Method(names, args, code, event_handler))

def handle_assignment_scope(s, l, t):
	#print "assignment-scope>", t
	return component(lang.AssignmentScope(t[0], t[1]))

def handle_nested_identifier_rvalue(s, l, t):
	#print "nested-id>", t
	return lang.handle_property_path(t[0])

def handle_enum_value(s, l, t):
	#print "enum>", t
	return "".join(t)

def handle_id_declaration(s, l, t):
	#print "id>", t
	return component(lang.IdAssignment(t[0]))

def handle_behavior_declaration(s, l, t):
	#print "behavior>", t
	return component(lang.Behavior(t[0], t[1]))

def handle_signal_declaration(s, l, t):
	return component(lang.Signal(t[0]))

def handle_function_call(s, l, t):
	#print "func> ", t
	name = t[0]
	if name[0].islower():
		name = '_globals.' + name
	return "%s(%s)" % (name, ",".join(t[1:]))

def handle_documentation_string(s, l, t):
	text = t[0]
	global doc_next, doc_root_component
	if doc_next is not None and doc_root_component is None:
		doc_root_component = doc_next

	if text.startswith('///<'):
		document(text[4:], l, True)
	elif text.startswith('///'):
		document(text[3:], l, False)
	elif text.startswith('/**'):
		end = text.rfind('*/')
		document(text[3:end], l, False)

def handle_json_object(s, l, tokens):
	obj = {}
	for key, value in tokens:
		obj[key] = value
	return obj

def handle_list_element(s, l, t):
	return lang.ListElement(t[0])

def handle_number(s, l, t):
	value = t[0]
	if value.startswith('0x'):
		return int(value[2:], 16)
	else:
		return float(value) if '.' in value else int(value)

def handle_bool_value(s, l, t):
	value = t[0] == "true"
	return value

expression = Forward()
expression_list = delimitedList(expression, ",")

component_declaration = Forward()

type = Word(alphas, alphanums)
component_type = Word(srange("[A-Za-z_]"), alphanums + "._")
identifier = Word(srange("[a-z_]"), alphanums + "_")
null_value = Keyword("null")
bool_value = Keyword("true") | Keyword("false")
bool_value.setParseAction(handle_bool_value)
number = Combine(Optional('0x') + Word("01234567890+-."))
number.setParseAction(handle_number)

def handle_string(s, l, t):
	value = t[0]
	value = value.replace('\t', '\\t')
	value = value.replace('\r', '\\r')
	value = value.replace('\n', '\\n')
	value = value.replace('\v', '\\v')
	value = value.replace('\f', '\\f')
	t[0] = value
	return t

quoted_string_value = \
	QuotedString('"', escChar='\\', unquoteResults = False, multiline=True) | \
	QuotedString("'", escChar='\\', unquoteResults = False, multiline=True) | \
	QuotedString("`", escChar='\\', unquoteResults = False, multiline=True)
quoted_string_value.setParseAction(handle_string)

code = originalTextFor(nestedExpr("{", "}", ignoreExpr=(quoted_string_value | cStyleComment | cppStyleComment)))

unquoted_string_value = \
	QuotedString('"', escChar='\\', unquoteResults = True, multiline=True) | \
	QuotedString("'", escChar='\\', unquoteResults = True, multiline=True) | \
	QuotedString("`", escChar='\\', unquoteResults = True, multiline=True)
unquoted_string_value.setParseAction(handle_string)

enum_element = Word(srange("[A-Z_]"), alphanums)
enum_value = Word(srange("[A-Z_]"), alphanums) + Literal(".") + enum_element
enum_value.setParseAction(handle_enum_value)

function_call = Word(alphanums + '._') + Suppress("(") + Optional(expression_list) + Suppress(")") + \
	ZeroOrMore(Suppress(".") + Suppress("arg") + Suppress("(") + expression + Suppress(")"))
function_call.setParseAction(handle_function_call)

nested_identifier_lvalue = Word(srange("[a-z_]"), alphanums + "._")

nested_identifier_rvalue = Word(srange("[a-z_]"), alphanums + "._")
nested_identifier_rvalue.setParseAction(handle_nested_identifier_rvalue)

newline = Suppress("\n")
expression_end = Suppress(";")
statement_end = expression_end | newline

signal_declaration = Keyword("signal").suppress() + identifier + statement_end
signal_declaration.setParseAction(handle_signal_declaration)

id_declaration = Keyword("id").suppress() + Suppress(":") + identifier + statement_end
id_declaration.setParseAction(handle_id_declaration)


assign_declaration = nested_identifier_lvalue + Suppress(":") + expression + statement_end
assign_declaration.setParseAction(handle_assignment)

assign_component_declaration = nested_identifier_lvalue + Suppress(":") + component_declaration
assign_component_declaration.setParseAction(handle_assignment)

const_property_declaration = Keyword("property").suppress() + Keyword("const") - Group(Group(identifier + Suppress(":") + code))
const_property_declaration.setParseAction(handle_property_declaration)

property_name_initializer_declaration = Group(identifier + Optional(Suppress(":") + expression))
property_declaration = ((Keyword("property").suppress() + type + Group(delimitedList(property_name_initializer_declaration, ',')) + statement_end) | \
	(Keyword("property").suppress() + type + Group(Group(identifier + Suppress(":") + component_declaration))))
property_declaration.setParseAction(handle_property_declaration)

alias_property_declaration = Keyword("property").suppress() + Keyword("alias").suppress() + identifier + Suppress(":") + nested_identifier_lvalue + statement_end
alias_property_declaration.setParseAction(handle_alias_property_declaration)

enum_property_declaration = Keyword("property").suppress() + Keyword("enum").suppress() + identifier + \
	Suppress("{") + Group(delimitedList(enum_element, ',')) + Suppress("}") + Optional(Literal(':').suppress() + enum_element) + statement_end
enum_property_declaration.setParseAction(handle_enum_property_declaration)

assign_scope_declaration = identifier + Suppress(":") + expression + statement_end
assign_scope_declaration.setParseAction(handle_assignment)
assign_scope = nested_identifier_lvalue + Suppress("{") + Group(OneOrMore(assign_scope_declaration | statement_end)) + Suppress("}")
assign_scope.setParseAction(handle_assignment_scope)

method_declaration = Group(delimitedList(nested_identifier_lvalue, ',')) + Group(Optional(Suppress("(") + delimitedList(identifier, ",") + Suppress(")") )) + Suppress(":") + code
method_declaration.setParseAction(handle_method_declaration)
method_declaration.ignore(newline)

method_declaration_qml = Keyword("function") - Group(nested_identifier_lvalue) + Group(Suppress("(") + Optional(delimitedList(identifier, ",")) + Suppress(")") ) + code
method_declaration_qml.setParseAction(handle_method_declaration)

behavior_declaration = Keyword("Behavior").suppress() + Keyword("on").suppress() + Group(delimitedList(nested_identifier_lvalue, ',')) + Suppress("{") + component_declaration + Suppress("}")
behavior_declaration.setParseAction(handle_behavior_declaration)

json_value = Forward()
json_object = Suppress("{") + delimitedList(Group((unquoted_string_value | identifier) + Suppress(":") + json_value) | empty, Suppress(";") | Suppress(",")) + Suppress('}')
json_object.setParseAction(handle_json_object)
json_array = Suppress("[") + delimitedList(json_value) + Suppress("]")
json_value << (null_value | bool_value | number | unquoted_string_value | json_array | json_object)

list_element_declaration = Keyword("ListElement").suppress() - json_object
list_element_declaration.setParseAction(handle_list_element)

import_statement = Keyword("import") + restOfLine

scope_declaration = list_element_declaration | behavior_declaration | signal_declaration | alias_property_declaration | enum_property_declaration | const_property_declaration | property_declaration | id_declaration | assign_declaration | assign_component_declaration | component_declaration | method_declaration | method_declaration_qml | assign_scope
component_scope = (Suppress("{") + Group(ZeroOrMore(scope_declaration | statement_end)) + Suppress("}"))

component_declaration << ZeroOrMore(statement_end).suppress() + (component_type + component_scope) + ZeroOrMore(statement_end).suppress()
component_declaration.setParseAction(handle_component_declaration)

def handle_unary_op(s, l, t):
	#print "EXPR", t
	return " ".join(map(str, t[0]))
def handle_binary_op(s, l, t):
	#print "EXPR", t
	return " ".join(map(str, t[0]))
def handle_ternary_op(s, l, t):
	#print "EXPR", t
	return " ".join(map(str, t[0]))

def handle_percent_number(s, l, t):
	value = t[0]
	strvalue = lang.to_string(value)
	return ("((%s) / 100 * ${parent.<property-name>})" %strvalue) if strvalue != 100 else "(${parent.<property-name>})"

percent_number = number + '%'
percent_number.setParseAction(handle_percent_number)

expression_array = Literal("[") + Optional(delimitedList(expression, ",")) + Literal("]")
def handle_expression_array(s, l, t):
	return "".join(t)

expression_array.setParseAction(handle_expression_array)

expression_definition = null_value | bool_value | percent_number | number | quoted_string_value | function_call | nested_identifier_rvalue | enum_value | expression_array

expression_ops = infixNotation(expression_definition, [
	(oneOf('! ~ + -'),	1, opAssoc.RIGHT, handle_unary_op),
	(oneOf('* / %'),	2, opAssoc.LEFT, handle_binary_op),
	(oneOf('+ -'),		2, opAssoc.LEFT, handle_binary_op),
	(oneOf('<< >>'),	2, opAssoc.LEFT, handle_binary_op),

	(oneOf('< <= > >= =='),	2, opAssoc.LEFT, handle_binary_op),
	(oneOf('== != === !=='),	2, opAssoc.LEFT, handle_binary_op),

	('&', 2, opAssoc.LEFT, handle_binary_op),
	('^', 2, opAssoc.LEFT, handle_binary_op),
	('|', 2, opAssoc.LEFT, handle_binary_op),

	('&&', 2, opAssoc.LEFT, handle_binary_op),
	('||', 2, opAssoc.LEFT, handle_binary_op),

	(('?', ':'), 3, opAssoc.RIGHT, handle_ternary_op),
])
expression_ops.setParseAction(lambda s, l, t: "(%s)" %lang.to_string(t[0]))

expression << expression_ops
expression.ignore(newline)

source = component_declaration
cStyleComment.setParseAction(handle_documentation_string)
source = source.ignore(cStyleComment)
dblSlashComment.setParseAction(handle_documentation_string)
source = source.ignore(dblSlashComment)
source = source.ignore(import_statement)

def parse(data):
	global doc_root_component
	doc_root_component = None
	tree = source.parseString(data, parseAll = True)
	if len(tree) > 0:
		tree[0].doc = doc_root_component
	return tree
