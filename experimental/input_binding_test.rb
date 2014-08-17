require 'rubygems'
require 'gosu'


# Generate a bunch of the input combinations, so they don't need to be written by hand
->(){
	# keyboard accelerators to modify mouse inputs
	a = [:shift, :control, :alt]
	# all possible combinations of any number of elements from a
	x = a.size.times.collect{|i| a.combination(i+1).to_a }.flatten(1)

	# spatial options
	y = [:on_object, :empty_space]

	# mouse click options
	z = [:left_click, :right_click]

	y.product(z).product(x).collect{|a,b| [a[0], a[1], b] }.each{|x| p x}
	
	# NOTE: need to add the cases where no accelerators are pressed
	
	
	
	
	# # click or drag?
	# w = [:click, :drag]

	# combinations = 
	# 	y.product(z).product(x).product(w)
	# 		.collect{|a,b| [a.first.first, a.first.last, a.last, b] }
	# combinations.each{|x| p x}
}[]





# {
# 	[:on_object,   :left_click,  []]                        => [:edit, :select_sub_text],
# 	[:on_object,   :left_click,  [:shift]]                  => [nil, :resize],
# 	[:on_object,   :left_click,  [:control]]                => [:add_to_group, :constrain],
# 	[:on_object,   :left_click,  [:alt]]                    => [:split, nil],
# 	[:on_object,   :left_click,  [:shift, :control]]        => [nil, nil],
# 	[:on_object,   :left_click,  [:shift, :alt]]            => [nil, nil],
# 	[:on_object,   :left_click,  [:control, :alt]]          => [nil, nil],
# 	[:on_object,   :left_click,  [:shift, :control, :alt]]  => [nil, nil],
# 	[:on_object,   :right_click, []]                        => [nil, :move],
# 	[:on_object,   :right_click, [:shift]]                  => [nil, :duplicate],
# 	[:on_object,   :right_click, [:control]]                => [:mark_as_query, :link],
# 	[:on_object,   :right_click, [:alt]]                    => [:join, nil],
# 	[:on_object,   :right_click, [:shift, :control]]        => [nil, :clone],
# 	[:on_object,   :right_click, [:shift, :alt]]            => [nil, nil],
# 	[:on_object,   :right_click, [:control, :alt]]          => [nil, nil],
# 	[:on_object,   :right_click, [:shift, :control, :alt]]  => [nil, nil],
# 	[:empty_space, :left_click,  []]                        => [nil, nil],
# 	[:empty_space, :left_click,  [:shift]]                  => [:spawn_text, nil],
# 	[:empty_space, :left_click,  [:control]]                => [:spawn_rect, nil],
# 	[:empty_space, :left_click,  [:alt]]                    => [:spawn_circle, nil],
# 	[:empty_space, :left_click,  [:shift, :control]]        => [nil, nil],
# 	[:empty_space, :left_click,  [:shift, :alt]]            => [nil, nil],
# 	[:empty_space, :left_click,  [:control, :alt]]          => [nil, nil],
# 	[:empty_space, :left_click,  [:shift, :control, :alt]]  => [nil, nil],
# 	[:empty_space, :right_click, []]                        => [nil, nil],
# 	[:empty_space, :right_click, [:shift]]                  => [nil, nil],
# 	[:empty_space, :right_click, [:control]]                => [:spawn_image, nil],
# 	[:empty_space, :right_click, [:alt]]                    => [nil, nil],
# 	[:empty_space, :right_click, [:shift, :control]]        => [nil, nil],
# 	[:empty_space, :right_click, [:shift, :alt]]            => [nil, nil],
# 	[:empty_space, :right_click, [:control, :alt]]          => [nil, nil],
# 	[:empty_space, :right_click, [:shift, :control, :alt]]  => [nil, nil]
# }