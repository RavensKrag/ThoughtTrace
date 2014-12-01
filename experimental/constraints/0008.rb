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
	@entity = entity
	@data   = foo(entity)
end

def load(entity)
	@data
end

def same_entity?(entity)
	@entity == entity
end

def changed?(entity)
	data = load(entity)
	
	if data == nil
		# constraint has not even run once yet
		save(entity)
		return true
	else
		# this constraint instance has run at least once
		if same_entity?(entity)
			# running on the same entity as last time
			new_data = save(entity)
			return data != new_data
		else
			# trying to run on an entity other than the one to which we are bound
			# return false so that we do not select this entity
			return false
		end
	end
end



# accept parameters that can be used to alter the #call step
def initialize
	
end

# list the things that will be changed
# needed to figure out when the entities are changing

# dependency, prerequisite?
# (is it a concurrent dependency? - interrelated, correlated)
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




# PropagatingConstraint
def choose(a,b)
	return a
end

# LimitingConstraint
def choose(a,b)
	return b
end



# NOTE: with the current implementation of #changed? and how it related to #filter, only one constraint will be able to fire off of a change in a particular Entity



selection = @entities.select &constraint.filter
selection.each{ |a,b|  constraint.call(a,b)  }










all_pairs do |a,b|
	call(a,b) if filter.call(a,b)
end










# try filtering the results this way, so you can catch multiple items
# not sure if this is actually necessary, considering how much the entity list will be constrained

# go through and mark everything that may have changed,
# and then 
# (this implementation assumes the hash backend caching is used. be careful, or the caches could bloat very quicky)

# NOTE: @entities is assumed to hold the entities relevant to this constraint, not ALL entities
require 'set'
monad = Monad.new(@entities)

# select only relevant entities that have changed since the last time the constraint was run
# NOTE: need to revert some changed to #changed?
# constraint ticks are defined pairwise, but constraints may track more than a pair of entity objects
changed_set = @entities.select{ |x| constraint.changed?(x)  }.to_set

selection = monad.all_pairs.select{ |a,b|
				changed_set.include? constraint.choose(a,b)
			}


selection.each{ |a,b|  constraint.call(a,b)  }


