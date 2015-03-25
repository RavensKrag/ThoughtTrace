require 'rubygems'
require 'chipmunk'

x = "
TODO: track system - query style binding
TODO: track system development - serialization
\"so, what about things that apply data to certain entities?\"
NOTE: potential problems with propagating constraints
constraints on multiple objects
\"NOTE: space is trying to call #gc? on constraints, but method is not yet defined\"
TODO: list current constraint backend objects
BUG: object packer breaks when trying to generate pack/unpack for an object with a 0 arg init
\"Q: do you need to click on Constraints, not just markers?\"
TODO: all markers in a document should use the same visual style
\"TODO: make sure Action#update ticks the same frame as #press, otherwise there may be a one frame lag on single-tick actions (notably, spawn actions)\"
TODO: consider action factory / mouse action extraction system interaction with multiple spaces
TODO: polymorphic edit and resize
\"TODO: consider scrapping rect resize action, in favor of constraint-based control system\"
\"TODO: update rectangle resize #anchor_point to accept an argument, instead of mucking with state\"
TODO: action factory should not use ThoughtTrace::Queries::Query check
BUG: crash on marker move
NOTE: general debug flow
BUG: rect resize action counter-steering wrecks LimitHeight
TODO: consider inverting LimitHeight
\"TODO: track time per frame ms, and convert to hz\"
\"TODO: load up both a limiting and a propagating constraint, to test Action / Constraint interaction\"
"

y = x.each_line.to_a; y.shift

z = y.collect{|x| x.chomp}


height = 23
p = CP::Vec2.new(1356.2500000000002,-306.22564972180544)

z.each_with_index do |x,i|
	puts "ThoughtTrace::Text,Lucida Sans Unicode,#{p.x},#{p.y+height*i},#{height},#{x}"
end