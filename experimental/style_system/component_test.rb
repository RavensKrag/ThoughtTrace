#!/usr/bin/env ruby

require 'rubygems'
require 'require_all'
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




Dir.chdir File.join path_to_root, 'lib', 'ThoughtTrace' do
	require_all './utilities/meta'
	
	require_all './entities/share'
	require './entities/components/component'
	require './entities/components/style'
end










Dir.chdir File.join path_to_root, 'bin', 'data', 'test'

container = ThoughtTrace::Style::StyleSystem.load Dir.pwd


comp1 = ThoughtTrace::Components::Style.new(container, "test_pallet")
comp2 = ThoughtTrace::Components::Style.new(container, "test_pallet")
comp3 = ThoughtTrace::Components::Style.new(container, "test_pallet")



comp2