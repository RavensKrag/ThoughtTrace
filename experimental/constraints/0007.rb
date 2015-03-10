
constraint
monad
visualization


monad = All.new(@entities)
monad.all_pairs
	@entities.permutation(2)





enum = @entities.permutation(2)
dirty = @entities.select{  }


# propagating constraint
enum = enum.select{ |a,b| dirty? a  }
# limiting constraint
enum = enum.select{ |a,b| dirty? b  }




# create pairs as appropriate
@entities.permutation(2)
# select only the pairs that need to be updated
.select{  |a,b|  dirty?(constraint, a,b)  }
# apply the constraint to manipulate the pairs
.each{    |a,b|  constraint.call(a,b)     }



def dirty?(constraint, a,b)
	new_value = constraint.gather_values(a,b)
	
	
	
	cached_value = dirty[entity]
	if cached_value
		# cached value found
		if cached_value == new_value
			# same value as before
			return false
		else
			# value has changed
			return true
		end
	else
		# no value in cache.
		# constraint has not been run even once yet.
		# mark as dirty so that it can run
		dirty[entity] = new_value
		return true
	end
end



class Constraint
	# collect up the values of properties that drive the constraint
	def gather_values(entity)
		self.values.collect{ |message| entity.instance_eval message  }
	end
end

class PropagatingConstraint < Constraint
	def gather_values(a,b)
		super(a)
	end
end

class LimitingConstraint < Constraint
	def gather_values(a,b)
		super(b)
	end
end



















class Constraint
	# collect up the values of properties that drive the constraint
	def gather_values(entity)
		self.values.collect{ |message| entity.instance_eval message  }
	end
end

class PropagatingConstraint < Constraint
	def gather_values(a,b)
		super(a)
	end
end

class LimitingConstraint < Constraint
	def gather_values(a,b)
		super(b)
	end
end




->(a,b){
	a[:physics].height
}




->(a,b){
	b[:physics].height
}













# update when A changes
propagating = ->(a,b){
	b[:physics].height = a[:physics].height
	
	return a[:physics].height
}

# update when B changes
limiting = ->(a,b){
	b[:physics].height = a[:physics].height
	
	return b[:physics].height
}


# list -> desired pair-wise grouping
# grouping -> reduce to only the ones that need to be updated
	# update criteria is dependent on the type of constraint