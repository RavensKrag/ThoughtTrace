# programming API
# should be viewed on the right

component
# stores multiple cascades in named modes
	entity[:style].cascade(:default)
	entity[:style].active_cascade
	entity[:style].include_cascade?
	entity[:style].mode = :default
	entity[:style].delete :default
	entity[:style].mode = :default
	entity[:style].edit :other do |cascade|
		
	end
	
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
	cascade.find{ |style|  style.name == "foo" }
	
	
	cascade[:property]
	cascade[:property] = :value
	
	cascade.has_property?
	
style
	style[:property]
	style[:property] = :value
	
	style.has_property?