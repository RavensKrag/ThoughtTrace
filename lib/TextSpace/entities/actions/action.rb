module TextSpace
	module Actions


# Things that can be performed on existing Entities
# 
# stored within Entity objects, accessed similar to methods
# mutates data from components
class Action
	include DependencyListing
	dependency_types :components, :actions
	# components :foo, :baz          # data blocks that are manipulated by this Action
	# actions :bleh, :things, :buttz # only actions specified in this list can be triggered
	
	
	attr_accessor :components, :actions
	
	
	
	# The Entity will be the one to actually set this variable.
	# It will be done as the Entity is added into a space.
	# (and cleared when Entity leaves a Space)
	attr_accessor :space # Space the parent Entity is inside of. Used for creating new Entities.
	
	# trying to keep init and setup separated so that the binding between entity and action
	# can be made explicit at the point where the action is declared.
	# Otherwise, you make it seem like the binding is tight, by declaring the two thing together,
	# but the linkage can actually be set to something completely different.
	# That would be weird and dumb.
	def initialize(entity)
		@entity = entity
	end
	
	def self.interface
		@name
	end
	
	# meta_def methods stick their instance variables on a Class
	# the same way that standard methods stick their instance variables on an Object
	private_meta_def 'interface_name' do |name|
		@name = name
	end
	
	
	
	
	
	
	
	
	# Executed before adding to queue
	def setup(stash, point)
		@stash = stash
	end
	
	def update(point)
		
	end
	
	# Executed after removed from queue
	def cleanup
		
	end
end



end
end