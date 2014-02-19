physics shapes
resize
other actions that modify shapes
what methods should go where

Test.new





class Foo < Entity
	def initialize
		super()
		
						body = CP::Body.new
						shape = CP::Shape.new body 
		add_component TextSpace::Components::Physics.new body, shape
		
		add_action TextSpace::Actions::Move.new
	end
end

x = Foo.new

x.components[:physics]
x.component(:physics)
x.components(:physics)
x[:physics]