module ThoughtTrace


# controls overall flow
# Will oversee the entire process, from extracting an Entity from the space,
# to firing the appropriate actions as necessary.
# Should illustrate program flow, sort of like a 'main' method.
	# controls operations for one input event binding
	# should assume that multiple instances will be used in tandem
class ActionFlowController
	attr_reader :bindings
	
	def initialize(space, selection, stash)
		@space = space
		@selection = selection
		@stash = stash
		# TODO: Should probably pass @selection to Action objects as they are initialized.
		# TODO: Consider the removal of the Action stash. May not be needed in new format.
			# was needed for automated handling of Actions
			# (now irrelevant. should be using direct interfaces for that purpose)
			
			# was needed to allow Actions to baton pass to other Actions
			# (not sure if that's still necessary or not)
		
		
		
		
		# TODO: may want to create a better interface to bind these things visually once GUI systems are operational. Not sure how to make this any better in text form. Gonna be weird no matter how you do it, and nested Hashes are straightforward to implement.
		@bindings = {
			:selection => {
				:click => nil,
				:drag => nil
			},
			:existing => {
				:click => nil,
				:drag => nil
			},
			:empty => {
				:click => nil,
				:drag => nil
			}
		}
		
		
		
		@action_controller = nil
	end
	
	# start operation
	def press(point)
		# TODO: fix crash when point is in empty space
		# resolve_action_symbols() doesn't work without an Entity, but that's exactly what happens in empty space
		
		entity = @space.point_query_best(point, layers=CP::ALL_LAYERS, group=CP::NO_GROUP, set=nil)
		
		
		
		
		standard_args = [@space, @stash]
		
		
		# one of these
		binding, place_to_look, target = 
			if entity.nil?
				# space is empty at desired point
				
				# no target, because most actions in empty space create new things
				# the target supposed to be a thing which already exists
				# but that doesn't make sense for an action that creates something new
				[@bindings[:empty], ThoughtTrace::SomeModule, nil]
			elsif @selection.include? entity
				# entity is part of the currently active selection
				
				[@bindings[:selection], ThoughtTrace::SomeOtherModule, entity]
			else
				# assuming we have found an existing Entity
				# but that it has no special characteristics
				
				[@bindings[:existing], entity.class, entity]
			end
		
		
		# using that information, generate both of these
		click_action, drag_action = 
			[:click, :drag].collect do |event|
				action_name = binding[event]
				puts "no action bound to #{event}" if action_name.nil?
				
				
				
				# TODO: make easy way to check if Action is a the null object for that type of action. Sorta like how you can call #nil? on an object to check if it is nil or not
				action = place_to_look.action_get(action_name).new(*standard_args,  target)
				
				if action.is_a? ThoughtTrace::Entity::Actions::NullAction
					puts "#{place_to_look.inspect} does not define action '#{action_name}'"
					# puts "action '#{action_name}' undefined for #{place_to_look.inspect}"
				end
				
				
				# pseudo-return
				action
			end
		
		
		# NOTE: May want to refrain from allocating and deallocating ClickAndDragController all the time. But you would have to remember to reset the internal state of the object before using it again. Easier for now to just make new ones.
		@action_controller = ClickAndDragController.new(click_action, drag_action)
		@action_controller.press(point)
	end
	
	# adjust operation interactively
	def hold(point)
		@action_controller.hold(point)
	end
	
	# complete operation
	def release(point)
		@action_controller.release(point)
		@action_controller = nil
	end
	
	# revert to the state before this structure was invoked
	def cancel
		@action_controller.cancel
		@action_controller = nil
	end
	
	# NOTE: Setting of the click and drag controller to nil is done to wipe state. Do not want unnecessary Actions hanging around. That's just likely to cause errors. Don't want anything firing on accident.
	
	
	
	
	
	def draw
		# Should be the only phase where you have to check if variable is set.
		# Same reasoning as in ClickAndDragController#draw delegation
		@action_controller.draw if @action_controller
	end
	
	
	private
	
	def categorize(entity)
		if entity.nil?
			# space is empty at desired point
			return :empty
		elsif @selection.include? entity
			# entity is part of the currently active selection
			return :selection
		else
			# assuming we have found an existing Entity
			# but that it has no special characteristics
			return :existing
		end
	end
	
	# resolve symbols into actual Actions
	def resolve_action_symbols(entity, category)
		[:click, :drag].collect do |event|
			action_name = @bindings[category][event]
			
			
			
			klass = entity.action(action_name)
			
			# these are more of warning debug messages,
			# as opposed to total failure exceptions
			if action_name.nil?
				puts "no action defined for #{category} -> #{event}"
			elsif klass == ThoughtTrace::Entity::Actions::NullAction
				puts "no handler defined for action '#{action_name}' on #{entity.class}"
			end
			
			
			klass.new(@space, @stash, entity)
		end
	end
end



end