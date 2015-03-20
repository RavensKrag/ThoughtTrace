module ThoughtTrace
	module Groups


class Group
	# Groups need access to the Entity list for z-index calculation. Not sure how to get that here.
	
	def initialize
		@entities = Set.new
		@z = 0
		
		# @buffer = Ashton::Texture.new(1024, 1024)
		# @shader = Ashton::Shader.new
	end
	
	
	
	
	
	def update
		
	end
	
	def draw
		# TODO: consider just drawing a visual overlay to show what elements are in the group, rather than creating a group style for each group
		# could still use style objects to control the properties of this overlay, however
		
		
		# some groups could assign styles to their members, but I don't think it's necessary to visualize "being in a group" with the assignment of a style
		# groups probably shouldn't be visible all the time anyway
		# (allows for better use of groups as an abstraction tool)
		
		color = Gosu::Color.argb(0x33FF00FF)
		@entities.each do |e|
			e[:physics].shape.bb.draw color, @z
		end
		
		# $window.gl @z do
		# 	GL.Enable(GL::GL_STENCIL_TEST)
		# 	# GL.StencilMask(stencilMask)
		# 		GL.StencilMask(GL::SAMPLE_MASK)
		# 	# GL.ClearStencil(clearStencilValue)
		# 		# func = GL::GL_STENCIL_FUNC.new # nope
		# 	# GL.StencilFunc(func, ref, mask)
		# 	# GL.StencilOp(fail,zfail,zpass)
		# 	GL.Clear(GL::GL_STENCIL_BUFFER_BIT)
		# end
	end
	
	def gc?
		
	end
	
	
	
	
	
	def include?(obj)
		@entities.include? obj
	end
	
	
	
	def add(obj)
		@entities.add obj
		# @z = compute_z_index()
	end
	
	def delete(obj)
		@entities.delete obj
		# @z = compute_z_index()
	end
	
	def clear
		@entities.clear
		# @z = 0
	end
	
	
	
	def union!(other)
		@entities = @entities.union other
	end
	
	def difference!(other)
		@entities = @entities.difference other
	end
	
	def intersection!(other)
		@entities = @entities.intersection other
	end
	
	
	
	
	
	def each(&block)
		@entities.each &block
	end
	
	include Enumerable
	
	
	private
	
	def compute_z_index
		@entities.collect{|e|  @space.entities.index_for(e) }.max
	end
	
	public
	
	
	
	
	# ===== serialization =====
	# convert ONE object to / from array on pack / unpack
	def pack
		return @entities.to_a
	end
	
	
	class << self
		def unpack(*entities)
			group = self.new
			
			entities.each{ |e| group.add e  }
			
			return group
		end
	end
	# =========================
end



end
end
