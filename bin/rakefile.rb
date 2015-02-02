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



task :constraint_test => [:build_serialization_system, :load_dependencies] do
	# constraint = ThoughtTrace::Constraints::LimitHeight.new
	constraint = Constraint.new
	p constraint
	
	
	
	
	
	
	
	
	
	# === Setup
	# resources = ResourceList.new
	resources = ResourceCollection.new
	p resources
	
	
	# === Initialize constraint (to be done via GUI)
	id = resources.add constraint
	
	
	
	# === Code to declare closure, with default parameter values
	foo = ->(resources){
	
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
	
	
	# === Run the closure
	constraint.closure.call 32
		 # just need to send some random number to populate the 'h' seen in the closure
	
	
	
	
	
	
	puts "--------------------------"
	# === Serialization
	# dump
	data_dump = resources.dump
	puts "=> data dump"
	p data_dump
	
	
	puts
	
	
	# sample data modification
	puts "=> altering data..."
	# (this simulates changing the data through the GUI)
	data_dump[id][1][:a] = 0.3 # change parameter :a to 0.3
	
	
	puts
	
	
	# load
	resources = ResourceCollection.load(data_dump)
	foo[resources]
	puts "=> loaded resource list"
	p resources
	# NOTE: this loads procs, but no guarantee that variables aren't being clobbered (yet). need to get that in before the next commit
		# NOTE: I think it should be working now.
		# NOTE: be aware that serialized variable values override the coded defaults
end


task :constraint_package_test => [:build_serialization_system, :load_dependencies] do
	# sample entities
	e1 = ThoughtTrace::Rectangle.new(100, 200)
	e2 = ThoughtTrace::Rectangle.new(20,  50)
	
	
	
	
	
	
	
	
	
	# === Setup
	# resources = ResourceList.new
	resources = ResourceCollection.new
	p resources
	
	
	# === Initialize constraint (to be done via GUI)
	id = resources.add LimitHeight.new
	
	
	
	# === Code to declare closure, with default parameter values
	foo = ->(resources){
	
	constraint = resources[id]
	constraint.closure
		.let :a => 0.8 do |vars, h|
			# 0.8*h
			vars[:a]*h
		end
	
	}
	foo[resources]
	
	
	# === Run the constraint (will run the closure as well)
	puts "execute constraint with closure"
		a = e2[:physics].shape.height * 0.8
		b = constraint.call(e2, e1) # A limits B
		c = e1[:physics].shape.height
	x = [a,b,c]
	p x
	puts "YES" if x.all?{|i| i == x[0] } # all values are the same
	
	
	
	
	puts "--------------------------"
	# === Serialization
	# dump
	data_dump = resources.dump
	puts "=> data dump"
	p data_dump
	
	
	puts
	
	
	# sample data modification
	puts "=> altering data..."
	# (this simulates changing the data through the GUI)
	data_dump[id][1][:a] = 0.3 # change parameter :a to 0.3
	
	
	puts
	
	
	# load
	resources = ResourceCollection.load(data_dump)
	foo[resources]
	puts "=> loaded resource list"
	p resources
end