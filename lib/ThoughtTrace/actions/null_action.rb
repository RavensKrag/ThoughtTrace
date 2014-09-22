module ThoughtTrace
	module Actions


# Stubs out all required callbacks
# doesn't actually descend from any sort of Action,
# but you should be coding based on interface anyway
class NullAction < BaseAction
	initialize_with :entity
	
	def setup(point)
		puts "#{@entity} -> setup null "
	end
	
	def update(point)
		puts "#{@entity} -> update null"
	end
	
	def cleanup(point)
		puts "#{@entity} -> cleanup null"
	end
	
	def cancel
		puts "#{@entity} -> cancel null"
	end
end



end
end