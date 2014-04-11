# list of entities
entities = [
	one(ClassName,arg1,arg2,arg3,argN),
	two(),
	three()
]

# list of constraints
constraints = [
	a(),
	b(),
	c()
]


# list of queries
# queries take Space as an argument on init,
# but the loading code is housed in Space anyway, so that's not really a variable you need to store
# also, not storing it means you can mix files more easily
# (could also be a potential stumbling block though, depending on how the symbols are resolved)

queries = [
	x(ClassName,entity),
	y(),
	z()
]


# all three are lists loaded from files
# which are stored in memory as arrays




# when you deal with serialization on constraints or queries,
# you need to match the associated Entity with that data
	# note that Queries are bound to one Entity
	# while Constraints can be bound to many Entity objects

# if you sort the lines in string form,
# the ID numbers for the associated Entities should be in ascending order
# this means you can iterate through the Entities array to resolve symbols

queries = [
	ClassName,1
	ClassName,3
	ClassName,4
	ClassName,2
	ClassName,5
]


# but wait: ID => entity is not the problem
# that's easily done by indexing the array anyway


queries = [
	ClassName,<Entity:0x0001>
	ClassName,<Entity:0x0003>
	ClassName,<Entity:0x0004>
	ClassName,<Entity:0x0002>
	ClassName,<Entity:0x0005>
]