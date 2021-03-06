module ThoughtTrace

class Space


# NOTE: UI stuff can take advantage of the fact that only one Entity is drawn at each z-index. This means, if you draw a UI overlay at the same index, it will only potentially conflict with one item. In Gosu, there shouldn't be z-fighting even then.
	# But in other rendering systems, you could instead use 'commodore style numbering', and assign automatic indicies like 10, 20, 30, 40, etc, so that there is a guaranteed gap between them where UI things can go.
	# would need to figure out just how much gap is appropriate.
class EntityList < ThoughtTrace::IndexedCollection
	include Packageable
	
	
	attr_reader :offsets
	
	def initialize(space)
		super(space)
		
		
		# each offset must have a different value, and be an integer
		map = {
			:text_caret               =>  4,
			:text_highlight           =>  3,
			:constraint_visualization =>  2,
			:selection_indiv          =>  1,
			:selection_group          => -1
		}
		min, max = map.values.minmax
		range = max - min
		
		
		@z_per_index = range
		@offsets = map
	end
	
	
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
	
	
	
	
	# Convert back and forth between backend index values, and frontend z-index values
	# 
	# backend values, in tightest pack possible, are mapped to all sequential non-negative integers
	# frontend values are spaced out more, so other objects can render between Entity layers
	# 
	# 
	# NOTE: serialization bypasses this indexing scheme by converting the EntityList into an Array
	# Doing these manipulations in an 'in-memory only' way
	# allows for the configuration to be tweaked
	# without altering the saved data format.
	def each_with_index
		return enum_for(:each_with_index) unless block_given?
		
		super do |x,i|
			yield x,i*@z_per_index
		end
	end
	
	def index_for(e)
		super(e)*@z_per_index
	end
	
	def swap(i,j)
		i = i.to_i
		j = j.to_i
		
		raise IndexError, 
			"First index given does not specify an Entity layer" unless i % @z_per_index == 0
		raise IndexError,
			"Second index given does not specify an Entity layer" unless j % @z_per_index == 0
		
		super(i/@z_per_index, j/@z_per_index)
	end
end



end
end