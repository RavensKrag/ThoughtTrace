
THRESHOLD = 10 # snap distance in world units

# attractive snapping: move the entity to the guide
def snap(entity, guide)
	p = entity[:physics].body.p.clone
	x =  guide[:physics].body.p.clone
	
	
	# TODO: snapping should probably be based on screen-space units, rather than world space
	if p.dist x < THRESHOLD
		entity[:physics].body.p = x
	end
end

# wait, this isn't enough.
# it's not enough to know when to trigger the "snap"
# you also have to be able to "let go" of the snap,
# if the cursor moves outside of the desired distance


# TODO: separate raw snap logic, from the attractive / repel when-do-I-trigger-things logic








# attractive snap :
# 	when close enough, trigger snap
# 	revert when the cursor leaves the zone

# repel snap :
# 	when overlapping, prepare the snap
# 	trigger the snap when the cursor tries to leave
# 	if the cursor gets even further though, then you need to revert



# snap constraints still operate between pairs, but the pairs are defined differently:
# the guide is always known, and "statically" defined
# the entity that gets moved is figured out "dynamically",
# being figured out by the collision handler

# (contrast this with other pairwise constraints, where you drag between two knows entities)




# so, snapping is programatically defined as a binary operation,
# but visually, it would be defined by marking a single object as a snap guide
# (topology like a single parent multi child structure, but children dynamically come and go)










# you really want to snap based on distance to any edge / surface, and not just distance to the center of the thing
# (or maybe you can have both styles? idk)
# not sure if I'll have to implement that logic, or if I can exploit some element of the existing physics system
# (will probably have to write it myself)


# potential different snap trigger types
# * snap to point
# * snap to circle (may be the same as snap to point?)
# * snap to poly
# * snap to line (may just be able to use snap to poly, and specify a quad? idk)