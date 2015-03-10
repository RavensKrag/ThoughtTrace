module ThoughtTrace
	module Constraints


# stores full constraint packages,
# with visualizations and markers, and entity bindings 
class PackageCollection
	# convert this collection to and from a nested array structure
	def pack
		# constraint package format:
			# marker_a              entity id   0
			# marker_b              entity id   1
			# a                     entity id   2
			# b                     entity id   3
			# constraint_object     UUID        4
			# visualization         'V' + id    5
			# visible?              boolean     6
		
		
		# NOTE: using id numbers for visualizations introduces weird confusion. up to this point, the only 'numbers' in the serialization format were all entity IDs. If you use indicies in an array to also refer to visualization object data, then there needs to be some sort of disambiguation.
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
			package = ThoughtTrace::Constraints::Package.unpack(row)
			
			self.add(package)
		end
		
		
		return self
	end
end



end
end