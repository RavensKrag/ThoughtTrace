module TextSpace
	module Actions


class Action
	include DependencyListing
	dependency_types :components, :actions
	
	
	attr_accessor :components, :actions
	
	def initialize
		
	end
	
	def self.interface
		@name
	end
	
	# meta_def methods stick their instance variables on a Class
	# the same way that standard methods stick their instance variables on an Object
	private_meta_def 'interface_name' do |name|
		@name = name
	end
	
	
	
	
	
	
	
	def on_press(point)
		
	end
	
	def on_hold(point)
		
	end
	
	def on_release(point)
		
	end
end



end
end