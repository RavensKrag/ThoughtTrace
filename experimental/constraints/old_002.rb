
# constraints are always defined pairwise
module SyncHeight < Constraint
class << self
	
	def tick(a,b)
		
	end
	
	def draw(a,b)
		
	end
	
	
	
	message "[:physics].height"
end
end








class Wrapper
	def initialize(constraint, *entity_list)
		@constraint = constraint
		@entity_list = entity_list
		
		@prev_list = nil
	end
	
	def update
		data_list =
			@entity_list.collect do |entity|
				data = eval "entity#{@constraint.message}"
			end
		
		
		
		
		
		if @prev_list
			# find the index of the first piece of data that has changed since the last update
			i = @prev_list.zip(data_list).find_index{ |a,b|  a != b  }
			
			# if a change has been found...
			unless i.nil?
				# extract the old and new values
				old_value = @prev_list[i]
				new_value =  data_list[i]
				
				
				# update each entity to use the new value
				
				# ----------
				# WAIT
				# don't want to just copy the value straight
				# you want to apply the value as dictated by the constraint
				# ----------
				@entity_list.each do |entity|
					eval "entity#{@constraint.message} = #{new_value}"
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