module ThoughtTrace
	module Groups


class Group < ThoughtTrace::ComponentContainer
	# Groups need access to the Entity list for z-index calculation. Not sure how to get that here.
	
	def initialize
		super()
		
		@entities = Set.new
		
		
		add_component ThoughtTrace::Components::Style.new
		@components[:style][:color]        = Gosu::Color.argb(0x33FF00FF)
		@components[:style][:hitbox_color] = Gosu::Color.argb(0x33AA00AA)
		
		
		# @rect is used to draw the extent of the group,
		# but also during various Group actions, such as 'resize'
		# (it's a rectangle, but it's basically being used as a bounding box)
		@rect = ThoughtTrace::Rectangle.new(10,10)
		@rect[:style][:color] = Gosu::Color.argb(0xaa00FFFF)
		
		@visible = false
		
		# TODO: link style object from Group style into @rect, so that the color of @rect changes according to the group style (only need this if you want to ever render the Rectangle)
	end
	
	
	
	
	# NOTE: draw may be called at least once before #update
	def update
		bb = @entities.collect{|x|  x[:physics].shape.bb }.reduce(&:merge)
		
		if bb
			@rect[:physics].shape.resize!(bb.width, bb.height)
			@rect[:physics].body.p.x = bb.l
			@rect[:physics].body.p.y = bb.b
			
			@visible = true
		else
			@visible = false
		end
	end
	
	def draw(space)
		# some groups could assign styles to their members, but I don't think it's necessary to visualize "being in a group" with the assignment of a style
		# groups probably shouldn't be visible all the time anyway
		# (allows for better use of groups as an abstraction tool)
		return unless @visible
		
		
		
		# must recompute z-index every frame,
		# because the items in the Entity list could be re-sorted at any time.
		# Can't assume that they will have the same positions as
		# when they were added to the Group
		z_values = @entities.collect{|e|  space.entities.index_for(e) }
		min_z, max_z = z_values.minmax
		
		color = @components[:style][:color]
		
		
		
		# === visualization for the group as a whole
		@rect.draw(min_z+ThoughtTrace::Space::EntityList::SELECTION_GROUP_OFFSET)
		# wait... because of draw stack flushing, you may not be able to render this at the proper level for Selection ('standard' groups may work differently, but those are not in yet)
		
		
		# === visualization for each element in the group
		@entities.each do |e|
			e[:physics].shape.bb.draw(
				color, max_z+ThoughtTrace::Space::EntityList::SELECTION_INDIV_OFFSET
			)
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
	
	
	def size
		@entities.size
	end
	
	def empty?
		@entities.empty?
	end
	
	
	
	def add(obj)
		@entities.add obj
	end
	
	def delete(obj)
		@entities.delete obj
	end
	
	def clear
		@entities.clear
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
