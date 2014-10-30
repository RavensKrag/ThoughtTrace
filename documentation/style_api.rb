# programming API
# should be viewed on the right

component
# stores multiple cascades in named modes
	entity[:style].on_bind
	entity[:style].on_unbind
	
	
	entity[:style].mirror(other_component)
	
	entity[:style].cascade(:default)
	entity[:style].active_cascade
	entity[:style].include_cascade?
	entity[:style].mode
	entity[:style].mode = :default
	entity[:style].delete :default
	entity[:style].mode = :default
	entity[:style].edit :other do |cascade|
		
	end
	
	entity[:style].each_cascade # iter or block
	
	entity[:style][:property]
	entity[:style][:property] = :value
	
cascade
# stores style objects in numbered sockets
	cascade.socket(1, StyleObject.new)
	cascade.unsocket(1)
	cascade.read_socket(1)
	
	cascade.move(source:2, destination:6)
	cascade.move_up(2)
	cascade.move_down(2)
	cascade.size
	
	cascade.primary_style
	
	cascade.each{ |style|  p style }
	       .each_style
	cascade.find{ |style|  style.name == "foo" }
	# cascade includes enumerable, 
	# providing find and a bunch of others
	
	cascade.name
	
	cascade[:property]
	cascade[:property] = :value
	
	cascade.has_property?
	
style
	style.name
	style.lock_name!
	
	style[:property]
	style[:property] = :value
	
	style.has_property?