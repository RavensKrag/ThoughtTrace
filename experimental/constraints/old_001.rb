c = Constraint.new

c.bind(e1, e2)



# bind to something else
c.bind(x, y)



# or, just use the init to bind

c = Constraint.new(e1,e2)
c = c.class.new(x, y)







constraint_list = [
	[constraint, e1, e2],
	[constraint, e1, e2],
	[constraint, e1, e2],
	[constraint, e1, e2]
]

constraint_list.each &:update

constraint_list.each &:draw


# pairwise constraints don't seem to require state
# but non-pairwise constraints seem to require it