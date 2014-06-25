module ThoughtTrace
	module Actions


# Stubs out all required callbacks
# doesn't actually descend from any sort of Action,
# but you should be coding based on interface anyway
class NullAction
	def initialize(*args)
		
	end
	
	def setup(point)
		puts "setup null"
	end
	
	def update(point)
		puts "update null"
	end
	
	def cleanup(point)
		puts "cleanup null"
	end
	
	def cancel
		puts "cancel null"
	end
end



end
end