


# all constraints should have ConstraintClosures attached, even if they end up being vestigial.
# Each constraint type will decide on it's own whether to pass data through the closure,
# so constraint types that don't use it will only waste space, not time.
# This is still inefficient, but that sort of thing can be optimized out later,
# during the graph system build phase
# (that's still a long ways away from being written... but still)

# === setup
parameterized = ResourceList.new
active        = Array.new




# === generate a new constraint

constraint = LimitHeight.new



parameterized.push constraint
# TODO: maybe count the number of active slots are using this constraint object? would be useful for seeing which constraints are in demand, and which ones are currently not being used at all... etc



# active        << [constraint, Directed, DrawEdge]
package = ConstraintPackage.new(constraint, DrawEdge)
active << package



package.constraint.closure
	.let :a => 0.8 do |vars, h|
		# 0.8*h
		vars[:a]*h
	end

# NOTE: in production code, the entities will be bound in the graphical interface, not directly in this part of the code
package.bind_source_entity e1
package.bind_sink_entity   e2






# === use existing constraint

constraint = parameterized.use(i)




package = ConstraintPackage.new(constraint, DrawEdge)
active << package



package.constraint.closure
	.let :a => 0.8 do |vars, h|
		# 0.8*h
		vars[:a]*h
	end

# NOTE: in production code, the entities will be bound in the graphical interface, not directly in this part of the code
package.bind_source_entity e1
package.bind_sink_entity   e2








# === delete a constraint

package = active[i]
constraint = package.constraint

parameterized.stop(constraint)












# refresh this cached selection on occasion
# (idk if this way is any "better")

# it's important to know if you want to keep parameterized constraints
# even when they don't have any active users.
# Blender does this with materials.
# It's often useful during the process of creation, even if it's not critical to the end product.
parameterized = active.collect{|x|  x.constraint }.uniq