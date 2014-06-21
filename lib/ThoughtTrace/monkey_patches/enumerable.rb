module Enumerable
	def short_circuiting_min_by
		target = nil
		min = nil
		
		self.each do |i|
			foo = yield i
			
			if min
				if foo < min
					min = foo
					target = i
				else
					break
				end
			else
				min = foo
				target = i
			end
		end
		
		
		return target
	end
end