module ThoughtTrace


class Entity
	def clone
		# could easily just use the serialization facilities
		# to generate a new Entity with the same properties as an existing one
		# would be similar to duplicating a line in the save file.
		# But because of how dump / load are implemented
		# (independent of disk write/read format)
		# it's easy to do the entire process in memory
		
		data = self.dump
		other = self.class.load(*data)
		
		return other
	end
end



end