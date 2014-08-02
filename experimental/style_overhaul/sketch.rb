# entity (component structure)

# basic interface
{
	:style => [
		'primary'
		'slot_1',
		'slot_2',
		'slot_3'
	]
}

# backend data store
{
	:style => {
		:mode1 => [
			'primary'
			'slot_1',
			'slot_2',
			'slot_3'
		],
		:mode2 => [
			'primary'
			'slot_1',
			'slot_2',
			'slot_3'
		]
	}
}

# + store style into any slot arbitrarily
# + find property value though cascade search

entity.mode = :default
entity[:style].primary

entity[:style].move 2, 4
# select the item currently at index 2
# insert a copy before the item at index 4
# delete the original item at index 2
	# arr.insert(j, arr[i]); arr.delete_at(i)

entity[:style][1] = Style.new
entity[:style][2] = other[:style].primary
# should NOT be allowed to slot a new primary style, which resides at index 0







# link styles by name
entity[:style].add p1['first']


# swap styles among a couple pallets
[p1, p2, p3].each do |pallet|
	entity[:style][1] = pallet['a']
	entity[:style][2] = pallet['b']
	entity[:style][3] = pallet['c']
end












# ???
{
	NAME => {
		:property => 'value',
		:prop1 => [],
		:prop2 => 2,
		:prop3 => Gosu::Color.argb(0xffAABBCC)
	}
}