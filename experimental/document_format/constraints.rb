module ThoughtTrace



# each constraint should be a function that accepts a number of entity objects as parameters
# 
# This collection is a class, and not a module,
# so that the active constraint list and associated parameters
# can be stored within an instance of this class
class Constraints
	def initialize
		# sorting the elements in this list will effect the execution order of the constraints
		# that may be necessary,
		# the same way that it is often necessary
		# to re-order the modifier stack in Blender 
		@active_list = Array.new
		# [function, e1, e2, ..., eN]
	end
	
	
	
	# oh wait, if the constraints need a draw phase, maybe they are objects?
	# can't exactly have two callbacks from one function
	# would have to attach two methods to one object or something like that
	
	def update
		@active_list.each do |args|
			self.call *args
		end
	end
	
	def draw
		
	end
	
	
	
	
	
	def foo(a, b)
		
	end
end


end