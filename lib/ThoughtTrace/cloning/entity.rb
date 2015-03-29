module ThoughtTrace


class Entity
	def clone
		# could easily just use the serialization facilities
		# to generate a new Entity with the same properties as an existing one
		# would be similar to duplicating a line in the save file.
		# But because of how dump / load are implemented
		# (independent of disk write/read format)
		# it's easy to do the entire process in memory
		
		data = self.pack
		other = self.class.unpack(*data)
		
		
		# # link to the same style component
		# component = self[:style]
		# other.delete_component(component.class.interface)
		# other.add_component(component)
		
		
		
		# # link to the existing cascades, but create new component
		# other[:style].mirror self[:style]
		
		
		
		# link the same style objects, but create new cascades and component
			# not sure this will work. (it works manually, but not in general like this)
			# any correct implementation would have to chain,
			# but when performing this method,
			# you would take a Primary Style, and slot it into Cascade B.
			# If you repeat the process, you would copy both the Primary of B, and the Style in slot 1 of B into Cascade C
			# Repeating again, you would have to copy 3 styles from C to D
			# (the increasing nature means you don't make exact copies, which leads to bloat and waste)
		
		
		
		# # deep copy of all style data
		# component = self[:style].clone
		# other.delete_component(component.class.interface)
		# other.add_component(component)
		
		
		return other
	end
end



end