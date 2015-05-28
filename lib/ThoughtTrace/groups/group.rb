module ThoughtTrace
	module Groups


class Group < ThoughtTrace::Rectangle
	# Groups need access to the Entity list for z-index calculation. Not sure how to get that here.
	
	def initialize
		super(10,10)
		
		@components[:style].edit(:default) do |s|
			s[:color]           = Gosu::Color.argb(0xaa00FFFF)
			s[:highlight_color] = Gosu::Color.argb(0x33FF00FF)
		end
		
		@entities = Set.new
		
		
		
		# TODO: link style object from Group style into @rect, so that the color of @rect changes according to the group style (only need this if you want to ever render the Rectangle)
		# NOTE: can't just cascade @rect style into Group style if you want the two colors to be different. The two properties would need two separate names, but both shapes want to draw based on the :color property.
		# NOTE: this means the entire Style cascading process needs to be rethought. This is most likely a problem you would run across in CSS as well, because there are no variables in vanilla CSS.
		
		
		
		
		@bb_cache = nil
		# NOTE: must use this cache variable instead of just comparing with the shape's BB, because sometimes the shape's BB and the BB of all included Entities do not match up exactly
	end
	
	
	
	
	# NOTE: draw may be called at least once before #update
	def update
		bb = @entities.collect{|x|  x[:physics].shape.bb }.reduce(&:merge)
		
		if !bb.nil? and bb != @bb_cache
			@bb_cache = bb
			
			[
				[CP::Vec2.new(-1,  0),   CP::Vec2.new(bb.l,0)],
				[CP::Vec2.new( 0, -1),   CP::Vec2.new(0,bb.b)],
				[CP::Vec2.new( 1,  0),   CP::Vec2.new(bb.r,0)],
				[CP::Vec2.new( 0,  1),   CP::Vec2.new(0,bb.t)]
			].each do |a,b|
				@components[:physics].shape.resize!(
					a, :world_space, point:b, lock_aspect:false
				)
			end
		end
	end
	
	def draw(space)
		# some groups could assign styles to their members, but I don't think it's necessary to visualize "being in a group" with the assignment of a style
		# groups probably shouldn't be visible all the time anyway
		# (allows for better use of groups as an abstraction tool)
		
		
		
		# must recompute z-index every frame,
		# because the items in the Entity list could be re-sorted at any time.
		# Can't assume that they will have the same positions as
		# when they were added to the Group
		min_z, max_z = 
			if empty?
				# Prevents crashing when the Group has 0 things inside it.
				# May want to keep it visible so you can add things into it again?
				[-1000, -1000]
			else
				z_values = @entities.collect{|e|  space.entities.index_for(e) }
				z_values.minmax
			end
		
		
		
		# === visualization for the group as a whole
		super(min_z+space.entities.offsets[:selection_group])
		
		
		# === visualization for each element in the group
		@entities.each do |e|
			e[:physics].shape.bb.draw(
				@components[:style][:highlight_color],
				max_z+space.entities.offsets[:selection_indiv]
			)
		end
		
		
		# NOTE: can't really do group visualization with stencil buffer right now because text objects are bitmap, not OpenGL real 3D things. so you can't draw them into the stencil buffer.
		
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
	
	
	
	
	
	def resize!(grab_handle, coordinate_space=nil, point:nil, delta:nil, minimum_dimension:1, lock_aspect:true, limit_by:nil)
		min = 10
		
		
		# split collection by type
		rects   = self.select{ |a,b| a.is_a? ThoughtTrace::Rectangle      }
		circles = self.select{ |a,b| a.is_a? ThoughtTrace::Circle         }
		
		# NOTE: 'lock_aspect' must be true, or else you get undefined behavior
		
		# Do you want to separate Rectangle from Text? (just share backend?)
		
		# should the sizes of the Group be constrained
		# (through rounding etc)
		# to reduce jitter?
		
		# Why is it possible to resize the Group such that the edges of some elements stick out?
		# This sorta happened with Text as well:
		# the width of the hitbox was shrinking, but the width of the text was not matching up
		
		# beware of overlapping elements.
		# the nested group handling assumes a tree-like structure,
		# where basic entity types are stored on leaf nodes only.
		# if this is not the case, then you could easily duplicate transforms.
		
		
		
		# === save values specific to this element / this level of transform
		# need these to move the sub-elements using range-remap
		original_body = @components[:physics].body.clone
		
		original_width  = @components[:physics].shape.width
		original_height = @components[:physics].shape.height
		
		# needed for restore
		original_positions = self.collect{ |e|  e[:physics].center }
		
		
		# parent save
		original_verts    = @components[:physics].shape.verts
		# original_position = @components[:physics].body.p.clone
		
		
		
		
		
		
		
		
		
		
		
		# figure out by what percent member entities could be resized,
		# without going below the minimum size
		# (this won't work for nested Groups, because the minimum size for a nested Group is variable and depends on the number and arrangement of the things inside it)
		h  = rects.collect{  |e| e[:physics].shape.height   }.min
		dh = nil
		dh = min.to_f / h if h
		
		r  = circles.collect{  |e| e[:physics].shape.radius }.min
		dr = nil
		dr = min.to_f / r if r
		
		
		# NOTE: dh and/or dr can be nil if there are no rects/circles selected
		
		min_dx = [dh, dr].compact.min # not sure if you want the big one or the small one...
		
		
		# NOTE: need to also limit the resizing of the group as a whole
		
		width  = @components[:physics].shape.width
		height = @components[:physics].shape.height
		dimension = 
			case limit_by
				when :smaller
					[width, height].min
				when :larger
					[width, height].max
				when :width
					width
				when :height
					height
			end
		
		minimum_dimension = dimension * min_dx
		
		
		
		
		
		# === resize the group's hitbox
		# (use Rectangle#resize!)
		container_memo = super(
			grab_handle, coordinate_space, point:point, delta:delta, lock_aspect:lock_aspect,
			minimum_dimension:minimum_dimension, limit_by:limit_by
		)
		# TODO: make sure coordinate spaces check out and everything
		# NOTE: Groups can only be resized with locked aspect ratio. not quite sure how that affects things
		
		
		
		
		
		
		
		
		# === resize nested elements, and save their memos so you can undo later
		delta = @components[:physics].shape.vert(1) - original_verts[1]
		dx = (delta.x.round / original_verts[1].x.to_f) + 1
		# dy = (delta.y.round / original_verts[1].y.to_f) + 1
		# NOTE: dx and dy are almost exactly the same value, as they should be.
		# NOTE: only need to compute either dx or dy
		
		# Bounding box seems to be snapping back to wrap around the entities during resize
			# I think this is because of the code in the Group#update that says Group should always be trying to limit it's size to the extent of the BB around all member Entities
		
		
		puts "==="
		puts "values:"
		puts dx
		dx = [dx, min_dx].max
		puts dx
		puts "min"
		puts min_dx
		puts "==="
		
		
		
		
		
		rect_memos = 
			rects.collect do |entity|
				# resize based on original vert * percentage change of container
				p = entity[:physics].shape.vert(1) * dx
				
				# PLAN: this would handle both Rectangle and Text objects. The method would be polymorphic, and perform necessarily Text-specific calculations.
				# NOTE: this method needs to be separate from the #resize! on shape, because that is defined in terms of general rect geometry, which doesn't know about the peculiarities of Text resizing.
				entity.resize!(
					CP::Vec2.new(1,1), :local_space, point:p, lock_aspect:lock_aspect,
					minimum_dimension:min
				)
				# NOTE: had to change Text to accept 'lock_aspect' and 'limit_by' parameters, because it has to abide by the same interface as Rectangle. Even though you CAN NOT resize text with an unlocked aspect ratio.
				
				# NOTE: currently nested Groups are triggered in this branch. no separate case.
			end
		
		circle_memos = 
			circles.each do |entity|
				# change radius based on original radius
				# (may actually have to be based on diameter? not quite sure)
				# well, you do r * 2 * delta / 2 = new radius
				# so it's exactly the same as just using the radius
				r = entity[:physics].radius
				
				# want the entity#resize! to have properties of convergent evolution, trying to become a similar as possible, but you don't need it be exactly the same, I think.
				entity.resize!(
					:local_space, radius:(r*dx), minimum_dimension:min
				)
			end
		
		undo_memos = rect_memos + circle_memos
		
		
		
		
		
		
		
		
		
		
		
		# === reposition the sub-elements
		
		# --- map original Entity positions onto new Group coordinate space
		# specify intervals for interval remapping
		x_in  = 0..original_width
		x_out = 0..@components[:physics].shape.width
		
		y_in  = 0..original_height
		y_out = 0..@components[:physics].shape.height
		
		
		# examine each Entity in the Group
		positions = 
			original_positions.collect do |p|
				# position of the Entity in the Group's coordinate space
				p = original_body.world2local(p)
				
					# remap intervals to account for resize
					p.x = ThoughtTrace.range_remap(value:p.x, input_range:x_in, output_range:x_out)
					p.y = ThoughtTrace.range_remap(value:p.y, input_range:y_in, output_range:y_out)
				
				
				# convert back to global coordinate space
				@components[:physics].body.local2world(p)
			end
		
		# apply new positions
		self.zip(positions) do |entity, p|
			center = entity[:physics].shape.center
			entity[:physics].right_hand_on_red(center, p)
		end
		
		
		
		
		
		
		
		
		
		
		undo = Proc.new do
			# undo all the sub-entity transforms
			undo_memos.each do |memo|
				memo.call
			end
			
			
			# undo transforms specific to this entity / this level
			# geometry reset same as rect resize action -> same as rect edit action
			container_memo.call
			
			
			# moving sub-entities back to original positions is special to Group
			self.zip(original_positions) do |entity, p|
				center = entity[:physics].shape.center
				entity[:physics].right_hand_on_red(center, p)
			end
		end
		
		return undo
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
