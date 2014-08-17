module InputSystem
	

# Create new actions based on name,
# sending the appropriate arguments to Action initialization as necessary.
class ActionFactory
	def initialize(*action_args)
		@action_args = action_args
	end
	
	
	
	
	# given the current state of things, figure out what action you're firing
	def create(spatial_status, action_name, entity=nil)
		place_to_look, target = 
			case spatial_status
				when :on_object
					# assuming we have found an existing Entity
					# but that it has no special characteristics
					
					[entity.class, entity]
					
				when :empty_space
					# space is empty at desired point
					
					# no target, because most actions in empty space create new things
					# the target supposed to be a thing which already exists
					# but that doesn't make sense for an action that creates something new
					[ThoughtTrace::Actions::EmptySpace, nil]
			end
		
		
		
		action = place_to_look.action_get(action_name).new(*@action_args,  target)
		
		# TODO: make easy way to check if Action is a the null object for that type of action. Sorta like how you can call #nil? on an object to check if it is nil or not
		if action_name and action.is_a? ThoughtTrace::Actions::NullAction
			warn "#{place_to_look.inspect} does not define action '#{action_name}'"
		end
		
		
		
		# p action
		
		return action
	end
end



end