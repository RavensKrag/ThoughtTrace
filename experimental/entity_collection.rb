# associates an obj with an integer IDs
# IDs are guaranteed to be unique
# (would be nice to guarantee that they were also in continuous sequence but idk how to do that)

# might be better to use a linked-list as the backing store,
# but the Hash is a built-in Ruby type, so it's just easier to get SOMETHING up this way.

class Collection
	def initialize(space)
		@space = space
		
		@obj_to_index = Hash.new
		@index_to_obj = Array.new
	end
	
	# fast ish? don't really care
	def add(object)
		i = @index_to_obj.size
		@obj_to_index[object] = i
		
		@index_to_obj << object
	end
	
	# don't care
	def delete(object)
		i = @obj_to_index[object]
		
		@obj_to_index.delete object
		@index_to_obj[i] = nil
	end
	
	# swap the items at the two indicies given
	# fast
	def swap(i,j)
		@obj_to_index[@index_to_obj[i]] = j
		@obj_to_index[@index_to_obj[j]] = i
		
		temp = @index_to_obj[i]
		@index_to_obj[i] = @index_to_obj[j]
		@index_to_obj[j] = temp
	end
	
	# given an object, retrieve its index
	# fast
	def index_for(object)
		return @obj_to_index[object]
	end
	
	
	include Enumerable
	
	def each_with_index(&block)
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
		@index_to_obj.size.times do |i|
			obj = @index_to_obj[i]
			next if obj.nil?
			
			block.call obj, i
		end
	end
	
	# each implemented in terms of #each_with_index
	# ( it's normally the other way around )
	def each(&block)
		unless block
			# return an enumerator if there is no block
			return nil
		end
		
		each_with_index do |x, i|
			block.call x
		end
	end
	
	
	
	
	
	# Compress the range of used indicies, such that there are no gaps.
	# By simply putting 'nil's into the Array, instead of doing a 'real' delete,
	# you can just move a bunch of things every once in a while.
	# 
	# NOTE: #gc can potentially create garbage in the @index_to_obj collection, because the number of indicies is decreasing. But the @obj_to_index collection will never have more entries than necessary, because the number of objects before and after #gc is constant.
	def gc
		# do a non-in-place operation in attempt to shrink C-Level data store
		@index_to_obj = @index_to_obj.compact
		
		# refresh cache
		@index_to_obj.each_with_index do |obj, i|
			@obj_to_index[object] = i
		end
		
		raise "Remapping failed" unless @index_to_obj.size == @obj_to_index.size
	end
end

