require 'rubygems'

require 'rake'
require 'rake/clean'

# -- file hierarchy --
		# ROOT
		# 	this directory
		# 		this file

# Must expand '..' shortcut into a proper path. But that results in a shorter string.
PATH_TO_ROOT = File.expand_path '../..', __FILE__




task :default => :run

# run the program
task :run => [:build_serialization_system, :load_dependencies, :load_main] do
	# filepath = ARGV[0]
	# filename ||= "default.yml"
	# raise "No file path specified" unless filepath
	
	x = Window.new './data/test'
	x.show
	x.on_shutdown
end

task :build_serialization_system do
	path = File.join PATH_TO_ROOT, 'bin'
	Dir.chdir path do
		system "object-packer.rb"
	end
end

task :load_dependencies do
	Dir.chdir PATH_TO_ROOT do
		require './lib/ThoughtTrace'
	end
end

task :load_main do
	require './main'
end






task :document_test => [:build_serialization_system, :load_dependencies] do
	path = File.join(PATH_TO_ROOT, 'experimental', 'document_format')
	Dir.chdir path do
		require './test'
	end
end

task :method_probing_test => [:build_serialization_system, :load_dependencies] do
	style_component   = ThoughtTrace::Components::Style.new
	cascade           = ThoughtTrace::Style::Cascade.new
	style_object      = ThoughtTrace::Style::StyleObject.new "test name"
	
	
	
	
	
	standard_methods = 1.methods
	
	
	puts "=== instance methods"
	puts "component"
	p style_component.methods - standard_methods
	puts "\n"
	
	puts "cascade"
	p cascade.methods - standard_methods
	puts "\n"
	
	puts "style"
	p style_object.methods - standard_methods
	puts "\n"
	
	puts "standard shared methods"
	p standard_methods
	puts "\n"
	
	
	
	
	
	
	standard_methods = 1.class.methods
	
	
	puts "=== class methods"
	puts "component"
	p style_component.class.methods - standard_methods
	puts "\n"
	
	puts "cascade"
	p cascade.class.methods - standard_methods
	puts "\n"
	
	puts "style"
	p style_object.class.methods - standard_methods
	puts "\n"
	
	puts "standard shared methods"
	p standard_methods
	puts "\n"
end



# test constraint objects
# (just saving constraints, no Entity bindings are saved in this test)
task :constraint_test => [:build_serialization_system, :load_dependencies] do
	# sample entities
	e1 = ThoughtTrace::Rectangle.new(100, 200)
	e2 = ThoughtTrace::Rectangle.new(20,  50)
	
	
	
	
	
	
	
	
	
	# === Setup
	# resources = ResourceList.new
	resources = ThoughtTrace::Constraints::ResourceCollection.new
	p resources
	
	
	# === Initialize constraint (to be done via GUI)
	# id = resources.add ThoughtTrace::Constraints::LimitHeight.new
	id = resources.add LimitHeight.new
	
	
	
	# === Code to declare closure, with default parameter values
	foo = ->(resources){
	
	# NOTE: in production code, ID needs to be hardcoded, because the closure definition happens in a separate file, and at a separate time, relative to the declaration of the constraint.
	
	constraint = resources[id]
	constraint.closure
		.let :a => 0.8 do |vars, h|
			puts "--> closure"
			# 0.8*h
			puts vars.class
			vars[:a]*h
		end
	
	}
	foo[resources]
	
	
	
	
	
	# === Run the constraint closure closure
	# (want to test just the closure, without considering the Entity system)
	constraint = resources[id]
	test = constraint.closure.call 50
		 # just need to send some random number to populate the 'h' seen in the closure
	
	
	
	
	# === Run the constraint (will run the closure as well)
	constraint = resources[id]
	
	puts "execute constraint with closure"
		a = e2[:physics].shape.height * 0.8
		b = constraint.call(e2, e1) # A limits B
		c = e1[:physics].shape.height
	x = [test, a,b,c]
	p x
	puts "YES" if x.all?{|i| i == x[0] } # all values are the same
	
	
	
	
	
	
	
	
	puts "--------------------------"
	# === Serialization
	# dump
	data_dump = resources.pack
	puts "=> data dump"
	p data_dump
	
	
	puts
	
	
	# sample data modification
	puts "=> altering data..."
	# (this simulates changing the data through the GUI)
	data_dump[id][1][:a] = 0.3 # change parameter :a to 0.3
	
	
	puts
	
	
	# load
	resources = ThoughtTrace::Constraints::ResourceCollection.unpack(data_dump)
	foo[resources]
	puts "=> loaded resource list"
	p resources
end


# test caching facilities, to make sure constraint only fires one tick,
# even if update is called many times
task :constraint_cache_test => [:build_serialization_system, :load_dependencies] do
		# === Setup
	# constraint_objects = ResourceList.new
	constraint_objects = ThoughtTrace::Constraints::ResourceCollection.new
	p constraint_objects
	
	
	# === Initialize constraint (to be done via GUI)
	id = constraint_objects.add LimitHeight.new
	
	
	
	# === Code to declare closure, with default parameter values
	foo = ->(collection){
	
	constraint = collection[id]
	constraint.closure
		.let :a => 0.8 do |vars, h|
			# 0.8*h
			vars[:a]*h
		end
	
	}
	foo[constraint_objects]
	
	
	
	
	
	
	
	
	# sample entity data
	e1 = ThoughtTrace::Rectangle.new(100, 200)
	e2 = ThoughtTrace::Rectangle.new(20,  50)
	
	
	a = e2
	b = e1
	
	
	# Package the constraint, to allow GUI graph system to feed entities into it
	constraint = constraint_objects[id]
	
	visualization = ThoughtTrace::Constraints::Visualizations::DrawEdge.new # old vis path
	package = ConstraintPackage.new(constraint, visualization)
	
	
	collection = ThoughtTrace::Constraints::Collection.new
	
	
	
	collection.add package
	
	
	# bind the constraint
	
	package.marker_a.bind_to a
	package.marker_b.bind_to b
	
	package.marker_a[:physics].body.p = a[:physics].shape.center.clone
	package.marker_b[:physics].body.p = b[:physics].shape.center.clone
	
	
	
	# NOTE: due to the implementation of the constraint, just because the constraint RUNS doesn't necessarily means that it has to change any data. That being said, data should only be mutated if the constraint actually fires.
		# ex) LimitHight will not update values if the height to be constrained is already UNDER the threshold
	
	
	
	test_package = ->(){
		# execute the constraint package
		puts "running package..."
		status = package.update
		puts status
	}
	
	test_constraint = ->(){
		# run just the constraint
		puts "running constraint..."
		constraint.call(a,b)
	}
	
	check_values = ->(){
		x = a[:physics].shape.height
		y = b[:physics].shape.height
		p [x,y]
	}
	
	
	
	# test caching
	test_package[]
	check_values[]
	puts
	
	test_package[]
	check_values[]
	puts
	
	test_package[]
	check_values[]
	puts
	
	# test_constraint[]
	# check_values[]
	# puts
end





# test serialization of parameterized constraint objects (just saving constraints, no bindings)
task :constraint_collection_test => [:build_serialization_system, :load_dependencies] do
	# === Setup
	# constraint_objects = ResourceList.new
	constraint_objects = ThoughtTrace::Constraints::ResourceCollection.new
	p constraint_objects
	
	
	# === Initialize constraint (to be done via GUI)
	id = constraint_objects.add LimitHeight.new
	
	
	
	# === Code to declare closure, with default parameter values
	foo = ->(collection){
	
	constraint = collection[id]
	constraint.closure
		.let :a => 0.8 do |vars, h|
			# 0.8*h
			vars[:a]*h
		end
	
	}
	foo[constraint_objects]
	
	
	
	
	
	
	
	
	# sample entity data
	e1 = ThoughtTrace::Rectangle.new(100, 200)
	e2 = ThoughtTrace::Rectangle.new(20,  50)
	
	
	entity_to_id_table = {
		e1 => 1,
		e2 => 2
	}
	
	constraint_to_uuid_table = constraint_objects.map_data_to_uuids()
	
	
	
	
	
	
	
	
	
	a = e2
	b = e1
	
	
	# Package the constraint, to allow GUI graph system to feed entities into it
	constraint = constraint_objects[id]
	visualization = ThoughtTrace::Constraints::Visualizations::DrawEdge.new # old vis path
	
	package = ConstraintPackage.new(constraint, visualization)
	
	
	collection = ThoughtTrace::Constraints::Collection.new
	
	
	
	collection.add package
	
	
	# add markers to space
	# (dummy test)
	entity_to_id_table[package.marker_a] = 3
	entity_to_id_table[package.marker_b] = 4
	
	
	
	
	# bind the constraint
	
	package.marker_a.bind_to a
	package.marker_b.bind_to b
	
	package.marker_a[:physics].body.p = a[:physics].shape.center.clone
	package.marker_b[:physics].body.p = b[:physics].shape.center.clone
	
	
	
	# try to save the entire collection
	data = collection.pack
	
	visualizations, constraint_data = data
	
	
	constraint_data.each do |record|
		record.map! &replace_according_to(entity_to_id_table)
		record.map! &replace_according_to(constraint_to_uuid_table)
	end
	
	
	p visualizations
	puts "--"
	p constraint_data
	
	

	
	puts "--------------------------"
	# === Serialization
	# dump
	data_dump = constraint_objects.pack
	puts "=> data dump"
	p data_dump
	
	
	puts
	
	
	# load
	constraint_objects = ThoughtTrace::Constraints::ResourceCollection.unpack(data_dump)
	foo[constraint_objects]
	puts "=> loaded resource list"
	p constraint_objects
	
	
	
	
	
	
	
	
	# === Equality test
	original = nil
	serialized_copy = nil
	
	x = 
		[original, serialized_copy].collect do |collection|
			e1 = ThoughtTrace::Rectangle.new(100, 200)
			e2 = ThoughtTrace::Rectangle.new(20,  50)
			
			
			
			
			a = nil
			
			
			
			b = nil
			
			
			
			c = nil
			
			
			[a,b,c]
		end
	
	if x.all?{|i| i == x[0] } # all values are the same
		puts "PASS"
	else
		puts "FAIL"
	end
end