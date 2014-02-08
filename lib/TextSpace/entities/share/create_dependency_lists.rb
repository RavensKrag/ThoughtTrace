# NOTE: a deep understanding of metaclasses reveals that any class method can be called from within the class definition.


=begin
	example of mixin use:
	
	
	class Foo
		include DependencyListing
		dependency_types :one, :two, :three
	end

	Foo.dependencies[:one]
	=> []
=end

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
				
				# Need to mark the symbol as a symbol
				# because during string interpolation it becomes a string,
				# and then during eval it becomes just a normal variable name
				
				class_eval do
					private_meta_def type do |*args|
						@dependencies[type] = args
					end
					
					
					# Set up hash that lives at the root
					#   Freeze the arrays, because they're really just null objects.
					#   Don't want them to be accidentally contaminated.
					@dependencies ||= Hash.new
					@dependencies[type] = [].freeze
				end
			end
		end
		
		def dependencies
			return @dependencies
		end
		
		
		
		
		
		def inherited(subclass)
			# Attach instance variables to the metaclasses of newly formed child classes
			# clone from the root, which should always remain pristine
			
			# NOTE: This is really fragile code, built on janky assumptions.
			# The only reason the root is staying clean even though this is NOT a deep copy
			# is that the arrays that default to empty in the root hash
			# are being replaced by completely new arrays when the component / action list is set
			dep = @dependencies
			
			subclass.class_eval do
				@dependencies = dep.clone
			end
		end
	end
end