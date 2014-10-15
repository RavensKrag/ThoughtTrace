require './constraints'
require './prefab_factory'
require './style_collection'

require './yaml/color'

require './document'

puts "=== load complete"


document = ThoughtTrace::Document.new


[
	[166.70833333333326,433.0833333333333,912.4680817284765,288.4436537983972],
	[205.11645320742514,827.3918745069254,71.21295151432058,65.30852761018318],
	[1264.4914532074251,826.3502078402587,71.21295151432058,65.30852761018318],
	[1184.2831198740917,821.1418745069255,71.21295151432058,65.30852761018318],
	[445.74145320742514,828.4335411735921,71.21295151432058,65.30852761018318],
	[364.49145320742514,826.3502078402588,71.21295151432058,65.30852761018318],
	[1105.1164532074254,825.3085411735921,71.21295151432058,65.30852761018318],
	[855.1164532074253,822.1835411735921,71.21295151432058,65.30852761018318],
	[768.6581198740918,822.1835411735921,71.21295151432058,65.30852761018318],
	[283.24145320742514,824.2668745069254,71.21295151432058,65.30852761018318],
	[686.366453207425,819.0585411735921,71.21295151432058,65.30852761018318],
	[1024.9081198740914,825.3085411735922,71.21295151432058,65.30852761018318],
	[599.9081198740919,821.1418745069254,71.21295151432058,65.30852761018318]
].each do |data|
	entity = ThoughtTrace::Rectangle.unpack *data
	document.space.entities.add entity
end

puts "=== entities added to space"




group = ThoughtTrace::Groups::Group.new document.space
document.space.entities.each do |entity|
	group.add entity
end
document.space.groups.add group

puts "=== group added to space"





	style = document.named_styles["Shared Query Style"]

document.space.entities.each do |entity|
	query = ThoughtTrace::Queries::Query.new
	component = ThoughtTrace::Components::Query.new(style, query)
	
	entity.add_component component
end

puts "=== marked queries"





path_to_file = File.expand_path(File.dirname(__FILE__))
Dir.chdir path_to_file do
	d1 = document
	d1.dump('./output')
	
	d2 = ThoughtTrace::Document.load('./output')
	
	
	# TODO: need to find a way to test if the load is decent, but I don't want to write an equality test.
	
	# probably should check the most suspect thing: the colors
	color = d2.named_styles["Shared Query Style"][:color]
	puts color
	p color
	p color.class
	
	
	
	
	original_color = d1.named_styles["Shared Query Style"][:color]
	
	if original_color == color
		puts "color restored successfully"
	else
		puts "ERROR: color data not correct"
		puts "original color:"
		puts original_color.inspect
		puts "loaded color:"
		puts color.inspect
	end
end