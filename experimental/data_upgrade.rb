#!/usr/bin/env ruby
Dir.chdir File.dirname(__FILE__)

require 'csv'

f = File.open File.join('..', 'data', 'entities_and_actions.yml')
data = f.read
f.close


clumps = data.split "\n- "

clumps.shift # ignore first clump (it's just the YAML start of document header)
# clumps.each{ |i| puts i; puts}





# pattern = <<EOS
# !<tag:example.com,2012-06-28/TextSpace::Text> "---\n:font: !<tag:example.com,2012-06-28/TextSpace::Font>
#   '--- (.*)\n\n  ...\n\n'\n:string: (.*)\n:height: (.*)\n:position:
#   !<tag:example.com,2012-06-28/CP::Vec2> '---\n\n  - (.*)\n\n  - (.*)\n\n'\n"
# EOS

# pattern = <<EOS
# !<tag:example.com,2012-06-28/TextSpace::Text> "---\n:font: !<tag:example.com,2012-06-28/TextSpace::Font>
#   '--- (.*)\n\n  ...\n\n'\n:string: (.*)\n:height: (.*)\n:position:
#   !<tag:example.com,2012-06-28/CP::Vec2> '---\n\n  - (.*)\n\n  - (.*)\n\n'\n"
# EOS



# pattern = <<EOS
# string: (.*)
# EOS

pattern = <<EOS
  '--- (.*) ...:string: (.*) :height: (.*) :position: (.*)
  !<tag:example.com,2012-06-28/CP::Vec2> (.*) - (.*) - (.*)
EOS
pattern.chomp!

# regex = Regexp.new pattern, Regexp::MULTILINE
# regex = Regexp.new pattern, Regexp::EXTENDED
regex = Regexp.new pattern, Regexp::MULTILINE | Regexp::EXTENDED

p regex

# parse YAML into arrays of values
data_dump =	clumps.collect do |entity_data|
				matchdata = regex.match(entity_data)
				data =	matchdata.captures.collect do |capture|
							capture.gsub! /\\n/, ''
							capture.gsub! /\n/, ''
							
							# remove certain things
							[
								/\.\.\./,
								/---/,
								/'/,
								/"/
							].each do |regex|
								capture.gsub! regex, ''
							end
							
							# Remove excess whitespace
							capture.strip!
							
							
							
							
							capture = nil if capture.empty?
							
							
							capture
						end
				
				# data.compact!
				[3,3].each{ |i| data.delete_at i }
				
				data
			end

# p data_dump


# convert from strings to proper data types
# data_dump.each do |entity_data|
# 	entity_data.collect do |data|
		
# 	end
# end


# convert to CSV
data_dump.collect! do |entity_data|
	entity_data.join(',')
end

data_dump.each{ |i| puts i } # print each CSV data line on a separate line

File.open(File.join(File.dirname(__FILE__), 'test_file') , 'w') do |f|
	data_dump.each{ |i| f.puts i }
end