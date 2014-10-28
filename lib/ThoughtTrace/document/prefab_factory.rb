module ThoughtTrace



# Stealing the name "prefab" from Unity because I can't think of a better name for than concept
# 
# Prefabs are principally built in the graphical view
# out of other, more basic entity types.
# However, they can also have additional behavior defined by writing code.
# Prefabs are classes, and thus can be dynamically altered by code at runtime.
# 
# The classes are stored in this collection, rather than in constants in a module
# so that the prefab code can be reloaded at runtime without warnings or redefinition errors.
# (consider a live-coding-ish environment where new code can be written full restarts)
class PrefabFactory
	def initialize
		
	end
	
	
	
	
	
	def dump(path_to_folder)
		
	end
	
	
	def self.load(path_to_folder)
		
	end
end


end