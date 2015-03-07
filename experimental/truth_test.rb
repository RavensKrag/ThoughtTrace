# test for the #within_limiting_set? method in space/queries.rb
foo= ->(x,a,b){
	return false   unless a.include? x    if a
	return false   unless !b.include? x    if b
	
	
	return true
}


[
	[5, [5], [5]],
	[5, [5], []],
	[5, [], [5]],
	[5, [], []],
	[5, [], nil],
	[5, nil, []],
	[5, nil, nil]
].each do |x,a,b|
	out = foo[x,a,b] ? "TRUE " : "false"
	
	a = '[ ]' if a.empty? if a 
	b = '[ ]' if b.empty? if b 
	
	a ||= 'xxx'
	b ||= 'xxx'
	puts "#{out}  |   #{x}      #{a}   #{b}"
end