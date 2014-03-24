# src http://stackoverflow.com/questions/9025277/how-do-i-extract-a-sub-hash-from-a-hash
# (possibly useful for extracting subsets of Actions/Components out of Entity objects when resolving dependencies)
class Hash
	def extract_subhash(*extract)
		h2 = self.select{|key, value| extract.include?(key) }
		self.delete_if {|key, value| extract.include?(key) }
		h2
	end
	
	# Modification of the above which only returns the selection,
	# it does not delete it from the original hash.
	def subhash(*extract)
		h2 = self.select{|key, value| extract.include?(key) }
		h2
	end
end
