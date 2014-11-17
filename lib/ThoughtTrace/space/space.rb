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
		@constraints = ConstraintList.new @space
		@groups = GroupList.new @space
	end
	
	def update
		[
			@entities,
			@constraints,
			@groups
		].each do |collection|
			collection.each &:update
		end
		
		@space.step(@dt)
	end
	
	def draw
		[
			@entities,
			@constraints,
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
			@constraints,
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
	end
	
	class EntityList < List
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
		end
	end
	
	class ConstraintList < List
		# def add(object)
			
		# end
		
		# def delete(object)
			
		# end
	end
	
	class GroupList < List
		# def add(object)
			
		# end
		
		# def delete(object)
			
		# end
	end
end



end