#!/usr/bin/env ruby


# note: This file is just a shortcut for the actual rakefile that drives the program. It just makes it easier for other people to be able to start up the program.
path_to_file = File.expand_path(File.dirname(__FILE__))
Dir.chdir path_to_file

`rake`