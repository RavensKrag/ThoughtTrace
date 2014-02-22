# Create a new instance of the specified entity type
class NewEntity < HumanAction
	def initialize(entity_class)
		@klass = entity_class
	end
end