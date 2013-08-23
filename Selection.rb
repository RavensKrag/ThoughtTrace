require 'set'

module TextSpace
	class Selection
		def initialize
			@set = Set.new
			
			@selected = nil
		end
		
		# Collection management
		def add(obj)
			clear
			@selected = obj
		end
		
		def delete(obj)
			# remove single
			if @selected # safe on empty
				@selected.release
				@selected.deactivate
				
				@selected = nil
			end
		end
		
		alias :remove :delete
		
		def clear
			# remove all
			if @selected # safe on empty
				# NOTE: when multiple selection is implemented, this needs to iterate over all selected
				@selected.release
				@selected.deactivate
				
				@selected = nil
			end
		end
		
		
		
		# Properties of selection as a whole
		# for single selection, this is basically just delegation
		# for multiple selection, it operates on the entire group
		def position
			if @selected
				@selected.position
			else
				CP::ZERO_VEC_2
			end
		end
		
		def position=(arg)
			if @selected
				@selected.position = arg
			else
				
			end
		end
	end
end