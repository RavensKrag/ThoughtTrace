# NOTE: a deep understanding of metaclasses reveals that any class method can be called from within the class definition.


module DependencyListing
	def self.included(base)
		base.class_eval do |klass|
			extend ClassMethods
		end
	end
	
	module ClassMethods
		# does not work as expected,
		# as the arrays are only initialized on the metaclass of Action
		# and not on any of the metaclasses of the child classes of Action (ex. Move)
		
		
		
		def dependency_types(*types)
			types.each do |type|
				# meta_def methods stick their instance variables on a Class
				# the same way that standard methods stick their instance variables on an Object
				
				class_eval %Q{
					private_meta_def '#{type}' do |*args|
						@#{type} = args
					end
				}
			end
		end
		
		def dependencies
			return {
				:components => @components,
				:actions => @actions
			}
		end
		
		
		
		
		
		def inherited(subclass)
			puts "INHERITANCE #{subclass}"
			
			
			# Attach instance variables to the 
			subclass.class_eval do
				@components ||= Array.new
				@actions ||= Array.new
			end
		end
	end
end