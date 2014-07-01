module CP

	
class Body
	def clone
		other = self.class.new(self.mass, self.moment)
		
		# --- copy over other values from this object into the new copy ---
		# vectors (objects which need to be cloned)
		[:p, :v, :f].each do |method|
			other.send "#{method}=", self.send(method).clone
		end
		# non-vectors (literals that can be directly copied)
		[:a, :w, :w_limit, :v_limit, :object].each do |method|
			other.send "#{method}=", self.send(method)
		end
		
		return other
	end
end



end