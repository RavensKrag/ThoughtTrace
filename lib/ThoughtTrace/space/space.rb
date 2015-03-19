require 'forwardable'

module ThoughtTrace


class Space
	attr_reader :entities, :constraints, :groups
	
	def initialize
		# set variables needed for physics space
		# iteration constants, etc
		@dt = 1.0/60
		
		@space = CP::Space.new
		
		
		
		@entities =	EntityList.new @space
		@groups = GroupList.new @space
	end
	
	def update
		[
			@entities,
			@groups
		].each do |collection|
			collection.each &:update
		end
		
		@space.step(@dt)
	end
	
	def draw
		[
			@entities,
			@groups
		].each do |collection|
			collection.each &:draw
		end
	end
	
	def empty?
		# TODO: consider checking all lists to see if they are empty instead of just @entities
		@entities.empty?
	end
	
	
	def merge(enum)
		enum.each do |obj|
			self.add obj
		end
		
		# enum.each &:add
	end
	
	
	# Clean up unnecessary objects
	# ie, empty strings
	def gc
		[
			@entities,
			@groups
		].each do |collection|
			collection.gc
		end
	end
	
	
	
	
	
	extend Forwardable
	def_delegators :@space,
		:add_collision_handler, :remove_collision_handler,
	# TODO: consider just binding this new Space class to the collision manager class? not really sure that the collision handler binding methods should be exposed like this
	
	
	
	
	
	module Packageable # mixin
		# contract: must define the following - 
			# collect
			# empty?
			# add
		# in order for #pack and #unpack to function
		
		
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
			@index_to_obj.size.times do |i|
				obj = @index_to_obj[i]
				next if obj.nil?
				
				yield obj, i
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


	
	
	class EntityList < Collection
		include Packageable
		
		def add(object)
			# raise "Physics component on #<#{object.class}:#{object.object_id}> not found." unless object.respond_to? :physics
			
			unless object[:physics]
				msg = <<-ERROR_MESSAGE
					
					#{object.class} does not have a Physics component
				ERROR_MESSAGE
				
				raise msg.multiline_lstrip
			end
			
			super(object)
			
			@space.add_shape(object[:physics].shape)
			@space.add_body(object[:physics].body)
		end
		
		def delete(object)
			super(object)
			
			@space.remove_shape(object[:physics].shape)
			@space.remove_body(object[:physics].body)
		end
		
		def gc
			# remove
			self.delete_if do |x|
				x.gc?
			end
			
			# compress index range
			super()
		end
	end
	
	class GroupList
		include Packageable
		
		def initialize(space)
			@space = space
			
			@storage = Array.new
		end
		
		def add(object)
			@storage.push object
		end
		
		def delete(object)
			@storage.delete(object)
		end
		
		def empty?
			@storage.empty?
		end
		
		def each(&block)
			@storage.each &block
		end
		
		include Enumerable
		
		
		def gc
			@storage.delete_if &:gc?
		end
	end
end



end