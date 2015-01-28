
ENTITY = 0
ENTITY = 1


# get the entities that have changed since the last frame
modified_assoc = collect_modified_entities(@entity_list)
# returns associative array
[
	[entity, [values, that, were, changed]],
	[entity, [w, x, y, z]],
	[entity, [a, b, c, d]]
]



reference = modified.first

reference.entity
reference.delta.prev
reference.delta.next













# get the entities that have changed since the last frame
modified = collect_modified_entities(@entity_list)

modified.each do |entity|
	next if entity == reference
	
	@constraint.tick(reference, entity)
end








# get the entities that have changed since the last frame
modified = collect_modified_entities(@entity_list)

	# reference = modified.first
	# modified.delete reference
reference = modified.shift # same thing

modified.each do |entity|
	@constraint.tick(reference, entity)
end















# get the entities that have changed since the last frame
modified = @entity_list.collect &modified_entities

	# reference = modified.first
	# modified.delete reference
reference = modified.shift # same thing

modified.each do |entity|
	@constraint.tick(reference, entity)
end










# maybe put a dirty flag on the Entity?
# actions could always set the flag to "yes, dirty"
# and then the flags could be cleared after the constraint update

# this assumes that the only way to edit Entity objects is through Action use
# this is most likely an incorrect assumption...




# if the is a "global" dirty flag
# instead of some flag specific to each constraint type,
# the constraint may sometimes be updated when it is not strictly necessary to do so
# (figuring out when exactly this needs to happen in a dependency graph problem)


# if this is a dependency graph style problem,
# you could try to make the "global" dirty flag hinge
# on the timestamp for "last time this was updated"
# (would be similar to checking file timestamps, and `touch`ing each file to show that it is potentially in need of update)
# again, not sure how to make sure flag only sets set on data write,
# as opposed to on any data access at all (read or write)






# wait, if you have a bunch of synced values,
# you only have to store one point for comparison
# DUH
# because if any of the points differ / drift away from that,
# then some change has occured
# which needs to be propogated
# 
# but this only works for group sync
# it will not work for many other types of constraints