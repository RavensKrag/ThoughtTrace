module TextSpace
	class Space
		def initialize(filepath)
			@objects =	if File.exist? filepath
							YAML.load_file(filepath)
						else
							[]
						end
			
			p @objects
		end
		
		def update
			@objects.each do |obj|
				obj.update
			end
		end
		
		def draw
			@objects.each do |obj|
				obj.draw
			end
		end
		
		def empty?
			@objects.empty?
		end
		
		def <<(object)
			@objects << object
		end
		
		def push(*args)
			@objects.push *args
		end
		
		def delete_if_empty(object)
			@objects.delete object if object.string == nil || object.string.strip.empty?
		end
		
		# Clean up unnecessary objects
		# ie, empty strings
		def gc
			@objects.delete_if do |obj|
				obj.string == nil || obj.string.strip.empty?
			end
		end
		
		
	#    ____                  _          
	#   / __ \__  _____  _____(_)__  _____
	#  / / / / / / / _ \/ ___/ / _ \/ ___/
	# / /_/ / /_/ /  __/ /  / /  __(__  ) 
	# \___\_\__,_/\___/_/  /_/\___/____/  
	# Delegate to all queries provided by SelectionQueries module
	# prefer delegation over having to expose @objects variable
		def bb_query(bb)
			return SelectionQueries.bb_query @objects, bb
		end
		
		def object_at(position)
			return SelectionQueries.point_query @objects, position
		end
	
	
	# 	   _____           _       ___             __  _           
	# 	  / ___/___  _____(_)___ _/ (_)___  ____ _/ /_(_)___  ____ 
	# 	  \__ \/ _ \/ ___/ / __ `/ / /_  / / __ `/ __/ / __ \/ __ \
	# 	 ___/ /  __/ /  / / /_/ / / / / /_/ /_/ / /_/ / /_/ / / / /
	# 	/____/\___/_/  /_/\__,_/_/_/ /___/\__,_/\__/_/\____/_/ /_/ 
		class << self
			def load(filepath)
				return Space.new filepath
			end
		end
		
		def dump(filepath)
			filepath = File.join(File.dirname(__FILE__), "data", "save_data.yml")
			
			File.open(filepath, "w") do |f|
				f.puts YAML::dump(@objects)
			end
		end
	end
end