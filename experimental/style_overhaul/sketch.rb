# entity (component structure)

# basic interface
{
	:style => [
		'primary'
		'slot_1',
		'slot_2',
		'slot_3'
	]
}

# backend data store
{
	:style => {
		:mode1 => [
			'primary'
			'slot_1',
			'slot_2',
			'slot_3'
		],
		:mode2 => [
			'primary'
			'slot_1',
			'slot_2',
			'slot_3'
		]
	}
}





# link styles by name
entity[:style].add p1['first']


# swap styles among a couple pallets
[p1, p2, p3].each do |pallet|
	entity[:style][1] = pallet['a']
	entity[:style][2] = pallet['b']
	entity[:style][3] = pallet['c']
end












# ???
{
	NAME => {
		:property => 'value',
		:prop1 => [],
		:prop2 => 2,
		:prop3 => Gosu::Color.argb(0xffAABBCC)
	}
}





















entity[:style].mode = :default                 # switch to mode with the given name

entity[:style].read(:color)                    # read from entire cascade
entity[:style].write(:color, "RED")            # write to primary style
entity[:style].socket(1, StyleObject.new)      # place a given style in the specified index
entity[:style].unsocket(1)                     # remove the style at the specified index
entity[:style].move(from:2, to:6)              # move style from one index to another
entity[:style].move_up(2)                      # move style in index 2 up one slot
entity[:style].move_down(2)                    # move style in index 2 down one slot
entity[:style].each_style{ |style|   }         # iterate through all available style objects

# may want to keep this interface, and alias a more friendly one for normal use
# naming the methods this way would allow for a better interface
# when calling methods "lisp-style" using Object#send



entity[:style][:color]
entity[:style][:color] = "RED"
entity[:style].socket(1, StyleObject.new)
entity[:style].unsocket(1)
entity[:style].move(source:2, destination:6)
entity[:style].move_up(2)
entity[:style].move_down(2)

entity[:style].each_style{ |style|   }




# TODO: style naming
# TODO: pallet swapping


# NOTE: can't serialize Styles by name, because names are not guaranteed to be unique, in any way



{
	:pallet_1 => {
		"foo" => {
			:property => 0
		},
		"baz" => {
			:property => 0
		},
		"qux" => {
			:property => 0
		}
	},
	
	:pallet_2 => {
		"foo" => {
			:property => 0
		},
		"baz" => {
			:property => 0
		},
		"qux" => {
			:property => 0
		}
	}
}


p1 = Array.new
p1 << StyleObject.new("foo")
p1 << StyleObject.new("baz")
p1 << StyleObject.new("qux")


p2 = Array.new
p2 << StyleObject.new("foo")
p2 << StyleObject.new("baz")
p2 << StyleObject.new("qux")



# swap out all the styles in the cascade with names that are the same as those in the pallet
# ex) if cascade defines a style called "foo", it will be replaced with the "foo" from the pallet
def pallet_swap(cascade, new_pallet)
	# collect up all styles from the new pallet
	# which have the same name as the styles currently defined in the cascade
	conversion_table = 
		cascade.each_with_object(Hash.new) do |style, h|
			h[style.name] = new_pallet.find{ |s|  s.name == style.name }
		end
	
	# swap out the styles as appropriate
	# but never touch the primary style
	cascade.each_with_index do |style, i|
		next if i == 0 # ignore the primary style
		
		swap_style = conversion_table[style.name]
		cascade.socket(i, swap_style) if swap_style
	end
end


# skip conversion of style elements with no name (ie name="")
# because that's the default name
# and there's going to be a lot of crazy senseless collision there
# like, collisions that make no sense
# that's not stuff you actually want to swap out,
# it's just stuff that collides because of defaults


# (maybe you want to assign UUIDs by default?)
# could still identify that it was a UUID, but you don't have to be like
# "HEY!" what up with all the collisons!?!?"


pallet_swap(entity[:style], p1)
pallet_swap(entity[:style], p2)