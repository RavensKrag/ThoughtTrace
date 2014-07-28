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




color = Gosu::Color.argb 0xffAABBCC
data = color.pack
puts data.to_s 16



style = ThoughtTrace::Style::StyleObject.new
style[:color] = color

data = style.pack
p data




# new_style = ThoughtTrace::Style::StyleObject.unpack data
# p new_style















require 'csv'

csv_string = 
	CSV.generate do |csv|
		csv << [0xffAABBCC, "testing"]
	end

csv_string.chomp!

p csv_string





data = CSV.parse(
			csv_string,
			:headers => false, :header_converters => :symbol, :converters => :all
		)
p data