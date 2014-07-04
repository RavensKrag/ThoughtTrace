module CP
	module Shape

	
class Rect
	def clone
		body = self.body
		
		width = self.width
		height = self.height
		
		offset = self.offset # NOTE: Inherited from Poly, which is not defined by default
		
		other = self.class.new(body, width, height, offset)
		
		
		
		
		# --- copy over other values from this object into the new copy ---
		# vectors (objects which need to be cloned)
		#   read                write
		[
			:surface_v,         :surface_v=
		].each_slice(2) do |r, w|
			other.send r, self.send(w).clone
		end
		
		# non-vectors (literals that can be directly copied)
		#   read                write
		[
			:obj,               :obj=,
			:body,              :body=,           # if you need the deep clone, that's on you
			:sensor?,           :sensor=,
			:collision_type,    :collision_type=,  # not sure if this will have side effects
			:e,                 :e=,
			:u,                 :u=,
			:group,             :group=,
			:layers,            :layers=
		].each_slice(2) do |r, w|
			other.send r, self.send(w)
		end
		
		
		return other
	end
end



end
end