#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'

require 'gosu'
require 'gl'

require 'DIS'

require 'chipmunk'
require 'require_all'


# Doing it this way obfuscates what is a directory, and what is a file,
# but it makes handling loading files in various directories
# (especially directories that are not children of the current directory)
# much easier to manage and understand.

	# -- file hierarchy --
	# ROOT
	# 	this directory
	# 		this file

# Must expand '..' shortcut into a proper path. But that results in a shorter string.
path_to_root = File.expand_path '../..', __FILE__
full_path = File.join path_to_root, "lib", "PACKAGE_NAME"

Dir.chdir full_path do
	require './utilities/PerformanceTimer'
	
	Metrics::Timer.new "load scripts" do
	
		[
			'./utilities/serialization',
			'./monkey_patches',
			
			
		
		
		
		
		].each do |path|
			# if it's a path, require_all
			# if it's a file, require
			# ---------------------------
			if File.directory? path
				# puts "LOAD DIR: #{path}"
				require_all path
			# TODO: Figure out why File.file? doesn't work sans extensions like require
			# elsif File.file? path
			else
				# puts "LOAD FILE: #{path}"
				require path
			end
		end
	
	end
end



module DIS
	def self.timestamp
		Gosu::milliseconds
	end
end

