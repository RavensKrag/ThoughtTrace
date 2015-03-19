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
# Don't try to hard-code things about z-indidies, 
# should just reference the z-index of another object by pointer or w/e

class Collection
	def initialize
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
	
	# don't care
	def empty?
		@obj_to_index.size == 0
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
		
		
		
		# you get more 'cache misses' as time goes on
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
	
	
	
	
	
	
	# TODO: need to figure out how to get this code from List without just copying it over
	
	
	# return a data blob
	def pack
		return self.collect{ |e| pack_with_class_name(e)  }
	end
	
	# take a data blob, and load that data into this object
	# NOTE: this method basically assumes that the current collection is empty. if it's not, weird things can happen
	def unpack(data)
		unless self.empty?
			identifier = "#<#{self.class}:#{object_space_id_string}"
			
			warn "#{identifier}#unpack_into_self may not function as intended because this object is not empty." 
		end
		
		data.each do |row|
			obj = unpack_with_class_name(row)
			self.add(obj)
		end
	end
	
	private
	
	def pack_with_class_name(obj)
		if obj.respond_to? :pack
			return obj.pack.unshift(obj.class.name)
			# [class_name, arg1, arg2, arg3, ..., argn]
		else
			return nil
		end
	end
	
	def unpack_with_class_name(array)
		# array format: same as the output to #pack_with_class_name
		klass_name = array.shift
		args = array
		
		klass = Kernel.const_get klass_name
		
		return klass.unpack *args
	end
end

