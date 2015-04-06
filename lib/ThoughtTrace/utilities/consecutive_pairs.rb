module ThoughtTrace

class << self
	# returns an iterator that gives all consecutive pairs in a loop
	# ie) treats the list as if it's a circular queue, and performs one full loop around
	# TODO: move this into a more general location
	def consecutive_pairs(list)
		enum = Enumerator.new do |y|
			list.each_cons(2) do |a,b|
				y.yield a,b
			end
			
			y.yield list.last, list.first
		end
		
		return enum
	end
end



end