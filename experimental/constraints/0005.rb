module Constraints

class Constraint
	class << self
		def curry(seed)
			klass = self
			
			return Constraints::CurryingWrapper.new(klass, seed)
		end
	end
end

# NOTE: this process only works one-level deep. You can only reduce a constraint of two arguments, into a constraint of 1 argument. This should not be a problem within the constraint system, but it is far less powerful than true currying.
class CurryingWrapper
	def initialize(klass, seed)
		@klass = klass
		@seed = seed
	end
	
	# finish up the initialization
	def new(entity)
		@klass.new(@seed, entity)
	end
	
	# NOTE: the class info and #inspect data should be in a similar format to metaclass data
	# the metaclass of a class called MailTruck looks like this
	# #<Class:#<MailTruck:0x81cfb94>>
	# so maybe for a constraint called SyncHeight,
	# something like this?
	# #<Constraint:#<SyncHeight:0x81cfb94>>
end


end



# example
x = Constraints::Constraint.curry(ref)
x.new(e2)

y = Constraints::Constraint.new(e1, e2)
# notice how the interface for making a new instance from a curryed object
# is the same as the interface for initializing a new Constraint right off the class.