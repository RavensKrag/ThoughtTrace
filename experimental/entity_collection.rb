# associates an obj with an integer IDs
# IDs are guaranteed to be unique
# (would be nice to guarantee that they were also in continuous sequence but idk how to do that)

class Collection
	def initialize(space)
		@space = space
		
		@obj_to_index = Hash.new
		@index_to_obj = Hash.new
		
		@next_i = 0
	end
	
	def add(object)
		i = @next_i
		@index_to_obj[i] = object
		@obj_to_index[object] = i
		
		@next_i += 1
	end
	
	def delete(object)
		i = @obj_to_index[object]
		
		@obj_to_index.delete object
		@index_to_obj.delete i
	end
	
	# swap the items at the two indicies given
	def swap(i,j)
		@obj_to_index[@index_to_obj[i]] = j
		@obj_to_index[@index_to_obj[j]] = i
		
		temp = @index_to_obj[i]
		@index_to_obj[i] = @index_to_obj[j]
		@index_to_obj[j] = temp
	end
	
	# given an object, retrieve its index
	def [](object)
		return @obj_to_index[object]
	end
	
	
	def each(&block)
		unless block
			# return an enumerator if there is no block
			return nil
		end
		
		
		
		
		
		# requires sorting, which is bad
		@index_to_obj.keys.sort.each do |i|
			block.call @index_to_obj[i]
		end
		
		
		# refrains from sorting,
		# but you get more 'cache misses' as time goes on
		# because there will be holes in the data upon deletion
		# 
		# I implemented #gc in order to help fix that issue,
		# but having to remember to GC regularly could be it's own problem
		@next_i.times do |i|
			obj = @index_to_obj[i]
			next if obj.nil?
			
			block.call obj
		end
	end
	
	include Enumerable
	
	
	
	# Compress the range of used indicies, such that there are no gaps.
	# 
	# ie) after running #gc, all indicies in the range [0..@next_i) will be occupied
	# ( Although, that may be confusing, as @next_i will be reset as well )
	def gc
		# create a list of valid indicies, in order from low to high
		index_list = @next_i.times.select{|i|  @index_to_obj[i]  }
		
		
		# remap that onto a compressed range, with no gaps
		obj_list = index_list.collect{|i|  @index_to_obj[i] }
			
			# clear out the maps, so you don't get any weird garbage data left over
			# 
			# note that if the value if @next_i decrease at the end of this operation,
			# there would be indicies that correspond to duplicate data.
			# @obj_to_index would be ok, but @index_to_object will have issues
			@index_to_obj.clear
			# @obj_to_index.clear
			
		obj_list.each_with_index do |obj, i|
			@index_to_obj[i] = object
			@obj_to_index[object] = i
		end
		@next_i = obj_list.size
		
		
		# alternative clean up method to using #clear
		@index_to_obj.delete_if{ |i,obj|  i >= @next_i }
		
		
		raise "Remapping failed" unless @index_to_obj.size == @obj_to_index.size
	end
end

