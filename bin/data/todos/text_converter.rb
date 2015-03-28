require 'rubygems'
require 'chipmunk'

x = "
many spawn actions
think ahead into selection
editor workflow versus core coding backend interface
why did I need queries the last time I wanted queries?
insert feels like a special kind of move
are insert and join the same thing?
TODO: consider action factory / mouse action extraction system interaction with multiple spaces
TODO: consider overhaul of input system
button up /  down
specific accelerator combo vs any accelerators
"

y = x.each_line.to_a; y.shift

z = y.collect{|x| x.chomp}


height = 23
p = CP::Vec2.new(1814.5833333333333,-941.6423163884722)

z.each_with_index do |x,i|
	puts "ThoughtTrace::Text,Lucida Sans Unicode,#{p.x},#{p.y+height*i},#{height},#{x}"
end