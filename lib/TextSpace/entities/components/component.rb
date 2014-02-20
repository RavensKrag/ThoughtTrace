module TextSpace
	module Components
		
		
class Component
	include DependencyListing
	dependency_types :components
	
	
	attr_accessor :components
	
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
end



end
end