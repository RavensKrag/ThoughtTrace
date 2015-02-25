module ThoughtTrace
	module Constraints



class Collection
	def initialize
		@list = Array.new
	end
	
	
	# currently assuming constraints are method objects
	# yes. method. objects.
	# take the containing object and call #method(name) to retrieve the method object
	def add(package)
		# package could be a ConstraintPackage, or it could just be a raw Constraint
		# (the latter case is an optimization, not a "normal" thing)
		@list << package
	end
	
	def update
		@list.each do |package|
			package.update
		end
	end
	
	def draw
		@list.each do |package|
			# raw Constraint objects don't have visualizations, so not all objects will #draw
			package.draw if package.respond_to? :draw
		end
	end
	
	
	
	
	def each(&block)
		@list.each(&block)
	end
	
	include Enumerable
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	# convert this collection to and from a nested array structure
	# NOTE: this returns TWO collections, rather than the typical ONE you get from #pack
	# (that's really weird and should probably get changed)
	
	def pack
		# constraint package format:
			# marker_a              entity id   0
			# marker_b              entity id   1
			# a                     entity id   2
			# b                     entity id   3
			# constraint_object     UUID        4
			# visualization         ???         5
			# visible?              boolean     6
		
		
		# NOTE: this introduces weird confusion. up to this point, the only 'numbers' in the serialization format were all entity IDs. If you use indicies in an array to also refer to visualization object data, then there needs to be some sort of disambiguation.
			# you could use UUIDs here as well, and I think that would work just fine.
				# UUIDs were created to allow for ID assignment in distributed applications, where different hosts could not talk to one another.
				# thus, it should work to use UUIDs here, and not check for collisions between these two subsystems
			# the visualization objects are also quite similar to the constraint object, in that all instances of a class are intended to be very very similar
		
		# instead of just using a number, add a "V" as in "visualization"
		# in order to distinguish these indicies from the ones that reference Entities
		
		
		@list.collect do |package|
			package.pack
		end
	end
	
	
	def unpack(data)
		data.each do |row|
			package = ThoughtTrace::Constraints::Package.new(nil,nil)
			# can set the initial values to 'nil' because we're just going to unpack data
			# we just need to pass _something_ into the initializer
			package.unpack(row)
			
			self.add(package)
		end
		
		
		return self
	end
end


end
end