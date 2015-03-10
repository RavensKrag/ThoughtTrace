constraint = LimitHeight.new

constraint.closure
	.let :a => 0.8 do |vars, h|
		# 0.8*h
		vars[:a]*h
	end


@vars
@block

# save vars, but don't save the block
# that would be dumb
# because the block is already saved on the disk as text
# because that's what code is









# here's how you do it:
# GUI allows for creating a new constraint object (parameterized constraint)
# that get's slotted into the resource list, but doesn't get parameterized
# then you can take the ID from the list, and write some code to parameterize it,
	# and also to assign default values
	# but once values are set, then the system should use those, instead of the defaults


# NOTE: potentially, you could want multiple constraints with the same block, but with different vars. maybe I should allow this? wouldn't b super hard or anything






# setup
resource_list = ResourceCollection.new


# GUI initialization
id = resource_list.add LimitHeight.new



# code to declare closure, with default parameter values
constraint = resource_list[id]
constraint.closure
	.let :a => 0.8 do |vars, h|
		# 0.8*h
		vars[:a]*h
	end







# serialization
class ResourceCollection

	def dump
		data_dump = Hash.new
			resource_list.each do |id, constraint|
				# id => [constraint class, {parameter map}]
				data_dump[id] = [constraint.class, constraint.vars]
			end
		
		return data_dump
	end
	
	
	
	class << self
	
	ENUM_CLASS = 0
	ENUM_PARAMETER_MAP = 1
	
	def load(data_dump)
		obj = self.new
		
		data_dump.each do |id, data|
			# may want to make this private or something?
			# don't want to confuse people about what interface to use.
			# you always want to add new objects with #add, but the hash-style interface is needed for serialization
			constraint = data[ENUM_CLASS].new
			constraint.load_data data[ENUM_PARAMETER_MAP]
			
			obj[id] = constraint
		end
		
		return obj
	end
	
	end


end





i = 0
resource_list[i] ||= LimitHeight.new
# shouldn't have to declare here.
# but then that gets a bit weird, because the class name can not be easily listed here
# (maybe put it in the filename?)

resource_list[i].closure
	.let :a => 0.8 do |vars, h|
		# 0.8*h
		vars[:a]*h
	end