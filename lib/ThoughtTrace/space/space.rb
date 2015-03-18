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
			collection.delete_if &:gc?
		end
	end
	
	
	
	
	
	extend Forwardable
	def_delegators :@space,
		:add_collision_handler, :remove_collision_handler,
	# TODO: consider just binding this new Space class to the collision manager class? not really sure that the collision handler binding methods should be exposed like this
	
	
	
	
	
	class List < Array
		def initialize(space)
			@space = space
		end
		
		def add(object)
			self.push object
		end
		
		def delete(object)
			super(object)
		end
		
		
		
		
		
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
	
	class EntityList < List
		# store a counter of the next z index to assign
		# assign the next index when a new object is added
		# never decrement the counter, though.
		# also: do not serialize the counter - 
		# The order of Entities in the data file will determine their z-index,
		# which will be in the same order as the order of elements in the collection.
		# This does not guarantee that all indicies in a range will be occupied,
		# but it does guarantee that no index will be used more than once.
		# The 'no duplication' part is what is truly important.
		# You can thus 'compress' the indicies that are being used by restarting.
		# 
		# The z-index of each object is not super important: what is important is the sorting relative to each other.
		# Don't try to hard-code things about z-indidies, should just reference the z-index of another object by pointer or w/e
		# 
		# Remember that when you swap positions of things in the list, you need to swap their z-index values as well. But because of what has been said previously, you can't assume that the z-index will always be the same as the position in the array. (deletions would get messy really fast)
		# Should implement a simple interface for swapping positions in the list, for rearranging elements
		
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
	end
	
	class GroupList < List
		# def add(object)
			
		# end
		
		# def delete(object)
			
		# end
	end
end



end