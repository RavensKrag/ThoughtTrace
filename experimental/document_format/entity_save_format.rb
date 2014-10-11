# NOTES:
# do NOT want to store Style data in here,
# as the same style object can be used across multiple cascades in various different entities

# the name of a style is not guaranteed to be unique under any circumstances
# it has a similar use to a person's real-world name:
# a friendly and humanistic identifier, rather than a rigorous and unique one
# (in humanistic contexts, usage and context disambiguate more than other factors)


entity_id => {
	physics => {
		:body => [body.p.x, body.p.y]
		:shape => [] # probably needs to be different for different shapes?
	},
	
	
	# component
	style => {
		# cascade
		:default => [
			# style object
			"primary" => {
				:property1 => :value
				:property2 => :value
				:property3 => :value
			},
			"some_other_name" => {		
				:property1 => :value
				:property2 => :value
				:property3 => :value
			}
		],
		:hover => {
			"primary" => {		
				:property1 => :value
				:property2 => :value
				:property3 => :value
			}
		}
	},
	
	query => [:type, arg1, arg2, .., argN]
}
