module Enumerable
	# finds a local min, based on the property derived from the given block.
	# 
	# Will look for lower and lower values, but stop when the value starts to increase.
	# Not guaranteed to find the absolutely lowest value in the collection,
	# but is still useful, and can be much faster
	# Thus, this method can be thought of as short-circuiting
	def local_min_by
		target = nil # element to be returned
		min = nil    # lowest known value of the block
		
		self.each do |i|
			foo = yield i
			
			if min == nil
				# first iteration
				# (initialization step)
				min = foo
				target = i
			else
				# try to find a better value
				if foo < min
					min = foo
					target = i
				else
					# stepped one tick beyond the local min
					# should return the value from the previous iteration
					break
				end
			end
		end
		
		
		return target
	end
end