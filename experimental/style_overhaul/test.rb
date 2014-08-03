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


entity = Hash.new # (dummy Entity to provide equivalent interface to the Style component)
entity[:style] = Components::Style.new
entity[:style].primary_style[:color] = "BLACK"


entity[:style].mode = :default                 # switch to mode with the given name

entity[:style].read(:color)                    # read from entire cascade
entity[:style].write(:color, "RED")            # write to primary style
entity[:style].socket(1, StyleObject.new)      # place a given style in the specified index
entity[:style].unsocket(1)                     # remove the style at the specified index
# entity[:style].move(from:2, to:6)              # move style from one index to another
# entity[:style].each_style{ |style|   }         # iterate through all available style objects









p entity[:style]