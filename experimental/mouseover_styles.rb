# at first glance, it seems like you would want an action for this
# because actions modify components
# but actions have to be controlled by an ActionStash
# Mouse currently doesn't have access to the Stash
# should it acquire access in some way, or should this not be an action?
# if this is an action, how does the namespacing work? (ie, what is the name of the action?)

# is there any sort of problem with having multiple actions working on one Style component?
	# there's no concurrency in the current system
	# but reshuffling to allow mouseover to have a Stash may complicate things?



# @entity[:style][:color] = Gosu::Color.argb(0xffFFFFFF)


width = 100
height = 100
@entity = ThoughtTrace::Rectangle.new width, height 


@entity[:style][:default][:color] = Gosu::Color.argb(0xffFFFFFF)




@entity[:style].mode = :default
@entity[:style][:color] = Gosu::Color.argb(0xffFFFFFF)


# need a way to be able to set a property in a given mode quickly
# would like to not have to set the mode many times when batch editing
# do not want to have to change the mode to change one property in that mode
	# (too easy to forget to change back. would cause many bugs)



# should style be having multiple modes?
# or should an Entity be allowed to have multiple components that implement the same interface?



@entity[:style].default.color = Gosu::Color.argb(0xffFFFFFF)

@entity[:style].default[:color] = Gosu::Color.argb(0xffFFFFFF)

@entity[:style][:default][:color] = Gosu::Color.argb(0xffFFFFFF)

@entity[:style][:default].color = Gosu::Color.argb(0xffFFFFFF)



@entity[:style][:color] = Gosu::Color.argb(0xffFFFFFF)

@entity[:style].color = Gosu::Color.argb(0xffFFFFFF)





# edit color for CURRENT mode
@entity[:style][:color] = Gosu::Color.argb(0xffFFFFFF)

@entity[:style][CURRENT][:color] = Gosu::Color.argb(0xffFFFFFF)
@entity[:style][ACTIVE][:color] = Gosu::Color.argb(0xffFFFFFF)

@entity[:style][ThoughtTrace::Components::Style::CURRENT][:color] = Gosu::Color.argb(0xffFFFFFF)
@entity[:style][ThoughtTrace::Components::Style::ACTIVE][:color] = Gosu::Color.argb(0xffFFFFFF)

@entity[:style]['CURRENT'][:color] = Gosu::Color.argb(0xffFFFFFF)
@entity[:style]['ACTIVE'][:color] = Gosu::Color.argb(0xffFFFFFF)


@entity[:style]['current'][:color] = Gosu::Color.argb(0xffFFFFFF)
@entity[:style]['active'][:color] = Gosu::Color.argb(0xffFFFFFF)


@entity[:style][:current][:color] = Gosu::Color.argb(0xffFFFFFF)
@entity[:style][:active][:color] = Gosu::Color.argb(0xffFFFFFF)
	# this way gets a bit lost...
	# :current / :active just looks like they're names of modes
	# and not like, a special mode selector



@entity[:style][@entity[:style].mode][:color] = Gosu::Color.argb(0xffFFFFFF)



mode = @entity[:style].mode
@entity[:style][mode][:color] = Gosu::Color.argb(0xffFFFFFF)




mode_name = @entity[:style].mode
mode = @entity[:style][mode_name]
mode[:color] = Gosu::Color.argb(0xffFFFFFF)
	# would like to be able to ommit mode when "unnecessary"
	# if the mode was omitted, it would be clear that it was editing the current mode
		# ...at least I think it would be...


mode_name = @entity[:style].mode
@entity[:style][mode_name].tap |mode|
	mode[:color] = Gosu::Color.argb(0xffFFFFFF)
end









@entity[:style].default[:color] = Gosu::Color.argb(0xffFFFFFF)
@entity[:style].active[:color] = Gosu::Color.argb(0xffFFFFFF)
	# want the invocation of a 'special mode' to visually pop
	# which means that it needs to be a different sort of syntax element






# if you have to switch the mode, the flow goes like this
old_mode = @entity[:style].mode
	@entity[:style].mode = :active
	@entity[:style][:color] = Gosu::Color.argb(0xffFFFFFF)
@entity[:style].mode = old_mode



# maybe an auto-switcher? that way you can't forget to switch back
# it's similar to the blocks on file IO, really
# (directly inspired by the .tap prototype above)
@entity[:style].quick_edit(:active) do |mode_handle|
	mode_handle[:color] = Gosu::Color.argb(0xffFFFFFF)
end

# might as well use .tap to implement this
# (but if I'm going this way, it probably needs a better name)
def quick_edit(mode)
	old_mode = self.mode
		self.mode = mode
		
		self.tap |mode_handle|
			yield mode_handle
		end
	self.mode = old_mode
end

# use instance variables
def quick_edit(mode)
	old_mode = @mode
		@mode = mode
		
		self.tap |mode_handle|
			yield mode_handle
		end
	@mode = old_mode
end





# lets try some names

@entity[:style].quick_swap(:active) do |style|
	style[:color] = Gosu::Color.argb(0xffFFFFFF)
end

@entity[:style].edit(:active) do |style|
	style[:color] = Gosu::Color.argb(0xffFFFFFF)
end
	# yeah, simple name might be best







# again, for easy comparison side-by-side
	# edit some other mode
	@entity[:style].edit(:active) do |style|
		style[:color] = Gosu::Color.argb(0xffFFFFFF)
	end
	
	# edit the current mode
	@entity[:style][:color] = Gosu::Color.argb(0xffFFFFFF)
	
	# or, if you have many properties to edit
	@entity[:style].edit do |style|
		style[:color] = Gosu::Color.argb(0xffFFFFFF)
	end
		# maybe have it default to "switching" to the current mode with zero args?


def edit(mode=@mode) # not sure if you can use an instance variable like this
	old_mode = @mode
		@mode = mode
		
		self.tap |mode_handle|
			yield mode_handle
		end
	@mode = old_mode
end


# try to avoid switching where unnecessary
def edit(mode=@mode)
	old_mode = @mode unless @mode == mode
	
		@mode = mode
		
		self.tap |mode_handle|
			yield mode_handle
		end
	
	@mode = old_mode if old_mode # will not exist if trying to switch to the currently active mode
end
	# it's probably more efficient to just perform the switch every time
	# it's just one variable being changed, after all











# normally styles will be dictated in CSS, not in code
# (or maybe some other style serialization format)

# --- css
Rectangle {
	
}

Rectangle:hover {
	
}


# custom (human readable)
# (I think that ultimately it will not be a language you would specify in a text editor like CSS)
Rectangle {
	# colors specified in ARGB hex encoding
	
	default {
		color: #ffFFFFFF
	}
	
	hover {
		color: #ff0000FF
	}
}


# want to serialize style into some format rather than declaring in code all the time
# but styles need to be editable at runtime
# so style properties need to be adjustable with code
# clearly, you need to read values as well

















# Mouse currently doesn't have access to the Stash
# should it acquire access in some way, or should this not be an action?
# if this is an action, how does the namespacing work? (ie, what is the name of the action?)

# is there any sort of problem with having multiple actions working on one Style component?
	# there's no concurrency in the current system
	# but reshuffling to allow mouseover to have a Stash may complicate things?



# should style be having multiple modes?
# or should an Entity be allowed to have multiple components that implement the same interface?

