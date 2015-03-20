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
		@entities.each_with_index{ |e,i|  e.draw i }
		@groups.each{ |x| x.draw }
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
		:add_collision_handler, :remove_collision_handler
	# TODO: consider just binding this new Space class to the collision manager class? not really sure that the collision handler binding methods should be exposed like this
end



end