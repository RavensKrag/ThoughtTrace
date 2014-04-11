require 'fileutils'

module ThoughtTrace


class Space < CP::Space
	attr_reader :entities, :queries, :constraints
	
	def initialize
		# TODO: consider implementing these lists as custom types. Would enable attaching #add / #delete to the collections themselves, instead of the Space as a whole.
		@entities =	EntityList.new self
		@queries = QueryList.new self
		@constraints = ConstraintList.new self
		
		# set variables needed for physics space
		# iteration constants, etc
		@dt = 1.0/60
		
		super()
	end
	
	def update
		@entities.each &:update
		@queries.each &:update
		@constraints.each &:update
		
		step(@dt)
	end
	
	def draw
		@entities.each &:draw
		@queries.each &:draw
		@constraints.each &:draw
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
		@entities.delete_if &:gc?
		@queries.delete_if &:gc?
		@constraints.delete_if &:gc?
	end
	
	
	
	
	
	
	
	class EntityList < Array
		def initialize(space)
			@space = space
			
			@list = Array.new
		end
		
		def add(object)
			# raise "Physics component on #<#{object.class}:#{object.object_id}> not found." unless object.respond_to? :physics
			
			unless object[:physics]
				msg = <<-ERROR_MESSAGE
					
					#{object.class} does not have a Physics component
				ERROR_MESSAGE
				
				raise msg.multiline_lstrip
			end
			
			self.push object
			
			@space.add_shape(object[:physics].shape)
			@space.add_body(object[:physics].body)
			
			
			
			# satisfy dependencies on Space for any applicable Actions
			object.action_names.each do |name|
				action = object.send(name)
				if action.respond_to? :space=
					action.space = @space
				end
			end
		end
		
		def delete(object)
			# remove linkage between this space and any Actions
			# (same loop from Space#add)
			object.action_names.each do |name|
				action = object.send(name)
				if action.respond_to? :space=
					action.space = nil
				end
			end
		end
	end
	
	class QueryList < Array
		def initialize(space)
			@space = space
			
			
		end
		
		def add(object)
			
		end
		
		def delete(object)
			
		end
	end
	
	class ConstraintList < Array
		def initialize(space)
			@space = space
			
			
		end
		
		def add(object)
			
		end
		
		def delete(object)
			
		end
	end
end



end