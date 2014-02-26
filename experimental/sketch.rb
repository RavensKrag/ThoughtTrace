# physics shapes
# resize
# other actions that modify shapes
# what methods should go where

Test.new





class Foo < Entity
	def initialize
		super()
		
						body = CP::Body.new
						shape = CP::Shape.new body 
		add_component TextSpace::Components::Physics.new body, shape
		
		add_action TextSpace::Actions::Move.new
	end
end

x = Foo.new

x[:physics] # access component by name





new_action.actions = actions # {:action_name => action_instance}
new_action.components = components # {:component_name => component_instance}








# find a way to specify what action to perform next
# make sure that cleanup phase always runs before switching actions
	# basically, want to run cleanup if control of the operation leaves this Action

class Split < Action
	interface :split
	
	actions :move
	
	
	MOVEMENT_THRESHOLD = 10 # distance in px relative to standard zoom level (100% scaling)
	
	
	def initialize(entity)
		@entity = entity
	end
	
	
	
	def start(point)
		@origin = point
	end

	def maintain(point)
		# split if you have moved more than a certain distance
		displacement = point - @origin
		if displacement.length > MOVEMENT_THRESHOLD
			# --- extract part of entity
				# + copy part of entity
				# + delete copied portion from original
				# + create new entity with extracted data
			shard = @entity.extract(3..-1)
				# arbitrary index for example purposes
				# I suppose you should just pass the selection? idk
			
			
			
			# --- want to switch action, and switch target
			# shard.move
			switch_action :move
			switch_target shard
			
			
			
			@shard = shard
			@shard.move.start
			@shard.move.mantain
		end
		
		
		
		# when the cursor moves outside a certain boundary, switch to move
		
		next_action :move
	end

	def cleanup(point)
		# recursive cleanup
		@shard.move.cleanup # wait, shouldn't this be on the stack or something?
		
		# can I use the standard stack at all?
		# do I have to make my own stack?
		# is this like how you can't really use 'while' because the whole game is a big loop?
	end
end









# Figure out what action to fire, and manage the state therein
# 


# 2 major problem remain:
# + how to bind
	# how you do figure out what actions should be used under which scenarios?
		# some actions should only fire in empty space. some only affect certain kinds of entities.
		# (that's the old logic anyway)
	# how do you "bind" action names to their proper contexts?
	# what properties can be used to prevent collisions?
# + how to find the type of action to launch
	# where does the info come from?
	# how do you do this exactly?



# and then there's the other half of the problem:
# raw input -> abstracted complex inputs
class Foo
	def initialize(space)
		@space = space
		@mouse = Mouse.new
		
		
		
		
		@action_names = [:foo, :bar, :baz]
		
		# if you're going to follow the legacy stile
		@action_names = {
			:selection => nil,
			:point => nil,
			:space => nil
		}
		# only can have one action name per slot
		# if you try to put an action where the name is already set, that is a collision
		# 
		# should put actions into the correct categories automatically
		# the user need only know what actions they want,
		# the designer of the action must know where the action should go
		
		
		
		@stack = ActionStack.new
	end
	
	def press
		# triggered on button press
							point = @mouse.position_in_world
							layers = CP::ALL_LAYERS
							group = CP::NO_GROUP
							set = nil
		entity = @space.point_query_best point, layers, group, set
		
		
		
		type = action_type(entity)
		action_name = @action_names[type]
		
		action = entity.send action_name
		
		@stack.push action
	end
	
	def hold
		@stack.update
	end
	
	def release
		@stack.pop # need to COMPLETELY purge the stack, not just the top item
		
		
		# the queue doesn't have that problem (I don't think)
		# because it's not really a 'queue' so much as it's an active item, and a waiting area
		# need to make ABSOLUTELY SURE though,
		# because failure to run ActionQueue#deque could result in Actions being setup and never cleaned
	end
	
	
	
	
	
	
	
	def action_type(entity)
		# DISAMGUATE WHICH ACTION TO LAUNCH
		# (selection, point, space) are the legacy pick callback types
			# legacy callbacks returned either a valid object, or nil
			# getting a non-nil object was a signal that the pick was successful,
			# and that the action should proceed
			# 
			# the older algorithm is more concurrency-friendly,
			# but Ruby is really bad at that anyway
		case entity
			when nil
				# firing into empty space
				
				# CAN LAUNCH SPAWN ACTIONS
			when fizzbar
				# target selection shard
				# entity with an active selected sub-sector
			when fizzbar
				# target selection group
				# entity which is part of active selection group
			when fizzbar
				# target standard entity
		end
		
		
		
		
		
		
		
		
		
		if entity.nil?
			# firing into empty space
			
			# CAN LAUNCH SPAWN ACTIONS
			
		# elsif entity.
			# target selection shard
			# entity with an active selected sub-sector
			# [:split]
		elsif @selection.include? entity
			# target selection group
			# entity which is part of active selection group
		else
			# target standard entity
			# [:move]
		end
	end
	
	
	
	# get an appropriate entity, and access the proper action from it
	def query
		
	end
end
