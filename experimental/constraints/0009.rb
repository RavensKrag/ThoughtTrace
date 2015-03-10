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







# think of Constraint objects as curryied functions -
# they accept parameters on init that may alter the function #call
# and contain a function #foo that lists dependencies
# but they are fundamentally centered around the #call function, and store no state about that call
# thus, one Constraint object could be used in multiple places
class Constraint
	# accept parameters that can be used to alter the #call step
	def initialize
		
	end
	
	
	# list the things that will be changed
	# needed to figure out when the entities are changing

	# dependency, prerequisite?
	# (is it a concurrent dependency? - interrelated, correlated)
	def foo(a,b)
		# NOTE: I didn't want to have to list out things like this, but as you can see from the previous sketches, things get WAY uglier if you try to do without this simple list. Just write the list. Maybe get a tool to write the lists later? but the system needs these simple lists.
		# NOTE: never include stateful objects in this list. This list should be completely 'state-free'....? idk what to call that
		[
			a[:physics].height
		]
	end

	# execute one tick
	def call(a,b)
		
	end
end








# don't need to serialize the cache,
# so it's nice to have it as a separate object :D
cache = Hash.new

monad = Monad.new(@entities)

constraint = Constraint.new


monad.all_pairs do |a,b|
	# for each pair
	# generate prereq measurement data
		# if the data is the same as the last time
			# then nothing has changed, don't run
		# if the data is different
			# then something has changed, run the constraint
	data = constraint.foo(a,b)
	key = [a,b]
	
	
	if cache[key]
		if cache[key] == data
			# no change
		else
			# something's up
			# run it again
			constraint.call(a,b)
		end
	else
		# no data stored yet
		cache[key] = data
		next
	end
end
























# don't need to serialize the cache,
# so it's nice to have it as a separate object :D
cache = Hash.new

monad = Monad.new(@entities)

constraint = Constraint.new


monad.all_pairs do |a,b|
	data = constraint.foo(a,b)
	key = [a,b]
	
	
	if cache[key]
		# call the constraint if the value has changed
		constraint.call(a,b) if cache[key] != data
	else
		# no data stored yet
		cache[key] = data
		next
	end
end


# wait but that never sets the cache data again after the first tick....























# don't need to serialize the cache,
# so it's nice to have it as a separate object :D
cache = Hash.new

monad = Monad.new(@entities)

constraint = Constraint.new


monad.all_pairs do |a,b|
	data = constraint.foo(a,b)
	key = [a,b]
	
	
	if cache[key]
		# call the constraint if the value has changed
		if cache[key] != data
			constraint.call(a,b) 
			cache[key] = data
		end
	else
		# no data stored yet
		cache[key] = data
		next
	end
end