class Component
	def initialize(components=nil)
		@components = components
	end
	
	
	
	# View this class as an instance, and thus return it's instance variables
	def self.dependencies
		@components ||= Array.new
		# @actions ||= Array.new
		
		return {
			:components => @components
			# :actions => @actions
		}
	end
	
	def self.interface
		@name
	end
	
	# meta_def methods stick their instance variables on a Class
	# the same way that standard methods stick their instance variables on an Object
	private_meta_def 'interface_name' do |name|
		@name = name
	end
	
	private_meta_def 'components' do |*args|
		@components = args
	end
	
	# private_meta_def 'actions' do |*args|
	# 	@actions = args
	# end
	
	
	
	# NOTE: a deep understanding of metaclasses reveals that any class method can be called from within the class definition.
end