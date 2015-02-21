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

def handle_method_declaration(s, l, t):
	return lang.Method(t[0], t[1], t[2])

def handle_assignment_scope(s, l, t):
	#print "assignment-scope>", t
	return lang.AssignmentScope(t[0], t[1])

def handle_nested_identifier_rvalue(s, l, t):
	#print "nested-id>", t
	path = t[0].split(".")
	if path[0] == "model":
		return "this._get('model').%s" %".".join(path[1:])
	path = ["_get('%s')" %x for x in path]
	return "this.%s" % ".".join(path)

def handle_id_declaration(s, l, t):
	#print "id>", t
	return lang.IdAssignment(t[0])

def handle_behavior_declaration(s, l, t):
	#print "behavior>", t
	return lang.Behavior(t[0], t[1])

def handle_signal_declaration(s, l, t):
	return lang.Signal(t[0], t[1])

type = Word(alphas, alphanums)
component_type = Word(srange("[A-Z]"), alphanums)
identifier = Word(srange("[a-z]"), alphanums)

optional_argument_list = Group(Optional(Literal("(").suppress() + identifier + ZeroOrMore(Literal(",").suppress() + identifier) + Literal(")").suppress() ))

code = originalTextFor(nestedExpr("{", "}", None, None))

nested_identifier_lvalue = Word(srange("[a-z]"), alphanums + ".")

nested_identifier_rvalue = Word(srange("[a-z]"), alphanums + ".")
nested_identifier_rvalue.setParseAction(handle_nested_identifier_rvalue)

expression_end = Literal(";").suppress()

signal_declaration = Keyword("signal").suppress() + identifier + optional_argument_list + expression_end
signal_declaration.setParseAction(handle_signal_declaration)

id_declaration = Keyword("id").suppress() + Literal(":").suppress() + identifier + expression_end
id_declaration.setParseAction(handle_id_declaration)

expression = Forward()
component_declaration = Forward()

assign_declaration = nested_identifier_lvalue + Literal(":").suppress() + expression + expression_end
assign_declaration.setParseAction(handle_assignment)

assign_component_declaration = nested_identifier_lvalue + Literal(":").suppress() + component_declaration
assign_component_declaration.setParseAction(handle_assignment)

property_declaration = (((Keyword("property").suppress() + type + identifier + Literal(":").suppress() + expression) | \
		(Keyword("property").suppress() + type + identifier)) + expression_end) | \
	(Keyword("property").suppress() + type + identifier + Literal(":").suppress() + component_declaration) \

alias_property_declaration = Keyword("property").suppress() + Keyword("alias").suppress() + identifier + Literal(":").suppress() + nested_identifier_lvalue + expression_end
alias_property_declaration.setParseAction(handle_alias_property_declaration)

property_declaration.setParseAction(handle_property_declaration)

assign_scope_declaration = identifier + Literal(":").suppress() + expression + expression_end
assign_scope_declaration.setParseAction(handle_assignment)
assign_scope = nested_identifier_lvalue + Literal("{").suppress() + Group(OneOrMore(assign_scope_declaration)) + Literal("}").suppress()
assign_scope.setParseAction(handle_assignment_scope)

method_declaration = nested_identifier_lvalue + optional_argument_list + Literal(":").suppress() + code
method_declaration.setParseAction(handle_method_declaration)

behavior_declaration = Keyword("Behavior").suppress() + Keyword("on").suppress() + identifier + Literal("{").suppress() + component_declaration + Literal("}").suppress()
behavior_declaration.setParseAction(handle_behavior_declaration)

scope_declaration = behavior_declaration | signal_declaration | alias_property_declaration | property_declaration | id_declaration | assign_declaration | assign_component_declaration | component_declaration | method_declaration | assign_scope
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

expression_definition = (dblQuotedString | Keyword("true") | Keyword("false") | Word("01234567890+-.") | nested_identifier_rvalue)

expression_ops = infixNotation(expression_definition, [
	('*', 2, opAssoc.LEFT, handle_binary_op),
	('/', 2, opAssoc.LEFT, handle_binary_op),
	('+', 2, opAssoc.LEFT, handle_binary_op),
	('-', 2, opAssoc.LEFT, handle_binary_op),
	('-', 1, opAssoc.RIGHT, handle_unary_op),
	('&&', 2, opAssoc.LEFT, handle_binary_op),
	('||', 2, opAssoc.LEFT, handle_binary_op),
	(('?', ':'), 3, opAssoc.RIGHT, handle_ternary_op),
])

expression << expression_ops

source = component_declaration
source = source.ignore(cStyleComment)
source = source.ignore(dblSlashComment)
#source.setDefaultWhitespaceChars(" \t\r\f")
ParserElement.enablePackrat()

def parse(data):
	tree = source.parseString(data, parseAll = True)
	return tree
