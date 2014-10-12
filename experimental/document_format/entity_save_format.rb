# NOTES:
# do NOT want to store Style data in here,
# as the same style object can be used across multiple cascades in various different entities

# the name of a style is not guaranteed to be unique under any circumstances
# it has a similar use to a person's real-world name:
# a friendly and humanistic identifier, rather than a rigorous and unique one
# (in humanistic contexts, usage and context disambiguate more than other factors)


entity_id => {
	core => {
		# data used by the object, which is not present in any component
		# 
		# the most prevalent example of this is Text,
		# which modifies component values according to other factors
		# (such as font properties)
		# which do not make sense split off into their own component
	}
	
	
	
	
	
	physics => {
		:body => [body.p.x, body.p.y]
		:shape => [] # probably needs to be different for different shapes?
	},
	
	
	# component
	style => {
		# cascade
		:default => [
			# style objects
			0xfffffa, # probably need better identifiers than hex numbers, but w/e good demo
			0xfffffb,
			0xfffffc
		],
		:hover => {
			0xfffffd
		}
	},
	
	query => 0xfffffa
	# NOTE: may have to save the primary style applied while the query mode is active
}



# OK LOOK
# style objects should just have a UUID field or something
# and then they can be serialized using that as the key
# and then BAM
# problem solved
# because you can just dump the cascades using the IDs stored on the style objects
# and then you can serialize the style objects in any order really,
# as long as you hit one of every instance
# (that way, all the data you need is preserved)









# style save format
# (remember, names are not unique IDs, that's why there's a separate ID field)
# (also, not all styles will set the same properties, or even the same *number of properties*)
{
	0xfffffa => [
		"primary",
		{		
			:property1 => :value
			:property2 => :value
			:property3 => :value
		}
	],
	0xfffffb => [
		"some_other_name",
		{		
			:property1 => :value
		}
	],
	0xfffffc => [
		"test",
		{		
			:foo => :value
			:baz => :value
			:qux => :value
		}
	],
	0xfffffd => [
		"primary",
		{		
			:property1 => :value
			:property2 => :value
			:property3 => :value
		}
	]
}


# query save format
{
	0xfffffa => ['class', arg1, arg2, .., argN],
	0xfffffb => ['class', arg1, arg2, .., argN],
	0xfffffc => ['class', arg1, arg2, .., argN]
}