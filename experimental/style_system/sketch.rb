cascade_stack = [
	# highest priority
	Style.new()
	Style.new()
	Style.new()
	Style.new()
	Style.new()
	# lowest priority
]
# prioritized is #each iteration order
# high priority is reached before low priority in #each iteration
# ie, the cascade stack is sorted by priority, high to low


cascade = CascadingStyleBlob.new
cascade.add "first", Style.new()
cascade.add "second", Style.new()
# items added later with have higher priority, like how CSS works


# move one Style object one position in the list
cascade.raise "second"
cascade.lower "first"


















# pallets dictate whole sets of styles (almost like a global?)
# 
# not the same as Cascade sets, which dictate a subset of that space,
# applied to one element with a certain precedence ordering






p = Pallet.new
p[:foo] = Style.new()
p[:baz] = Style.new()
p[:bar] = Style.new()



p.each do |style|
	p [style.name, style.property_x, style.property_y, style.property_z]
end



entity = Foo.new


# pallet swap
# (swap out a whole set of styles at once)
entity[:style].pallet = p


# swap out one style
# (affects all objects that use the same pallet)
entity[:style][:foo] = Style.new



# edit the style of a particular element
# (this needs work)
# (not sure if I want to explicitly be editing a particular style?)
# (maybe automatically edit the most recent style? is that just a UI concern?)
entity[:style][:foo].color = Gosu::Color::RED

















# -----------------------------
#  entity -> cascade -> pallet
# -----------------------------

# change the pallet, affect a bunch of cascades
# change the cascade, affect one or more entities

# multiple styles, organized by name, in a cascade (aggregation)
# multiple styles, bound to names, in a pallet (composition)



pallet = Pallet.new
cascade = Cascade.new
entity = Entity.new




pallet[:foo] = Style.new()
pallet[:baz] = Style.new()
pallet[:bar] = Style.new()


cascade.pallet = pallet
cascade.add :foo
# TODO: may want to make a GUI thing, sort of like #inspect that allows for easy cascade reordering
	# not sure that should directly be a method, but you need methods to allow for model mutation
	
	# + list available styles
	# + select one style by name
	# + move selected style into a different position
	


# could switch the cascade for a particular entity
# if you need to change a bunch of styles all at once
entity[:style].cascade = cascade











# not sure if you should be able to have multiple pallets active,
# or if there should only be one pallet?

# should be able to have multiple pallets active
# but only because of prefabs
	# if you can only have one pallet active,
	# you need to do weird things to pallets when you start using prefabs
	
	# so, having multiple pallets sort of provides a namespacing thing









group = Group.new
group.add entity

# swap the pallets for a whole bunch of Entities
class Group
	def pallet_swap(pallet)
		self.each do |entity|
			entity.pallet = pallet
		end
	end
end
