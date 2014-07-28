#!/usr/bin/env ruby

require 'rubygems'
require 'gosu'



path_to_file = File.expand_path(File.dirname(__FILE__))

path = File.join '.', '..', '..'
path_to_root = File.expand_path path, path_to_file

puts path_to_root


Dir.chdir File.join path_to_root, 'lib', 'ThoughtTrace', 'style' do
	require './cascade'
	require './pallet'
	require './style'
	
	require './style_system'
end

Dir.chdir File.join path_to_root, 'experimental', 'style_system' do
	require './color'
end




# pack
color = Gosu::Color.argb 0xffAABBCC
data = color.pack
puts data.to_s 16



style = ThoughtTrace::Style::StyleObject.new
style[:color] = color
p style

data = style.pack
p data




pallet = ThoughtTrace::Style::Pallet.new
pallet[:foo] = style
	
	pallet[:baz] = ThoughtTrace::Style::StyleObject.new
	pallet[:baz][:prop1] = 5
	pallet[:baz][:prop2] = 23

	pallet[:bar] = ThoughtTrace::Style::StyleObject.new
	pallet[:bar][:prop1] = 5
	pallet[:bar][:prop2] = 7

p pallet


data = pallet.pack
p data



puts
puts "=================="
puts





# unpack
new_pallet = ThoughtTrace::Style::Pallet.unpack data
p new_pallet


new_style = new_pallet[:foo]
p new_style



puts "\n\n"
puts "------------"

puts "same pallet? #{new_pallet == pallet}"
puts "same style?  #{new_style  == style}"
puts "same color?  #{new_style[:color] == style[:color]}"



puts
puts
puts



cascade = ThoughtTrace::Style::Cascade.new pallet
cascade.add :foo
p cascade

data = cascade.pack
p data














puts
puts


puts "========================="


container = ThoughtTrace::Style::StyleSystem.new "path/to/project/root/here"
	# ----- pallet -----
	container.add_pallet("test_pallet", ThoughtTrace::Style::Pallet.new).tap do |pallet|
		pallet[:foo] = ThoughtTrace::Style::StyleObject.new
		pallet[:foo].tap do |style|
			style[:color] = Gosu::Color.argb 0xffAABBCC
		end
		
		pallet[:baz] = ThoughtTrace::Style::StyleObject.new
		pallet[:baz].tap do |style|
			style[:prop1] = 5
			style[:prop2] = 23
		end
		
		pallet[:bar] = ThoughtTrace::Style::StyleObject.new
		pallet[:bar].tap do |style|
			style[:prop1] = 5
			style[:prop2] = 7
		end
	end
	
	
	
	# ----- cascade -----
	pallet = container.get_pallet "test_pallet"
	cascade = ThoughtTrace::Style::Cascade.new pallet
	container.add_cascade("test_cascade", cascade).tap do |cascade|
		cascade.add :foo
	end

p container
puts
p container.pack

# puts name
# puts "pallets"
# pallets.each{   |x|  print"\t"; p x }
# puts "cascades"
# cascades.each{  |x|  print"\t"; p x }



puts "========================="




















# dump
Dir.chdir File.join path_to_root, 'experimental', 'style_system' do
	pallet.dump File.join Dir.pwd, 'out'
end
