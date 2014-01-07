#!/usr/bin/env ruby
Dir.chdir File.dirname(__FILE__)

require 'csv'

# given an old header and a new one, update the old CSV data to the new format

# I think you also need to know default values for each possible column,
# just in case there hasn't been any data set for a particular thing


old_csv_header = "font,text,height,x,y"
new_csv_header = "font,height,x,y,text"

default_values = {
	"font" => "Lucida Sans Unicode",
	"height" => 20.0,
	"x" => 10.0,
	"y" => 10.0,
	"text" => "HELLO WORLD!"
}


old_csv_properties = old_csv_header.split ','
new_csv_properties = new_csv_header.split ','

new_csv_properties.each do |property|
	raise "No default value defined for CSV property #{property}" unless default_values.include? p
end


new_csv_data =	old_csv_data.collect do |row|
					new_csv_row_hash = Hash.new
					
					new_csv_properties.each do |property|
						new_csv_row_hash[property] = row[property]
						
						# set default only if there is no property to copy from the old 
						new_csv_row_hash[property] ||= default_values[property]
					end
					
					# Order CSV values according to new header
					old_csv_properties.collect{ |heading| new_csv_row_hash[heading] }.join(',')
				end