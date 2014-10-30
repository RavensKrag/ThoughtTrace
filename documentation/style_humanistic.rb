# humanistic API
# should be viewed on the left

component
# stores multiple cascades in named modes
	component;_binding_callback
	component_unbind_callback
	
	
	copy_data_from_other_component
	
	get_cascade_by_mode_name
	get_active_cascade
	include_cascade_by_mode_name?
	get_current_mode_name
	set_mode
	delete_mode
	new_mode
	edit_mode
		# make changes to another mode,
		# and then swap back
	
	iterate_over_all_contained_cascades
	
	get_property # delegate
	set_property # delegate

cascade
# stores style objects in numbered sockets
	add_style
	remove_style
	get_style
	
	move
	move_up # the object at index i up one slot
	move_down # same thing, but down one slot
	number_of_styles
	
	get_primary_style
	
	each_style
		# aliases
	find_style
	all_methods_defined_by_enumerable_mixin
	
	
	get_name     # generate from style data
	
	get_property # delegate
	set_property # delegate
	
	has_property?

style
	get_name
	prevent_name_from_being_edited
	
	get_property
	set_property
	
	has_property?