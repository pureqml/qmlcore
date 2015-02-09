def scan(text):
	str_context = False
	escape = False
	c_comment = False
	cpp_comment = False
	begin = 0
	invalid = []
	for i in xrange(0, len(text)):
		c = text[i]
		if escape:
			escape = False
			continue

		if cpp_comment:
			if c == "\n":
				cpp_comment = False
				end = i
				invalid.append((begin, end))
				#print "cpp-comment", (begin, end), text[begin:end]
			continue

		if c_comment:
			if text[i: i + 2] == "*/":
				end = i + 2
				c_comment = False
				invalid.append((begin, end))
				#print "c-comment", begin, end, text[begin:end]
			continue

		if str_context and c == "\\":
			escape = True
			continue

		if c == "\"" or c == "'":
			str_context = not str_context
			if str_context:
				begin = i
			else:
				end = i + 1
				invalid.append((begin, end))
				#print "string at %d:%d -> %s" %(begin, end, text[begin:end])
			continue

		if str_context:
			continue

		if text[i: i + 2] == "//":
			begin = i
			cpp_comment = True

		if text[i: i + 2] == "/*":
			c_comment = True
			begin = i


	return text, invalid

def process(text, registry):
	text, invalid = scan(text)
	print invalid
	return text
