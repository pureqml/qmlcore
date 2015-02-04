from pyparsing import *

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
assign_component_declaration = nested_identifier + Literal(":").suppress() + component_declaration

property_declaration = ((Keyword("property") + type + identifier + Literal(":").suppress() + expression) | \
	(Keyword("property") + type + identifier)) + expression_end

assign_scope_declaration = identifier + Literal(":").suppress() + expression + expression_end
assign_scope = nested_identifier + Literal("{").suppress() + Group(OneOrMore(assign_scope_declaration)) + Literal("}").suppress()

method_declaration = nested_identifier + Literal(":").suppress() + code

scope_declaration = Group(event_declaration | property_declaration | assign_declaration | assign_component_declaration | component_declaration | method_declaration | assign_scope)
component_scope = (Literal("{").suppress() + Group(ZeroOrMore(scope_declaration)) + Literal("}").suppress())

component_declaration << Group(component_type + component_scope)

expression_definition = (dblQuotedString | Keyword("true") | Keyword("false") | Word("01234567890+-.") | nested_identifier)
expression << expression_definition

source = OneOrMore(component_declaration)
source = source.ignore(cStyleComment)
source = source.ignore(dblSlashComment)
#source.setDefaultWhitespaceChars(" \t\r\f")
