# wraps the string class, so I don't have to pollute String with monkey patches
# that only apply to the build system
# (I think it's more like just part of the system at that)

# Contains manipulations to turn the 'load' body into the 'dump' body

# All methods should take no arguments, manipulate @string, and return self
module ThoughtTrace



class StringWrapper
	attr_reader :string
	
	def initialize(string)
		@string = string
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
						"#{arg} = #{var_name}.#{arg}"
					end
			
			# merge the lines into one blob that will be appended to file
			@string = lines.join("\n")
				# WARNING: this means that the Array containing all lines will not necessarily have one array entry per line, as this blob could have multiple lines encoded into one string.
			
			return self
		end
	end


end


end