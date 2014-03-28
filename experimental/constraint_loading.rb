# data format
# CSV format
# constraint name,ID#1,ID#2,...,ID#n
Constraint,1,2


# pretty solid, but maybe the constraints need other parameters?
# how should those parameters be separated from the entity list?


Constraint,1,2,,foo,baz,bar

# first element is the class name
# then, a list of the effected Entities (IDs in lieu of pointers)
# -- empty entry (evaluates to nil) --
# additional arguments


# what can you change after the constraint has been initialized?
	# can you change what things are related?
	# can you change the other parameters?
	
	# maybe you can't change anything?
	
	
# should be able to tracked Entities
	# would be silly to have to throw the whole object away when the 
	
	
	# or is it? because then you have to create a binding method which sets up the state
	# but the initialization method is supposed to set up the state of that object
	
	# but you want the other values to be the same,
	# so at the very least you need to copy them over
	
	# so maybe you should just allow rebinding?