class Action
	def initialize(components, actions=nil)
		@components = components
		@actions = actions
	end
	
	
	
	# View this class as an instance, and thus return it's instance variables
	def self.dependencies
		@components ||= Array.new
		@actions ||= Array.new
		
		return {
			:components => @components,
			:actions => @actions
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
	
	private_meta_def 'actions' do |*args|
		@actions = args
	end
	
	
	
	# NOTE: a deep understanding of metaclasses reveals that any class method can be called from within the class definition.
	
	
	
	
	
	# class << self
	# 	def dependencies
	# 		return { :components => @components, :actions => @actions }
	# 	end
		
		
	# 	self.instance_eval do # meta_eval
	# 		define_method 'name' do |name|
	# 			@name = name
	# 		end
			
	# 		define_method 'components' do |*args|
	# 			# @dependencies ||= {
	# 			# 	:components => Array.new,
	# 			# 	:actions => Array.new
	# 			# }.freeze
				
				
	# 			# @dependencies[:components].concat args
				
				
	# 			@components = args
	# 		end
	# 	end
	# end
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	def on_press(point)
		
	end
	
	def on_hold(point)
		
	end
	
	def on_release(point)
		
	end
end