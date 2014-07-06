module CP
	module Shape

	
class Poly
	def clone
		body = self.body
		
		verts = self.verts
		verts.collect!{|v| v.clone}
		 # clone just in case. Don't want to get references to original verts
		
		offset = self.offset # NOTE: Poly does not define #offset, although Circle does
		
		other = self.class.new(body, verts, offset)
		
		
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