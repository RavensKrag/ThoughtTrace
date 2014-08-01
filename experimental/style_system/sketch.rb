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



















class StyleComponent
	def initialize
		# use one cascading blob for each mode
		@modes = Hash.new
	end
	
	def mode_switch(mode)
		@modes[mode] ||= CascadingStyleBlob.new
		@active_mode = @modes[mode]
	end
	
	delegate methods:[:add, :raise, :lower] to: :@active_mode
	
end



component = StyleComponent.new
component.mode_switch :default
# component['color'] = 

# when you change the value of some property though the cascade system,
# which actual Style object are you modifying?
# The changes have to eventually be applied to one Style in particular,
# because that's where all the actual data lives.

# I assume you want to change the most recently added Style that defines that value?
# Or maybe you want to always set the value on a "local" style
	# don't want changes to percolate back, unless you manually copy them back
























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


pallet[:bar][:color] = 0xffAABBCC


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






































require 'securerandom'

# map IDs to style data
class Pallet
	def initialize
		@storage = Hash.new	
	end
	
	# assign new id to style object, and start tracking the style
	def add(style)
		id = SecureRandom.uuid
		@storage[id] = style
		
		return id
	end
	
	def delete(style)
		@storage.delete_if{ |k,v|  v == style }
		# well, if you use an array backing as well, it's still going to be linear time to delete
		# so this works pretty decently, to be honest
	end
	
	
	
	# fetch the style object with the associated ID
	def [](id)
		return @storage[id]
	end
end


# map style data to human readable IDs that can be changed at will without affecting the backend
class NameIndex
	def initialize
		
	end
	
	# return the name associated with this style
	def [](style)
		
	end
	
	# generate name for Style automatically
	def store(style)
		
	end
	
	# assign a new name to Style
	def rename(style)
		
	end
	
	# stop tracking this Style
	def delete(style)
		
	end
end



pallet = Pallet.new
# maps object IDs to Styles

names = NameIndex.new
# a context under which styles can be named
# objects can have different names under different contexts



# does this apply to only the Style <=> name mapping, or to any mapping of objects and names in the Style system?


pallet = Pallet.new
cascade = ThoughtTrace::Style::Cascade.new pallet

style = ThoughtTrace::Style::StyleObject.new



# --- assigning to cascade
id = pallet.add style
cascade.add id
# what happens when you try to add a style object that already is in the Pallet?


# --- resolving styles through cascade
target_property = ""
@styles.each do |id|
	style = pallet[id]
	style[target_property]
end





# --- visualizing data
name = names[style]
# do you want to map style objects in this collection, or style IDs?
# you need to translate to the IDs anyway when you serialize

# but maybe I want to know the name of a particular style, like, independent of pallet?

# (not sure if that makes sense, or is advisable)



# TODO: on cascade evaluation, iterate using #each, and make sure that the "primary" style for the component is stored as the first element (highest priority)
# wait... no....
# the first element in the list should indeed be the highest priority
# so that you can easily add more ancestors as needed
# but maybe the iteration order is still reverse_each?




# --- in component
# + map the primary style of one thing into the cascade of another
	# this kinda reduces the need for names, sorta
	# (I think I'm gonna delay having names for a bit?)

# (this should probably be something that affects two components, rather than being in a comp)
def foo(a,b)
	id = a[:style].style_id
	
	b[:style].cascade.add id
end