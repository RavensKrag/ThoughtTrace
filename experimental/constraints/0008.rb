# check the data here
# if it's changed, transform it, and ship it over there
# when the data gets over there, see if it's different
# if the data is different, apply it
# if data has been applied, the data has changed
# if the data has changed, transform it and ship it to the places that need it


cache = Hash.new

cache[entity] = data


# dependency assertion function
# when the values specified by this function change,
# then the associated constraint will be fired
p = ->(entity){
	[
		entity[:physics].height
	]
}
# p[entity]


cache[entity] = p[entity]







def save(entity)
	@cache[entity] = foo(entity)
end

def load(entity)
	@cache[entity]
end

def changed?(entity)
	data = load(entity)
	
	if data == nil
		save(entity)
		return true
	else
		return data != foo(entity)
	end
end



# list the things that will be changed
# needed to figure out when the entities are changing
def foo(entity)
	[
		entity[:physics].height
	]
end

# execute one tick
def call(a,b)
	
end


# PropagatingConstraint
def filter
	p = Proc.new do |a,b|
		changed?(a)
	end
	
	return p
end

# LimitingConstraint
def filter
	p = Proc.new do |a,b|
		changed?(b)
	end
	
	return p
end

# NOTE: with the current implementation of #changed? and how it related to #filter, only one constraint will be able to fire off of a change in a particular Entity



selection = @entities.select &constraint.filter
selection.each{ |a,b|  constraint.call(a,b)  }
