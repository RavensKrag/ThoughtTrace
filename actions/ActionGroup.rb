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
	
	def [](action_name)
		# TOOD: accessing items by name should really be constant time
		
		i = @list.index{ |action| action.name == action_name }
		
		raise "No action registered with the name #{action_name}" unless i
		
		
		return @list[i]
	end
end