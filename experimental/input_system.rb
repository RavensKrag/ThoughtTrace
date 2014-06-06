# accelerator system
# simple system
# only works with single keys, combined with accelerators (typically: shift, ctrl, alt)
class Foo
	def initialize
		@accelerators = [
			:shift,
			:control,
			:alt
		] # accelerators
		
		
		# not accelerators
		@main_keys = [
			:a, :b, :o
		]
		
		
		# events that can be fired, mapped to input sequences
		@events = {
			[:shift,   :a] => lambda{ },
			[:control, :b] => ->(){  },
			[:o] => ->(){   }
		}
		
		
		# maps raw button inputs to human readable names
		# Gosu already provides some names, but I want a structure independent of that
		# also, this means you can provide application-specific names
		# and potentially, you could switch around the underlying mapping for a particular name
		# without that much hassle, which is good when you're prototyping
		
		# this also means the system can easily figure out what inputs can be safely ignored
		# if an input ID is not registered in the button map,
		# that means that it is not being used in any binding
		# -> the ID is in the button map IFF the button is being used in a binding
		@button_map = {
			Gosu::MsLeft => :left_click,
			Gosu::MsRight => :right_click,
			
			Gosu::KbA => :a,
			Gosu::KbB => :b,
			Gosu::KbO => :o,
		}
		
		
		
		# when main key depressed, fire event
		# can fire separate event for unmodified event, vs each and every accelerated event
		
		
		# list of keys currently being held
		@held = Set.new
	end
	
	
	def button_down(id)
		button = @button_map[id]
		
		# short circuit for unregistered buttons
		return if button.nil?
		
		
		
		@held.add button if @accelerators.include? id
		
		
		if @main_keys.include? button
			# fire event
			
			
			# modify event with all available accelerators
			# but do NOT expend accelerators to do so
			
				# accelerators should probably be listed in a particular order,
				# independent of when they had been pressed, so that it
				# becomes easier to match them up with events
		end
		
		
		
		
		
		
		@held.add button
	end
	
	def update
		
	end
	
	# def button_up(id)
	# 	@held.delete id
	# end
	
	def button_up(id)
		button = @button_map[id]
		
		@held.delete button
	end
end



keys -> name
name -> callbacks

def bind(keys, name)
def bind(name, keys)
	
end

def register(name, callbacks)
	
end


# You can't really do this
@input.bind[:click] = Qux.new(keys:[Gosu::MsLeft], modifiers:[]))
@input.register[:click] = event




@input.bind(:click, Qux.new(keys:[Gosu::MsLeft], modifiers:[]))
@inputs[:click] = Qux.new(keys:[Gosu::MsLeft], modifiers:[])

@inputs.register(:click) do
	press do
		
	end
	
	hold do
		
	end
	
	release do
		
	end
end
@inputs.register(:fire => event, :on => :click)




@input.bind event_name: :click, input: Qux.new(keys:[Gosu::MsLeft], modifiers:[])
@inputs.register fire: event, on: :click


@input.bind event: :click, input: Qux.new(keys:[Gosu::MsLeft], modifiers:[])
@inputs.fire event: event, on: :click



@inputs.register(
	:input => Qux.new(keys:[Gosu::MsLeft], modifiers:[]),
	:name => :click,
	:callbacks => event
)

@inputs.register(:click) do
	fire event
	on Qux.new(keys:[Gosu::MsLeft], modifiers:[])
end






	click = Input.new keys:[Gosu::MsLeft], modifiers:[]
	event = EventCallback.new
x = Foo.new :click, click, event

x = Foo.new :click, on: click, fire: event


x.callbacks.press if x.input.keys.subset? @ansotehu


new_input = Input.new keys:[Gosu::MsLeft], modifiers:[Gosu::KbLeftControl]
x.rebind(new_input)




# problem with this interface is that you can only have one binding per event
# but the sames goes for the other interface
ev = Event.new(:click, callbacks)
ev.bind(keys:[Gosu::MsLeft], modifiers:[Gosu::KbLeftControl])
# this reduces the feeling that Event represents three pieces of data in tandem
# feels more like two pieces, and a subservient piece












# example of new Event binding style

event = Event.new event_name, callbacks
event.bind_to keys:[Gosu::MsLeft], modifiers:[]

event.unbind! # TODO: consider implementing #unbind!


@input.register event


@input.find(event_name).bind_to()
event.bind_to()





# The real question seems to be whether or not "callbacks" should be mutable
# making "callbacks" mutable would push Event closer to the Builder pattern
# but callbacks always has to be an object with a fixed interface, so maybe Builder is bad?
event = Event.new event_name
event.callback_object = callbacks
event.bind keys:[Gosu::MsLeft], modifiers:[]

# you need this sort of interface if you want to be able to change the callback object
# current interface implies that the callbacks are never to be altered









# ===== Data format for button bindings =====

# CSV format with test header
data = <<-EOF
	categorization,phase,action_name,event_name,,list,of,keys,,list,of,modifiers
	
EOF

# something a bit different
data = <<-EOF
	categorization,phase,action_name
	event_name
	list,of,keys
	list,of,modifiers
	
EOF

# YAML
data = <<-END_OF_THE_STRING
---
:categorization: selection
:phase: drag
:action_name: move and spaces are ok
:event_name: click
:keys:
- 1
- 2
:modifiers:
- 6
END_OF_THE_STRING
# note that the keys and modifiers are going to come out as integers
# this makes the YAML not really "human readable"
# but I'm not really using it for a human readable format,
# I just want to be able to serialize without having to worry about low-level things



# TODO: consider compressing the chain of classes used to get from low level input to event firing. It's getting rather large, and some of the transformations are really basic. This makes it easy to follow, and easy to change, but may make things inefficient => input lag.
