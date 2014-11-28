
# constraints are always defined pairwise
# always define data flow from a to b (unidirectional edge)
module SyncHeight < Constraint
class << self
	
	# TODO: need a better name for this "things I plan to edit in the tick phase" block
	message = ->(x){ |x|
		x[:physics].height
	}
	
	def tick(a,b)
		b[:physics].height = a[:physics].height
	end
	
	
	
	
	
	def draw(a,b)
		draw_line(a[:physics].center, b[:physics].center)
	end
	
end
end






# should have different types of wrappers
# + group    (define edges for all n! relationships)
# + one way  (define one edge)
# + two-way  (define two edges, one in each direction)


# (could possibly create a factory class to create the proper wrapper based on arity?)
# (but that can't distinguish between 1-way and 2-way edges anyway... sooo....)




class Wrapper
	attr_reader :constraint, :entity_list
	# WARNING: exposing entity_list in this way could allow it to be edited
	
	# NOTE: The "previous state" thing is only necessary to know what values are being changed. That information does not need to be saved. Relevant entity data will be saved when entities and components are serialized.
	
	def initialize(constraint, *entity_list)
		@constraint = constraint
		@entity_list = entity_list
		
		@prev_list = nil
	end
	
	def update
		# figure out what parts of the entity may be subject to change
		# only apply a tick of the constraint if the constraint needs to be
		data_list =
			@entity_list.collect do |entity|
				@constraint.message.call(entity)
			end
		
		
		
		
		
		
		
		if @prev_list # ignore the first iteration, when you don't have a "previous"
			# find the index of the first piece of data that has changed since the last update
			i = @prev_list.zip(data_list).find_index{ |a,b|  a != b  }
			
			# if a change has been found...
			unless i.nil?
				# extract the old and new values
				old_value = @prev_list[i]
				new_value =  data_list[i]
				
				
				# as well as the entity itself
				updated_entity = @entity[i]
				
				
				# update each entity to use the new value
				
				# ----------
				# WAIT
				# don't want to just copy the value straight
				# you want to apply the value as dictated by the constraint
				# ----------
				@entity_list.each do |entity|
					next if entity == updated_entity
					
					@constraint.tick(updated_entity, entity)
				end
			end
		end
		
		
		
		
		
		@prev_list = data_list
	end
	
	
	
	
	
	
	
	
	
	def update
		@entity_list.permutation(2) do |a,b|
			@constraint.tick(a,b)
		end
	end
	
	def draw
		@entity_list.permutation(2) do |a,b|
			@constraint.draw(a,b)
		end
	end
	
	# Need to draw any pair for which at least one Entity is visible on screen
	# Probably need to update all Entity objects that are currently being tracked
		# wait
		# but you need to not update ALL pairs,
		# because that would 
end




Wrapper.new(constraint, a,b)

# Wrapper.new(a,b, tick:->(a,b){  }, draw:->(a,b){   })









	
	
	# select the element that has changed, and propagate changes
	
	
	
	
	# group trigger
	x = group.find{ |x|  x[:physics].height == CHANGED   }
	unless x.nil?
		group.each do |entity|
			entity <-- x
		end
	end
	
	
	# pairwise trigger
	if a[:physics].height == CHANGED
		b <-- a
	elsif b[:physics].height == CHANGED
		a <-- b
	end
	
	
	# so...
	# some sequence of message sends to find a value
	# the wrapper must save the last known value of the message evaluation
	# and compare it to the current tick?