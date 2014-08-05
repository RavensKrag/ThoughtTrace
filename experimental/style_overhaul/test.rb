#!/usr/bin/env ruby



#!/usr/bin/env ruby

require 'rubygems'
require 'require_all'
require 'gosu'




path_to_file = File.expand_path(File.dirname(__FILE__))

path = File.join '.', '..', '..'
path_to_root = File.expand_path path, path_to_file

puts path_to_root


Dir.chdir File.join path_to_root, 'lib', 'ThoughtTrace' do
	require_all './utilities'
end


Dir.chdir File.join path_to_root, 'lib', 'ThoughtTrace', 'style' do
	require './pallet'
	require './cascade'
	require './style'
end

Dir.chdir File.join path_to_root, 'lib', 'ThoughtTrace', 'entities', 'components' do
	require_all './../share/'
	require './component'
	require './style'
end




# note that names can change
# but IDs never change
# (IDs should persist even across sessions)


entity = Hash.new # (dummy Entity to provide equivalent interface to the Style component)
entity[:style] = ThoughtTrace::Components::Style.new
entity[:style].primary_style[:color] = "BLACK"


style = ThoughtTrace::Style::StyleObject.new



entity[:style].mode = :default                 # switch to mode with the given name

entity[:style].read(:color)                    # read from entire cascade
entity[:style].write(:color, "RED")            # write to primary style
entity[:style].socket(1, style)                # place a given style in the specified index
entity[:style].unsocket(1)                     # remove the style at the specified index
# entity[:style].move(from:2, to:6)              # move style from one index to another
# entity[:style].move_up(2)                      # move style in index 2 up one slot
# entity[:style].move_down(2)                    # move style in index 2 down one slot
entity[:style].each_style{ |style|  p style  } # iterate through all available style objects



puts





p entity[:style]