module ThoughtTrace

class Space


class GroupList
	include Packageable
	
	def initialize(space)
		@space = space
		
		@storage = Array.new
	end
	
	def add(object)
		@storage.push object
		
		@space.add_shape(object[:physics].shape)
		@space.add_body(object[:physics].body)
	end
	
	def delete(object)
		@storage.delete(object)
		
		@space.remove_shape(object[:physics].shape)
		@space.remove_body(object[:physics].body)
	end
	
	def empty?
		@storage.empty?
	end
	
	def each(&block)
		@storage.each &block
	end
	
	include Enumerable
	
	
	def gc
		@storage.delete_if &:gc?
	end
end



end
end