#!/usr/bin/env ruby



#!/usr/bin/env ruby

require 'rubygems'
require 'require_all'
require 'gosu'




path_to_file = File.expand_path(File.dirname(__FILE__))

path = File.join '.', '..', '..'
path_to_root = File.expand_path path, path_to_file

puts path_to_root


Dir.chdir File.join path_to_root, 'lib', 'ThoughtTrace', 'experimental', 'style_overhaul' do
	require './pallet'
	require './cascade'
	require './style'
end






# # note that names can change
# # but IDs never change
# # (IDs should persist even across sessions)

# pallet = Pallet.new


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