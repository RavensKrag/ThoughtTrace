# organize a bunch of action into a nice collection
class ActionGroup
	def initialize
		@list = Array.new
	end
	
	def update
		@list.each do |action|
			action.update
		end
	end
	
	def add(*actions)
		@list += actions
	end
end