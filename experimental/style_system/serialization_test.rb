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




pallet = ThoughtTrace::Style::Pallet.new "test_pallet"
pallet [:foo] = style

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


