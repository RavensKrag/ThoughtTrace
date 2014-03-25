module ThoughtTrace
	class CLASS_NAME < Entity


def pack
	BODY {
		strip_comments
		reverse_assignment
		extraction_from_initialization
		
		replace_object_with_self
		
		process_bang_command_with_arguments
		ignore_bang_commands
		
		special_case_property_substitution
	}.reverse!.strip_blank_lines!
	
	return ARGS
end



end
end