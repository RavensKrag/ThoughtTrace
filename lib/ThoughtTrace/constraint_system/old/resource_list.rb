# GUI will display a list of parameterized constraints,
# similar to how the Blender GUI shows a list of the currently active materials.
# This class forms the backend for that list.
class ResourceList
	# tracked object, resource count, gc when count is zero? (on close, etc)
	Data = Struct.new(:resource, :count, :removal_flag)
	
	
	def initialize
		@storage = Array.new
	end
	
	def push(resource)
		@storage << Data.new(resource, 1, true)
	end
	
	def each(&block)
		@storage.each &block
	end
	
	def find(resource)
		@storage.find{ |x| x.resource.equal? resource  }
	end
	
	# (might not need this)
	def count_for(resource)
		self.find(resource).count
	end
	
	
	
	
	
	
	
	# make it so that constraints will not be removed, even when they have 0 users
	# 
	# (Blender: F button)
	def lock(i)
		@storage[i].removal_flag = false
	end
	
	# opposite of #lock
	def unlock(i)
		@storage[i].removal_flag = true
	end
	
	# duplicate one item, and store it as a new resource
	# 
	# (Blender: + button)
	def duplicate(i)
		self.push @storage[i].resource.clone
	end
	
	# remove a particular resource from the list
	# NOTE: this should probably also purge it from the system. (remove from all objects that use this resource) Not sure how to implement that
	# not sure if this command is necessary
	# 
	# (Blender: - button)
	def delete_at(i)
		@storage.delete_at i
	end
	
	
	# provide a pointer to the resource, and increment the count
	# TODO: needs better name
	def use(i)
		data = @storage[i]
		data.count += 1
		
		return data.resource
	end
	
	# given a pointer to a resource, decrement the count because we're done with it now
	# TODO: needs better name
	def stop(resource)
		data = self.find(resource)
		data.count -= 1
		
		if data.count < 0
			raise "Freed data where you shouldn't have. Can't have negative resource count." 
		end
	end
	
	
	
	
	
	
	
	
	def gc
		@storage.reject! do |data|
			data.removal_flag and data.count == 0
		end
	end
end
