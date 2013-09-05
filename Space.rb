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
		
		def object_at(position)
			# TODO: Should short circuit when selection becomes empty
			# TODO: Short circuit on selection size of 1? (Only after initial bb query)
			
			# Select objects under the mouse
			# If there's a conflict, get smallest one (least area)
			
			# There should be some other rule about distance to center of object
				# triggers for many objects of similar size?
				
				# when objects are densely packed, it can be hard to select the right one
				# the intuitive approach is to try to select dense objects by their center
			
			
			
			# TODO: Re-write as loop of sorting and testing selection size
			# removes "selection = selection.method" noise in defining sorts
			# better illustrates cyclical flow
			
			
			selection = @objects.select do |o|
				o.bb.contains_vect? position
			end
			
			selection.sort! do |a, b|
				a.bb.area <=> b.bb.area
			end
			
			# Get the smallest area values, within a certain threshold
			# Results in a certain margin of what size is acceptable,
			# relative to the smallest object
			selection = selection.select do |o|
				# TODO: Tweak margin
				size_margin = 1.8 # percentage
				
				first_area = selection.first.bb.area
				o.bb.area.between? first_area, first_area*(size_margin)
			end
			
			selection.sort! do |a, b|
				distance_to_a = a.bb.center.dist position
				distance_to_b = b.bb.center.dist position
				
				# Listed in order of precedence, but sort order needs to be reverse of that
				[a.bb.area, distance_to_a].reverse <=> [b.bb.area, distance_to_b].reverse
			end
			
			return selection.first
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