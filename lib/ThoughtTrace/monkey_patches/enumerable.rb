module Enumerable
	def short_circuiting_min_by
		target = nil
		min = nil
		
		self.each do |i|
			if min
				foo = yield i
				
				if foo < min
					min = foo
					target = i
				else
					break
				end
			else
				foo = yield i
				min = foo
				target = i
			end
		end
		
		
		return target
	end
end