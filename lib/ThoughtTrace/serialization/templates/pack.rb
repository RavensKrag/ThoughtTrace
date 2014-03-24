module ThoughtTrace
	class CLASS_NAME < Entity


def pack
	BODY {
		strip_comments
		reverse_assignment
		extraction_from_initialization
		
		replace_object_with_self
	}.reverse!
	
	return ARGS
end



end
end