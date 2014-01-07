#!/usr/bin/env ruby
Dir.chdir File.dirname(__FILE__)

require 'csv'


# raw_csv_data = <<END_OF_STRING
# font,height,x,y,text


# "Lucida Sans Unicode",53.0,83.0,557.0,"alt"
# "Lucida Sans Unicode",53.0,83.0,557.0,"ctrl"
# "Lucida Sans Unicode",53.0,83.0,557.0,"shift"

# END_OF_STRING



raw_csv_data = <<END_OF_STRING
font,text,height,x,y


Lucida Sans Unicode,left,50.0,300.0,25.0
Lucida Sans Unicode,middle,51.0,534.0,26.0
Lucida Sans Unicode,right,47.0,831.0,27.0
Lucida Sans Unicode,scroll up,45.0,1079.0,31.0
Lucida Sans Unicode,scroll down,48.0,1307.0,29.0
Lucida Sans Unicode,shift,48.0,71.0,148.0
Lucida Sans Unicode,ctrl,58.0,71.0,355.0
Lucida Sans Unicode,alt,53.0,83.0,557.0

END_OF_STRING







raw_csv_data.gsub! /^$\n/, '' # remove empty lines



CSV::Converters[:blank_to_nil] = lambda do |field|
  field && field.empty? ? nil : field
end
csv = CSV.new(raw_csv_data, 
		:headers => true,
		:header_converters => :symbol,
		:converters => [:all, :blank_to_nil]
	)
data = csv.to_a.map {|row| row.to_hash }
# data = csv.to_a

data.each{ |i| p i } # print each hash on a separate line
