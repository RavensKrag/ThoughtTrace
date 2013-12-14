# organize a bunch of action into a nice collection
module TextSpace
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
		
		def [](action_class)
			# TOOD: accessing items by name should really be constant time
			
			i = @list.index{ |action| action.class == action_class }
			
			raise "No action registered of type #{action_class}" unless i
			
			
			return @list[i]
		end
		
		def each(&block)
			@list.each(&block)
		end
		
		include Enumerable
	end
end