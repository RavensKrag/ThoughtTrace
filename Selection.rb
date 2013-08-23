require 'set'

module TextSpace
	class Selection
		def initialize
			@set = Set.new
			
			@selected = nil
		end
		
		def add(obj)
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
	end
end