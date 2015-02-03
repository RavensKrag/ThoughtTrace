class EntityMarker
	def initialize
		# create dummy entity object
		# null object pattern for when the marker has nothing to track
		@@dummy ||= x
	end
	
	def update
		# move position to match the position of the tracked Entity, if any
	end
	
	def draw
		
	end
	
	
	
	
	def bind_to(entity)
		
	end
end