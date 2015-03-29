module ThoughtTrace


class Entity < ComponentContainer
	def initialize(physics_component)
		super()
		
		add_component physics_component
		
		
		style = ThoughtTrace::Components::Style.new
		add_component style
	end
	
	def update
		
	end
	
	def draw(z_index=0)
		
	end
	
	# let Space know that you should be deleted
	# useful for removing empty strings, etc which can not be selected by the user
	# and contain no useful information
	def gc?
		
	end
end



end