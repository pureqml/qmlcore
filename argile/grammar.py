from pyparsing import *

component_type = Word(srange("A-Z"), alphanums)
identifier = Word(srange("a-z"), alphanums)
nested_identifier = Word(srange("a-z"), alphanums + ".")

event_declaration = Keyword("event") + identifier
expression_end = Literal(";").suppress()

expression = Forward()
expression_definition = (dblQuotedString | nested_identifier | Keyword("true") | Keyword("false"))
expression << (expression_definition + expression_end)

assign_declaration = identifier + Literal(":").suppress() + expression

property_declaration = Keyword("property") + identifier + identifier + Optional(Keyword(":") + expression)

inscope_declaration = event_declaration | assign_declaration | property_declaration

component_scope = Literal("{").suppress() + Group(ZeroOrMore(inscope_declaration)) + Literal("}").suppress()

component_declaration = Group(component_type + component_scope)

source = OneOrMore(component_declaration)
source = source.ignore(cStyleComment)
source = source.ignore(dblSlashComment)
source.setDefaultWhitespaceChars(" \t\r\f")
