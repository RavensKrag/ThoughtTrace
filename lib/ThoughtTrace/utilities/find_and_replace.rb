
# returns a Proc which will be used as a block by #map! to perform replacement
def replace_according_to(conversion_table)
	Proc.new do |input|
		output = conversion_table[input]
		output ? output : input
	end
end