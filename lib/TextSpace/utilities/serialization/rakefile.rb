#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'

require 'gosu'
require 'gl'

require 'DIS'

require 'chipmunk'
require 'require_all'




# require 'rake'
require 'rake/clean'




# Doing it this way obfuscates what is a directory, and what is a file,
# but it makes handling loading files in various directories
# (especially directories that are not children of the current directory)
# much easier to manage and understand.

	# -- file hierarchy --
	# ROOT
	# 	this directory
	# 		this file

# Must expand '..' shortcut into a proper path. But that results in a shorter string.
path_to_root = File.expand_path '../../../../..', __FILE__
full_path = File.join path_to_root, "lib", "TextSpace"


Dir.chdir full_path do
	require './utilities/performance_timer'
	
	Metrics::Timer.new "load scripts" do
	
		[
			'./monkey_patches',
			
			'./utilities/meta',
			'./utilities/font',
			
			'./space',
			
			# require_all seems to snip the Class#inherited callback.
			# wait, but only for recursive add or something?
			# one directory at a time seems to be fine...
			# './entities'
			'./entities/share/',
			'./entities/actions/',
			'./entities/components/',
			'./entities/',
			
			'./cameras/camera',
			
			
			# './input_system'
				'./input_system/human_action',
				
				'./input_system/action_stash',
				'./input_system/action_selector',
				
				'./input_system/input_abstraction',
				# './input_system/human_actions' # currently empty folder
				
				'./input_system/input_manager'
			
		
		
		
		].each do |path|
			begin
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
			rescue LoadError => e
				puts "LOAD ERROR: Failed to load #{path}"
				
				raise e
			end
		end
	
	end
end





# src: http://rosettacode.org/wiki/Strip_comments_from_a_string
class String
  def strip_comment( markers = ['#',';'] )
    re = Regexp.union( markers ) # construct a regular expression which will match any of the markers
    if index = (self =~ re)
      self[0, index].rstrip      # slice the string where the regular expression matches, and return it.
    else
      rstrip
    end
  end
end

class String
	def strip_extension
		File.basename(self,File.extname(self))
	end
end


# TODO: migrate to using Rake asap, so that you can have proper build, clean, and clobber tasks



path_to_this_file = File.expand_path '..', __FILE__
Dir.chdir path_to_this_file



# source files are 'foo.rb' built files are 'foo_reverse.rb'
task :default => :build


COMPILED_FILE_SUFFIX = "_reverse.rb"



CLEAN.include "*#{COMPILED_FILE_SUFFIX}"
# CLOBBER.include

task :build do
	Dir['./*.rb'].each do |file|
		next if File.basename(file) == File.basename(__FILE__)
		next if file.include? COMPILED_FILE_SUFFIX
		
		
		name = file.strip_extension
		puts name
		
		
		
		File.open("#{name}#{COMPILED_FILE_SUFFIX}", 'w') do |f|
		
		
		File.readlines(file).reverse_each do |line|
			# Strip comments
			line = line.strip_comment
			
			# Flip variable assignment over the equal sign
			# ex) x = a ---> a = x
			line = reverse_assigment(line)
			
			
			
			
			# Turn object initialization steps into data extraction steps
			
			
			
			
			
			# TODO: consider omitting lines without equals signs in them
			# probably only need the assignment statement lines, right...?
			
			# TODO: consider omitting lines with bang! operations in them
			# don't really need to know about things that modify internal state, do we...?
			# because the 'reverse' files are for dumping,
			# and you don't really care about the state of the object in memory as you dump
			
			
			# TODO: ignore lines featuring space manipulation (ie: space.add)
			# want to be able to contentiously save
			# maybe the load operations don't really need to explicitly call space?
			# do they really need anything other than adding the object to the space?
			# that could just be a return or something
			# and the return should much more obviously be omitted from the 'reverse' copy
			
			
			
			# If line starts with "return" keyword...
			match = line.match(/return/)
			if match
				if match.begin(0) == 0 # beginning of the match with index 0
					parts = line.split
					parts.shift # eject the return statement, keep the rest of the line
					line = "# examining this object: #{parts.join(' ')}"
				end
			end
			
			
			# If line tries to assign many values into one variable, that is the "return"
			# from the reverse file
			# Using an actual return statement will cause ruby to auto-pack the multi-return
			# into a single array containing all the values.
			# Not sure if this is the way to go or not,
			# but the end result should be an array with the desired values inside of it
			# 
			# Currently looking for just the "args" variable being assigned
			# the equal sign for setting the variable may have any amount of whitespace on either side of it
			regex = /args\s*=\s*/
			match = line.match regex
			if match
				if match.begin(0) == 0 # beginning of the match with index 0
					puts "FOUND IT"
					
					line.sub! regex, "return "
					
				end
			end
			
			
			f.puts line
		end
			
			
		end
	end
end



# All transformation lines below
# all methods written in functional style


# x = a --> a = x
def reverse_assigment(line)
	line = line.split('=').collect{ |i| i.strip }.reverse.join(' = ')
end

def extraction_from_initialization(line)
	if line.include? '.new'
		# format: Class.new arg1, arg2, ..., argn = var
		# result: arg = var.arg
		
		parts = line.split('=').collect{ |i| i.strip }
		# ['Class.new arg1, arg2, ..., argn', 'var']
		
		
		# split up into three segments
		a = parts[0].split('.new')[0].strip
		b = parts[0].split('.new')[1].strip
		c = parts[1]
		
		
		# take all arguments,
		# create one line for each argument that needs to be extracted from the object
		lines =	b.split(/,\s/).collect do |arg|
					"#{arg} = #{c}.#{arg}"
				end
		
		# merge the lines into one blob that will be appended to file
		line = lines.join("\n")
	end
end

