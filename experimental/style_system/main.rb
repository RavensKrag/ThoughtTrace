#!/usr/bin/env ruby

path_to_file = File.expand_path(File.dirname(__FILE__))
Dir.chdir path_to_file

require './style'
require './cascading'
require './color'



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

def test(cascade, properties)
	properties.each do |property|
		puts "#{property}: #{cascade[property]}"
	end
	puts "\n"
end



space = StyleSpace.new
style = Style.new

# space.add "first", style
space["first"] = Style.new
space["second"] = Style.new
space["third"] = Style.new



space["first"][:color] = 'black'
space["second"][:color] = 'blue'


space['third'][:size] = '2x3'


space['second'][:link] = 'google.com'



cascade = CascadingStyleBlob.new
cascade.add space["first"]
cascade.add space["second"]
cascade.add space["third"]




# make sure properties can still change after the objects have been set to the cascade container
space["third"][:color] = 'blue'


# changing properties in the middle of the cascade doesn't change anything,
# even though the definition is coming later
# (this is what I want)
space["second"][:color] = 'red'





# test to make sure cascade works as expected
test cascade, [:color, :size, :link]








# re-order the cascade, and watch the changes happen
cascade.raise space["third"] # 'third' moves up one slot. order: ['first', 'third', 'second']
# 'second' now has the priority

test cascade, [:color, :size, :link]







# re-order the cascade, and watch the changes happen
cascade.lower space["first"], by:2 # order: ['third', 'second', 'first']
# 'first' now has the priority


test cascade, [:color, :size, :link]














require 'gosu'

color = Gosu::Color.argb 0xffAABBCC
data = color.pack
p data.to_s 16

x = Gosu::Color.unpack data
p x
puts x == color

puts "\n\n"





require 'yaml'

data = [
	{
		:source_file => "__FILE__",
		:pallet_name => "name"
	},
	[:foo, :bas, :bar]
]
puts data.to_yaml
