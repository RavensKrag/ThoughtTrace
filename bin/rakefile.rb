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
	
	
	constraint.closure
		.let :a => 0.8 do |vars, h|
			# 0.8*h
			vars[:a]*h
		end
end