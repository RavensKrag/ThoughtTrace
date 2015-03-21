x = "
selection - group - group actions - disambiguation
group system - mark and select
clear selection on non-selection-altering action?
groups / copy group
pick group / abstraction layer with scroll wheel
TODO: consider ActionFactory#get_type for groups
all groups should start off as selections
NOTE: constraint Visualizations and Groups now both use Style Components
component serialization - non-Entity types
implement loading of visualizations
NOTE: each Constraint Pair needs a separate Visualization object
Visualizations need to save Style component data
rethink how Style data is saved
what do you do about deleting Entity markers?
document format - multiple documents
nested document
nested document - cascade to resolve action
layers of interaction (for UI etc)
TODO: limit camera drawing
TODO: camera layers
TODO: camera should be spatial data
constraint creation action
constraint / constraint package maker
API to create / delete whole Constraint Packages
add / remove whole entities (including components)
Entity delete mechanism
input system overhaul
input binding - no-target actions
input binding - mode-specific UI interaction
notes program - tree overview - text field w/ spell check
multi-line text input
how do you bind mouse click actions for a Entity?
action system documentation update
TODO: rewrite 'empty space actions' as 'zero target actions'
move on to queries
implement prefabs
implement text split-rip action
try to implement something like text caret again
TODO: awkward to see the text caret appear quickly - then vanish
locking things in place
attachment point markers
query object serialization
bind query object to query component
how are Queries shown visually?
implement text search of all Text objects
multiple editor views
short-circuiting min_by -> really a lazy min_by
TODO: make sure Physics#center works with all collision shapes ASAP
shrink rect resize margins as object shrinks
"

y = x.each_line.to_a; y.shift

z = y.collect{|x| x.chomp}


z.each_with_index do |x,i|
	puts "ThoughtTrace::Text,Lucida Sans Unicode,0.0,#{23*i},22.97394578559605,#{x}"
end