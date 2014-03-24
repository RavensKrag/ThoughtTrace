require 'fileutils'

module ThoughtTrace
	class Space < CP::Space
		def initialize
			@objects =	Array.new
			
			
			# set variables needed for physics space
			# iteration constants, etc
			@dt = 1.0/60
			
			super()
		end
		
		def update
			@objects.each do |obj|
				obj.update
			end
			
			step(@dt)
		end
		
		def draw
			@objects.each do |obj|
				obj.draw
			end
		end
		
		def empty?
			@objects.empty?
		end
		
		def add(object)
			# raise "Physics component on #<#{object.class}:#{object.object_id}> not found." unless object.respond_to? :physics
			
			unless object[:physics]
				msg = <<-ERROR_MESSAGE
					
					#{object.class} does not have a Physics component
				ERROR_MESSAGE
				
				raise msg.multiline_lstrip
			end
			
			@objects << object
			
			add_shape(object[:physics].shape)
			add_body(object[:physics].body)
			
			
			
			# satisfy dependencies on Space for any applicable Actions
			object.action_names.each do |name|
				action = object.send(name)
				if action.respond_to? :space=
					action.space = self
				end
			end
		end
		
		def merge(enum)
			enum.each do |obj|
				self.add obj
			end
			
			# enum.each &:add
		end
		
		def delete(object)
			@objects.delete object
			
			# remove linkage between this space and any Actions
			# (same loop from Space#add)
			object.action_names.each do |name|
				action = object.send(name)
				if action.respond_to? :space=
					action.space = nil
				end
			end
		end
		
		
		
		
		# Clean up unnecessary objects
		# ie, empty strings
		def gc
			@objects.delete_if do |obj|
				obj.gc?
			end
		end
	end
end