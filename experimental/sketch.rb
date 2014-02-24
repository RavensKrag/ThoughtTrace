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
