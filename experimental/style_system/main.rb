#!/usr/bin/env ruby

path_to_file = File.expand_path(File.dirname(__FILE__))
Dir.chdir path_to_file

require './style'
require './cascading'



# Style object should have unique IDs
# those IDs should persists across sessions,
# they should be unique among all Style objects within the same space


# a style space holds all known Style objects
# many spaces can be initialized at one time,
# which can allow for namespacing
# (could alternatively use c-style prefix-namespacing on Style name if you would prefer)
# (though, I think it's always better to have an actual namespacing facility)

# Style objects are grouped into particular blobs.
# Blobs maintain cascade priority / searching for a particular property
# among multiple Style objects that are cascasding together to form a single, cohesive unit


class StyleSpace
	def initialize
		@collection = Hash.new
	end
	
	def add(style)
		id = generate_id(style)
		@collection[id] = style
	end
	
	def [](key)
		warn "no style currently exists with the name '#{key}'" unless @collection[key]
		
		@collection[key]
	end
	
	def []=(key, val)
		@collection[key] = val
	end
	
	
	private
	
	# TODO: generate IDs in a way that can persist across sessions
	def generate_id(style)
		return style.object_id
	end
end



space = StyleSpace.new
style = Style.new

# space.add "first", style
space["first"] = Style.new
space["second"] = Style.new
space["third"] = Style.new




cascade = CascadingStyleBlob.new
cascade.add space["first"]
cascade.add space["second"]
cascade.add space["third"]



# one one Style object in a space can have a given name
# if the Style is updated in one place, all other places will update as well
# (all references to one style via it's one common name point at the same data)