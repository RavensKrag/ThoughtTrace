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
	end
	
	def delete(object)
		@storage.delete(object)
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