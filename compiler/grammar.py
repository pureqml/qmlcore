from pyparsing import *
import lang

def handle_component_declaration(s, l, t):
	#print "component>", t
	return lang.Component(t[0], t[1])

def handle_assignment(s, l, t):
	#print "assignment>", t
	return lang.Assignment(t[0], t[1])

def handle_property_declaration(s, l, t):
	#print "property>", t
	default = t[2] if len(t) > 2 else None
	return lang.Property(t[0], t[1], default)

def handle_alias_property_declaration(s, l, t):
	return lang.AliasProperty(t[0], t[1])

def handle_enum_property_declaration(s, l, t):
	return lang.EnumProperty(t[0], t[1], t[2] if len(t) > 2 else None)

def handle_method_declaration(s, l, t):
	event_handler = t[0] != 'function'
	if event_handler:
		name, args, code = t[0], t[1], t[2]
	else:
		name, args, code = t[1], t[2], t[3]
	return lang.Method(name, args, code, event_handler) if name != 'constructor' else lang.Constructor(args, code)

def handle_assignment_scope(s, l, t):
	#print "assignment-scope>", t
	return lang.AssignmentScope(t[0], t[1])

def handle_nested_identifier_rvalue(s, l, t):
	#print "nested-id>", t
	path = t[0].split(".")
	if path[0] == 'this':
		return 'this'
	if path[0] == "model":
		return "this._get('model').%s" %".".join(path[1:])
	path = ["_get('%s')" %x for x in path]
	return "this.%s" % ".".join(path)

def handle_enum_value(s, l, t):
	#print "enum>", t
	return "".join(t)

def handle_id_declaration(s, l, t):
	#print "id>", t
	return lang.IdAssignment(t[0])

def handle_behavior_declaration(s, l, t):
	#print "behavior>", t
	return lang.Behavior(t[0], t[1])

def handle_signal_declaration(s, l, t):
	return lang.Signal(t[0])

def handle_builtin(s, l, t):
	#print "builtin> ", t
	return "".join(t)

def handle_function_call(s, l, t):
	#print "func> ", t
	return "%s(%s)" % (t[0], ",".join(t[1:]))

expression = Forward()
expression_list = Forward()
component_declaration = Forward()

type = Word(alphas, alphanums)
component_type = Word(srange("[A-Za-z_]"), alphanums + "._")
identifier = Word(srange("[a-z_]"), alphanums + "_")
code = originalTextFor(nestedExpr("{", "}", None, None))

enum_element = Word(srange("[A-Z_]"), alphanums)
enum_value = Word(srange("[A-Z_]"), alphanums) + Literal(".") + enum_element
enum_value.setParseAction(handle_enum_value)

builtin = Keyword("Math") + Literal(".") + Word(alphanums) + Optional(Literal("(") + expression_list + Literal(")"))
builtin.setParseAction(handle_builtin)

function_call = Word(alphanums) + Literal("(").suppress() + expression_list + Literal(")").suppress() + \
	ZeroOrMore(Literal(".").suppress() + Literal("arg").suppress() + Literal("(").suppress() + expression + Literal(")").suppress())

function_call.setParseAction(handle_function_call)

nested_identifier_lvalue = Word(srange("[a-z_]"), alphanums + "._")
nested_identifier_lvalue_list = Group(nested_identifier_lvalue + ZeroOrMore(Literal(",").suppress() + nested_identifier_lvalue))

nested_identifier_rvalue = Word(srange("[a-z_]"), alphanums + "._")
nested_identifier_rvalue.setParseAction(handle_nested_identifier_rvalue)

expression_end = Literal(";").suppress()

signal_declaration = Keyword("signal").suppress() + identifier + expression_end
signal_declaration.setParseAction(handle_signal_declaration)

id_declaration = Keyword("id").suppress() + Literal(":").suppress() + identifier + expression_end
id_declaration.setParseAction(handle_id_declaration)


assign_declaration = nested_identifier_lvalue + Literal(":").suppress() + expression + expression_end
assign_declaration.setParseAction(handle_assignment)

assign_component_declaration = nested_identifier_lvalue + Literal(":").suppress() + component_declaration
assign_component_declaration.setParseAction(handle_assignment)

property_declaration = (((Keyword("property").suppress() + type + identifier + Literal(":").suppress() + expression) | \
		(Keyword("property").suppress() + type + identifier)) + expression_end) | \
	(Keyword("property").suppress() + type + identifier + Literal(":").suppress() + component_declaration) \

alias_property_declaration = Keyword("property").suppress() + Keyword("alias").suppress() + identifier + Literal(":").suppress() + nested_identifier_lvalue + expression_end
alias_property_declaration.setParseAction(handle_alias_property_declaration)

enum_property_declaration = Keyword("property").suppress() + Keyword("enum").suppress() + identifier + \
	Literal("{").suppress() + Group(enum_element + ZeroOrMore(Literal(",").suppress() + enum_element)) + Literal("}").suppress() + Optional(Literal(':').suppress() + enum_element) + expression_end
enum_property_declaration.setParseAction(handle_enum_property_declaration)

property_declaration.setParseAction(handle_property_declaration)

assign_scope_declaration = identifier + Literal(":").suppress() + expression + expression_end
assign_scope_declaration.setParseAction(handle_assignment)
assign_scope = nested_identifier_lvalue + Literal("{").suppress() + Group(OneOrMore(assign_scope_declaration)) + Literal("}").suppress()
assign_scope.setParseAction(handle_assignment_scope)

method_declaration = nested_identifier_lvalue + Group(Optional(Literal("(").suppress() + identifier + ZeroOrMore(Literal(",").suppress() + identifier) + Literal(")").suppress() )) + Literal(":").suppress() + code
method_declaration.setParseAction(handle_method_declaration)

method_declaration_qml = Keyword("function") + nested_identifier_lvalue + Group(Literal("(").suppress() + Optional(identifier + ZeroOrMore(Literal(",").suppress() + identifier)) + Literal(")").suppress() ) + code
method_declaration_qml.setParseAction(handle_method_declaration)

behavior_declaration = Keyword("Behavior").suppress() + Keyword("on").suppress() + nested_identifier_lvalue_list + Literal("{").suppress() + component_declaration + Literal("}").suppress()
behavior_declaration.setParseAction(handle_behavior_declaration)

scope_declaration = behavior_declaration | signal_declaration | alias_property_declaration | enum_property_declaration | property_declaration | id_declaration | assign_declaration | assign_component_declaration | component_declaration | method_declaration | method_declaration_qml | assign_scope
component_scope = (Literal("{").suppress() + Group(ZeroOrMore(scope_declaration)) + Literal("}").suppress())

component_declaration << (component_type + component_scope)
component_declaration.setParseAction(handle_component_declaration)

def handle_unary_op(s, l, t):
	#print "EXPR", t
	return " ".join(t[0])
def handle_binary_op(s, l, t):
	#print "EXPR", t
	return " ".join(t[0])
def handle_ternary_op(s, l, t):
	#print "EXPR", t
	return " ".join(t[0])


expression_array = Literal("[") + Optional(expression + ZeroOrMore(Literal(",") + expression)) + Literal("]")
def handle_expression_array(s, l, t):
	return "".join(t)
expression_array.setParseAction(handle_expression_array)

expression_definition = (QuotedString('"', escChar='\\', unquoteResults = False, multiline=True) | \
	QuotedString("'", escChar='\\', unquoteResults = False, multiline=True) | \
	Keyword("true") | Keyword("false") | Word("01234567890+-.") | builtin | function_call | nested_identifier_rvalue | enum_value | expression_array)

expression_ops = infixNotation(expression_definition, [
	('!', 1, opAssoc.RIGHT, handle_unary_op),
	('%', 2, opAssoc.LEFT, handle_binary_op),
	('*', 2, opAssoc.LEFT, handle_binary_op),
	('/', 2, opAssoc.LEFT, handle_binary_op),
	('+', 2, opAssoc.LEFT, handle_binary_op),
	('-', 2, opAssoc.LEFT, handle_binary_op),
	('-', 1, opAssoc.RIGHT, handle_unary_op),
	('&&', 2, opAssoc.LEFT, handle_binary_op),
	('||', 2, opAssoc.LEFT, handle_binary_op),
	(('?', ':'), 3, opAssoc.RIGHT, handle_ternary_op),

	('<',	2, opAssoc.LEFT, handle_binary_op),
	('<=',	2, opAssoc.LEFT, handle_binary_op),
	('>',	2, opAssoc.LEFT, handle_binary_op),
	('>=',	2, opAssoc.LEFT, handle_binary_op),
	('==',	2, opAssoc.LEFT, handle_binary_op),
	('!=',	2, opAssoc.LEFT, handle_binary_op),
	('===',	2, opAssoc.LEFT, handle_binary_op),
	('!==',	2, opAssoc.LEFT, handle_binary_op),
])
expression_ops.setParseAction(lambda s, l, t: "(%s)" %t[0])

expression << expression_ops

expression_list_definition = expression + ZeroOrMore(Literal(",") + expression)
expression_list << Optional(expression_list_definition)

source = component_declaration
source = source.ignore(cStyleComment)
source = source.ignore(dblSlashComment)
#source.setDefaultWhitespaceChars(" \t\r\f")
ParserElement.enablePackrat()

def parse(data):
	tree = source.parseString(data, parseAll = True)
	return tree
