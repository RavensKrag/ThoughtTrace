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
				:press => nil,
				:hold => nil
			},
			:existing => {
				:press => nil,
				:hold => nil
			},
			:empty => {
				:press => nil,
				:hold => nil
			}
		}
		
		
		
		@action_controller = nil
	end
	
	# start operation
	def press(point)
		entity = @space.point_query_best(point, layers=CP::ALL_LAYERS, group=CP::NO_GROUP, set=nil)
		category = categorize(entity)
			puts "category: #{category}"
		
		click_and_drag = resolve_action_symbols(entity, category)
			puts "[#{click_and_drag[0].class.name}, #{click_and_drag[1].class.name}]"
		
		# NOTE: May want to refrain from allocating and deallocating ClickAndDragController all the time. But you would have to remember to reset the internal state of the object before using it again. Easier for now to just make new ones.
		@action_controller = ClickAndDragController.new(*click_and_drag)
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
			
			
			klass =
				unless action_name.nil?
					entity.action(action_name)
				else
					# use NullObject to stub callbacks
					# ThoughtTrace::Entity::Actions::Action
					NullAction
				end
			
			
			klass.new(@space, @stash, entity)
		end
	end
	
	
	# Actually, the base Action is itself sort of a NullObject,
	# as it just stubs out all necessary callbacks.
	# 
	# This allows for easy debug outputs though.
	class NullAction < ThoughtTrace::Entity::Actions::Action
		def initialize(*args)
			super(*args)
		end
		
		def setup(point)
			puts "setup null"
		end
		
		def update(point)
			puts "update null"
		end
		
		def cleanup(point)
			puts "cleanup null"
		end
	end
end



end