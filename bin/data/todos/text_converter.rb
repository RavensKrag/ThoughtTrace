require 'rubygems'
require 'chipmunk'

x = "
improve mouseover state
May want to change how text resizes horizontally on center drag
\"If Style is created without a parent, it's parent should default to the baseline style\"
Figure out how to change Entities when style properties are altered
edit space point query
is there any reason to keep Component?
TODO: implement screen space to world space conversion in accordance with new systems
TODO: custom subclass of Hash to deal with action bindings
TODO: Ruby methods are objects. Apply structure to Action
TODO: consider different views of same space
TODO: change the way corner resize of rectangles works
\"TODO: fix short circuiting min by, and the entities/text.rb -> Text#nearest_character_boundary() optimization that it messes up\"
TODO: create action to delete a whole Entity
TODO: remove Object delegate metaprogramming monkeypatch
TODO: make sure an empty project can be loaded
"

y = x.each_line.to_a; y.shift

z = y.collect{|x| x.chomp}


height = 23
p = CP::Vec2.new(2860.416666666667,-691.6423163884722)

z.each_with_index do |x,i|
	puts "ThoughtTrace::Text,Lucida Sans Unicode,#{p.x},#{p.y+height*i},#{height},#{x}"
end