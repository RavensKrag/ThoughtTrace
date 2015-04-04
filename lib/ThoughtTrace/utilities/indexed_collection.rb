module ThoughtTrace

# associates an obj with an integer IDs
# IDs are guaranteed to be unique
# (would be nice to guarantee that they were also in continuous sequence but idk how to do that)

# might be better to use a linked-list as the backing store,
# but I'm not sure how you would get a fast ID -> object mapping that way.

# Note that for serialization, the order of Entities in the data file will determine their z-index,
# which is the same order as the order of elements in the collection.
# This does not guarantee that all indicies in a range will be occupied,
# but it does guarantee that no index will be used more than once.
# The 'no duplication' part is what is truly important.
# You can thus 'compress' the indicies that are being used by restarting.

# The precise value of the index for each element is not super important:
# what is important is the sorting relative to each other.
# Don't try to hard-code things about z-indicies, 
# should just reference the z-index of another object by pointer or w/e

class IndexedCollection
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
	
	def delete_if # &block
		# this works because deleting will not change the size of the array,
		# and thus can not affect the iteration of #each.
		each do |x|
			if yield x
				delete x
			end
		end
	end
	
	# don't care
	def empty?
		@obj_to_index.size == 0
	end
	
	# swap the items at the two indicies given
	# fast
	def swap(i,j)
		flag1 = @index_to_obj[i].nil?
		flag2 = @index_to_obj[j].nil?
		
		if flag1 or flag2
			ordinal = flag1 ? "First" : "Second"
			
			raise IndexError, "#{ordinal} index given is not a valid index. Expected one of these: #{@obj_to_index.values.sort}"
		end
		
		
		
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
	
	def each_with_index
		return enum_for(:each_with_index) unless block_given?
		
		
		
		# you get more 'cache misses' as time goes on
		# because there will be holes in the data upon deletion
		# 
		# I implemented #gc in order to help fix that issue,
		# but having to remember to GC regularly could be it's own problem
		@index_to_obj.each_with_index do |x,i|
			next if x.nil?
			
			yield x, i
		end
	end
	
	# each implemented in terms of #each_with_index
	# ( it's normally the other way around )
	def each
		return enum_for(:each) unless block_given?
		
		each_with_index do |x, i|
			yield x
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
			@obj_to_index[obj] = i
		end
		
		raise "Remapping failed" unless @index_to_obj.size == @obj_to_index.size
	end
end



end