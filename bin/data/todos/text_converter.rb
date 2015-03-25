require 'rubygems'
require 'chipmunk'

x = "
image Entity type
non-destructive crop of Images
multi-item mask (not just images)
load initial prototype config from base config for entire library
action - input - query
action - input - constraint
sharper font scaling
input system - how inputs trigger actions
diagram showing all actions
collision handler system
mulitple phases of text input
TODO: create graph relating files to subsystems
list ALL the THINGS
TODO: adjust body masses and collisions
NOTE: notice that the prototype for Text keeps getting updated
"

y = x.each_line.to_a; y.shift

z = y.collect{|x| x.chomp}


height = 23
p = CP::Vec2.new(1393.75,213.56601694486142)

z.each_with_index do |x,i|
	puts "ThoughtTrace::Text,Lucida Sans Unicode,#{p.x},#{p.y+height*i},#{height},#{x}"
end