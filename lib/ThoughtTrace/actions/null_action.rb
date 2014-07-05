module ThoughtTrace
	module Actions


# Stubs out all required callbacks
# doesn't actually descend from any sort of Action,
# but you should be coding based on interface anyway
class NullAction < BaseAction
	def initialize(*args)
		@target = args.last
		@target ||= "empty space"
	end
	
	def setup(point)
		puts "#{@target} -> setup null "
	end
	
	def update(point)
		puts "#{@target} -> update null"
	end
	
	def cleanup(point)
		puts "#{@target} -> cleanup null"
	end
	
	def cancel
		puts "#{@target} -> cancel null"
	end
end



end
end