module ThoughtTrace


class Space < CP::Space
	attr_reader :entities, :queries, :constraints, :groups
	
	def initialize
		@entities =	EntityList.new self
		@queries = QueryList.new self
		@constraints = ConstraintList.new self
		@groups = GroupList.new self
		
		# TODO: may want to separate physics space stuff from other attributes not directly related to spatial data
		
		# set variables needed for physics space
		# iteration constants, etc
		@dt = 1.0/60
		
		super()
	end
	
	def update
		[@entities, @queries, @constraints, @groups].each do |collection|
			collection.each &:update
		end
		
		step(@dt)
	end
	
	def draw
		[
			@entities,
			@queries,
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
			@queries,
			@constraints,
			@groups
		].each do |collection|
			collection.delete_if &:gc?
		end
	end
	
	
	
	
	
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
	
	class QueryList < List
		# def add(object)
			
		# end
		
		# def delete(object)
			
		# end
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