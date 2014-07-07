callbacks = [
	press:->(){
		
	},
	
	hold:->(){
		
	},
	
	release:->(){
		
	},
	
	cancel:->(){
		
	}
]
# better to just use blocks than lambdas
# especially when the blocks have to have particular names


callbacks = 
	Callbacks.new do
		press do
			
		end
		
		hold do
			
		end
		
		release do
			
		end
		
		cancel do
			
		end
	end

event = InputSystem::ButtonEvent.new :enter, callbacks
# this is a bit silly
# why create a new object, when you could just put the block directly on the thing
# from the user's perspective, it's certainly strange






event = 
	InputSystem::ButtonEvent.new :event_name do
		press do
			
		end
		
		hold do
			
		end
		
		release do
			
		end
		
		cancel do
			
		end
	end

# but to access any sort of variables in this scheme, you would have to instance-eval
# the blocks within the calling context
# I think you need to pass a reference to the calling context to be able to do that?

class ButtonEvent
	
end





callbacks = SpecialCallback.new *args # feed it the variables you will need
event = InputSystem::ButtonEvent.new :enter, callbacks
