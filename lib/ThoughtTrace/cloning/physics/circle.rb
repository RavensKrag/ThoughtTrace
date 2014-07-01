module CP
	module Shape

	
class Circle
	def clone
		body = self.body
		r = self.r
		offset = self.offset
		
		other = self.class.new(body, r, offset)
		
		
		# [
		# 	:radius,            :set_radius!,
		# 	:obj,               :obj=,
		# 	:body,              :body=,
		# 	:sensor?,           :sensor=,
		# 	:collision_type,    :collision_type=
		# 	:e,                 :e=,
		# 	:u,                 :u=,
		# 	:surface_v,         :surface_v=,
		# 	:group,             :group=,
		# 	:layers,            :layers=,
		# ]
		
		
		# --- copy over other values from this object into the new copy ---
		# vectors (objects which need to be cloned)
		#   read                write
		[
			:surface_v,         :surface_v=,
		].each_slice(2) do |r, w|
			other.send r, self.send(w).clone
		end
		
		# non-vectors (literals that can be directly copied)
		#   read                write
		[
			:obj,               :obj=,
			:body,              :body=,           # if you need the deep clone, that's on you
			:sensor?,           :sensor=,
			:collision_type,    :collision_type=  # not sure if this will have side effects
			:e,                 :e=,
			:u,                 :u=,
			:group,             :group=,
			:layers,            :layers=,
		].each_slice(2) do |r, w|
			other.send r, self.send(w)
		end
		
		
		return other
	end
end



end
end