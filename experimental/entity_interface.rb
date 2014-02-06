x = Entity.new
x.respond_to? :move

# no, try duck typing

x.move # action verbs

# better

x.components[:physics] # ugly, and implies Hash collection
x.physics	# nouns?
x.rendering	# gerunds?
# maybe components are just non-verbs?
# I suppose they're not adjectives either
# maybe "object words" vs "action verbs"




x.send(:move).press
x.actions[:move].press
x.move.press

x.actions.add Split.new
x.add_action :split, :actions => [:new, :move], :components => [:physics]




:resize => ResizeRect.new @physics
:resize => ResizeCircle.new @physics

x.add_action ResizeRect.new @physics
x.add_action ResizeCircle.new @physics # Exception => "resize" action already defined
# actually, ResizeCircle should probably only work with Circle shapes,
# so there should be two exceptions:
	# parameters of the action are wrong
	# action already exists
		# maybe this should be a warning instead?
