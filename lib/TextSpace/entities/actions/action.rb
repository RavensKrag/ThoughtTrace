class Action
	def initialize(components, actions=nil)
		
	end
	
	
	
	# View this class as an instance, and thus return it's instance variables
	def self.dependencies
		return { :components => @components, :actions => @actions }
	end
	
	def self.foo
		# NOTE: Remember that Class#name is already a thing. Find a new name.
		@name
	end
	
	# meta_def methods stick their instance variables on a Class
	# the same way that standard methods stick their instance variables on an Object
	meta_def 'name' do |name|
		@name = name
	end
	
	meta_def 'components' do |*args|
		@components = args
	end
	
	meta_def 'actions' do |*args|
		@actions = args
	end
	
	meta_eval do
		private :components, :actions
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