module ThoughtTrace
	class Entity
		module Actions


# Actually, the base Action is itself sort of a NullObject,
	# as it just stubs out all necessary callbacks.
	# 
	# This allows for easy debug outputs though.
class NullAction < Entity::Actions::Action
	def initialize(*args)
		super(*args)
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
		puts "cancel nil"
		super()
	end
end



end
end
end