# wraps the string class, so I don't have to pollute String with monkey patches
# that only apply to the build system
# (I think it's more like just part of the system at that)

# Contains manipulations to turn the 'load' body into the 'dump' body

# All methods should take no arguments, manipulate @string, and return self
module ThoughtTrace



class StringWrapper
	attr_reader :string
	
	def initialize(string, obj, args)
		@string = string
		
		@object = obj
		@args = args
	end
	
	
	def strip_comments
		@string = @string.strip_comment
		
		return self
	end
	
	# x = a --> a = x
	def reverse_assignment
		@string = @string.split('=').collect{ |i| i.strip }.reverse.join(' = ')
		
		return self
	end
	
	# format: Class.new arg1, arg2, ..., argn = var
	# result: arg = var.arg
	def extraction_from_initialization
		if @string.include? '.new'
			
			parts = @string.split('=').collect{ |i| i.strip }
			# ['Class.new arg1, arg2, ..., argn', 'var']
			
			
			# split up into three segments
			class_name = parts[0].split('.new')[0].strip # 'Class'
			arg_blob   = parts[0].split('.new')[1].strip # 'arg1, arg2, ..., argn'
			var_name   = parts[1]                        # 'var'
			
			
			# take all arguments,
			# create one line for each argument that needs to be extracted from the object
			lines =	arg_blob.split(/,\s*/).collect do |arg|
						# accessor should not repeat the name of the variable
						accessor =	arg.sub(/#{var_name}_/, '')
						
						"#{arg} = #{var_name}.#{accessor}"
					end
			
			# merge the lines into one blob that will be appended to file
			@string = lines.join("\n")
				# WARNING: this means that the Array containing all lines will not necessarily have one array entry per line, as this blob could have multiple lines encoded into one string.
			
		end
		
		return self
	end
	
	# OBJECT is the thing being examined
	# this replaces it with a reference to self
	# but the replacement is not on the OBJECT tag,
	# but on variables within the BODY text that have the same name
	def replace_object_with_self
		# NOTE: be careful not to replace all instances of the OBJECT name, just the variable names
		
		# consider the case when there's an equals sign
		# foo = OBJECT.some.other.things		(not necessarily dot operator delineated)
		@string.gsub!(/#{@object}(?:)/, 'self')
		
		return self
	end
	
	
	# blank out lines with bang commands
	def ignore_bang_commands
		if @string =~ /.*!(?:\(.*\))?/  # some_text!(foo) <-- parens and contents optional
			@string = ''
		end
		
		return self
	end
end


end