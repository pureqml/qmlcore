from pyparsing import *
import lang

def handle_component_declaration(s, l, t):
	#print "component>", t
	return lang.Component(t[0])

def handle_assignment(s, l, t):
	#print "assignment>", t
	return lang.Assignment(t[0], t[1])

def handle_property_declaration(s, l, t):
	#print "property>", t
	default = t[2] if len(t) > 2 else None
	return lang.Property(t[0], t[1], default)

def handle_method_declaration(s, l, t):
	#print "method>", t
	return lang.Method(t[0], t[1])

def handle_assignment_scope(s, l, t):
	#print "assignment-scope>", t
	return lang.AssignmentScope(t[0], t[1])

type = Word(alphas, alphanums)
component_type = Word(srange("[A-Z]"), alphanums)
identifier = Word(srange("[a-z]"), alphanums)
nested_identifier = Word(srange("[a-z]"), alphanums + ".")
code = originalTextFor(nestedExpr("{", "}", None, None))

expression_end = Literal(";").suppress()

event_declaration = Keyword("event") + identifier + expression_end

expression = Forward()
component_declaration = Forward()

assign_declaration = nested_identifier + Literal(":").suppress() + expression + expression_end
assign_declaration.setParseAction(handle_assignment)

assign_component_declaration = nested_identifier + Literal(":").suppress() + component_declaration
assign_component_declaration.setParseAction(handle_assignment)

property_declaration = ((Keyword("property").suppress() + type + identifier + Literal(":").suppress() + expression) | \
	(Keyword("property").suppress() + type + identifier)) + expression_end
property_declaration.setParseAction(handle_property_declaration)

assign_scope_declaration = identifier + Literal(":").suppress() + expression + expression_end
assign_scope_declaration.setParseAction(handle_assignment)
assign_scope = nested_identifier + Literal("{").suppress() + Group(OneOrMore(assign_scope_declaration)) + Literal("}").suppress()
assign_scope.setParseAction(handle_assignment_scope)

method_declaration = nested_identifier + Literal(":").suppress() + code
method_declaration.addParseAction(handle_method_declaration)

scope_declaration = Group(event_declaration | property_declaration | assign_declaration | assign_component_declaration | component_declaration | method_declaration | assign_scope)
component_scope = (Literal("{").suppress() + Group(ZeroOrMore(scope_declaration)) + Literal("}").suppress())

component_declaration << (component_type + component_scope)
component_declaration.setParseAction(handle_component_declaration)

expression_definition = (dblQuotedString | Keyword("true") | Keyword("false") | Word("01234567890+-.") | nested_identifier)
expression << expression_definition

source = component_declaration
source = source.ignore(cStyleComment)
source = source.ignore(dblSlashComment)
#source.setDefaultWhitespaceChars(" \t\r\f")

def parse(data):
	tree = source.parseString(data, parseAll = True)
	return tree
