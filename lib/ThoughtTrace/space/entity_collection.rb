module ThoughtTrace

class Space


class EntityList < IndexedCollection
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