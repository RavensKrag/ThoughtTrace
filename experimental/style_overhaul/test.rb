#!/usr/bin/env ruby



#!/usr/bin/env ruby

require 'rubygems'
require 'require_all'
require 'gosu'




path_to_file = File.expand_path(File.dirname(__FILE__))

path = File.join '.', '..', '..'
path_to_root = File.expand_path path, path_to_file

puts path_to_root


Dir.chdir File.join path_to_root, 'experimental', 'style_overhaul' do
	require './pallet'
	require './cascade'
	require './style'
	
	require './style_component'
end



# note that names can change
# but IDs never change
# (IDs should persist even across sessions)




pallet = Pallet.new


entity = Hash.new # (dummy Entity to provide equivalent interface to the Style component)
entity[:style] = Components::Style.new

p entity[:style][:color]











# style = Style.new "test name"
# pallet.add style



# id_list = pallet
# 			.select{   |id, style|  style.name =~ /SOMETHING/  }
# 			.collect{  |id, style|  id }


# id_list.each{ |style_id|  cascade.add style_id }




# lookup_table = Hash.new
# id_list.each do |style_id|
# 	style = lookup_table[style_id]
	
	
# end



# # still not sure where names should go though....
# # probably going to delay that until I can get this into production