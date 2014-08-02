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






# ???
{
	NAME => {
		:property => 'value',
		:prop1 => [],
		:prop2 => 2,
		:prop3 => Gosu::Color.argb(0xffAABBCC)
	}
}