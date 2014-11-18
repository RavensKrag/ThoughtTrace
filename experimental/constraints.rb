
# constraints are always defined pairwise
module SyncHeight < Constraint
class << self
	
	def tick(a,b)
		b[:physics].height = a[:physics].height
	end
	
	def draw(a,b)
		line(a[:physics].center, b[:physics].center)
	end
	
	
	
	message = ->(x){ |x|
		x[:physics].height
	}
end
end








class Wrapper
	def initialize(constraint, *entity_list)
		@constraint = constraint
		@entity_list = entity_list
		
		@prev_list = nil
	end
	
	def update
		# figure out what parts of the entity may be subject to change
		# only apply a tick of the constraint if the constraint needs to be re-evaluated
		data_list =
			@entity_list.collect do |entity|
				data = @constraint.message.call(entity)
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
	
	def draw
		@entity_list.each_cons(2) do |a,b|
			@constraint.draw(a,b)
		end
	end
end




Wrapper.new(constraint, a,b)

# Wrapper.new(a,b, tick:->(a,b){|a,b|  }, draw:->(){})