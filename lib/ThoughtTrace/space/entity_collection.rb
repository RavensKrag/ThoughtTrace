module ThoughtTrace

class Space


# NOTE: UI stuff can take advantage of the fact that only one Entity is drawn at each z-index. This means, if you draw a UI overlay at the same index, it will only potentially conflict with one item. In Gosu, there shouldn't be z-fighting even then.
	# But in other rendering systems, you could instead use 'commodore style numbering', and assign automatic indicies like 10, 20, 30, 40, etc, so that there is a guaranteed gap between them where UI things can go.
	# would need to figure out just how much gap is appropriate.
class EntityList < ThoughtTrace::IndexedCollection
	include Packageable
	
	def add(object)
		# raise "Physics component on #<#{object.class}:#{object.object_id}> not found." unless object.respond_to? :physics
		
		unless object[:physics]
			msg = <<-ERROR_MESSAGE
				
				#{object.class} does not have a Physics component
			ERROR_MESSAGE
			
			raise msg.multiline_lstrip
		end
		
		super(object)
		
		@space.add_shape(object[:physics].shape)
		@space.add_body(object[:physics].body)
	end
	
	def delete(object)
		super(object)
		
		@space.remove_shape(object[:physics].shape)
		@space.remove_body(object[:physics].body)
	end
	
	def gc
		# remove
		self.delete_if do |x|
			x.gc?
		end
		
		# compress index range
		super()
	end
end



end
end