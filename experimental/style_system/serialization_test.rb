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

Dir.chdir File.join path_to_root, 'lib', 'ThoughtTrace', 'serialization', 'manual_serialization' do
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
style_id = pallet.add style
	
	id = pallet.add ThoughtTrace::Style::StyleObject.new
	pallet.get_style(id)[:prop1] = 5
	pallet.get_style(id)[:prop2] = 23

	id = pallet.add ThoughtTrace::Style::StyleObject.new
	pallet.get_style(id)[:prop1] = 5
	pallet.get_style(id)[:prop2] = 7

p pallet


data = pallet.pack
p data



puts
puts "=================="
puts





# unpack
new_pallet = ThoughtTrace::Style::Pallet.unpack data
p new_pallet


new_style = new_pallet.get_style style_id
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


container = ThoughtTrace::Style::StyleSystem.new
	# ----- pallet -----
	container.pallets["test_pallet"] = ThoughtTrace::Style::Pallet.new
	container.pallets["test_pallet"].tap do |pallet|
		id = pallet.add ThoughtTrace::Style::StyleObject.new
		pallet.get_style(id).tap do |style|
			style[:color] = Gosu::Color.argb 0xffAABBCC
		end
		
		id = pallet.add ThoughtTrace::Style::StyleObject.new
		pallet.get_style(id).tap do |style|
			style[:prop1] = 5
			style[:prop2] = 23
		end
		
		id = pallet.add ThoughtTrace::Style::StyleObject.new
		pallet.get_style(id).tap do |style|
			style[:prop1] = 5
			style[:prop2] = 7
		end
	end
	
	
	
	# ----- cascade -----
	pallet = container.pallets["test_pallet"]
	cascade = ThoughtTrace::Style::Cascade.new pallet
	container.cascades["test_cascade"] = cascade
	container.cascades["test_cascade"].tap do |cascade|
		cascade.add :foo
		cascade.add :baz
		cascade.add :bar
	end

p container
puts

data = container.pack
p data
puts

new_container = ThoughtTrace::Style::StyleSystem.unpack data
puts "same container? #{new_container == container}"


puts "========================="














# dump
Dir.chdir File.join path_to_root, 'bin', 'data', 'test' do
	pallet.dump File.join Dir.pwd, 'out'
end








Dir.chdir File.join path_to_root, 'bin', 'data', 'test' do
	container.dump Dir.pwd
	
	new_container = ThoughtTrace::Style::StyleSystem.load Dir.pwd
	
	puts "serialization SUCESS!" if new_container == container
end