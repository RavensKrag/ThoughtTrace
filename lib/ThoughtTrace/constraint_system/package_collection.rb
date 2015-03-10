module ThoughtTrace
	module Constraints


# stores full constraint packages,
# with visualizations and markers, and entity bindings 
class PackageCollection
	def initialize
		@list = Array.new
	end
	
	
	# currently assuming constraints are method objects
	# yes. method. objects.
	# take the containing object and call #method(name) to retrieve the method object
	def add(package)
		# package could be a ConstraintPackage, or it could just be a raw Constraint
		# (the latter case is an optimization, not a "normal" thing)
		@list << package
	end
	
	def update
		@list.each do |package|
			package.update
		end
	end
	
	def draw
		@list.each do |package|
			# raw Constraint objects don't have visualizations, so not all objects will #draw
			package.draw if package.respond_to? :draw
		end
	end
	
	
	
	
	def each(&block)
		@list.each(&block)
	end
	
	include Enumerable
end



end
end