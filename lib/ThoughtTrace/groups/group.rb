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
	
	
	
	
	
	def resize!(grab_handle, coordinate_space=nil, point:nil, delta:nil, minimum_dimension:1, lock_aspect:false, limit_by:nil)
		min = 10
		
		
		# split collection by type
		rects   = self.select{ |a,b| a.is_a? ThoughtTrace::Rectangle      }
		circles = self.select{ |a,b| a.is_a? ThoughtTrace::Circle         }
		
		
		
		
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
		
		
		# === resize the group's hitbox
		# (use Rectangle#resize!)
		container_memo = super(
			grab_handle, coordinate_space, point:point, lock_aspect:true,
			minimum_dimension:minimum_dimension
		)
		# TODO: make sure coordinate spaces check out and everything
		# NOTE: Groups can only be resized with locked aspect ratio. not quite sure how that affects things
		
		
		
		
		
		
		
		
		# === resize nested elements, and save their memos so you can undo later
		# p @components[:physics].shape.verts.collect{|v| v.to_s }
		delta = @components[:physics].shape.vert(1) - original_verts[1]
		dx = (delta.x.round + original_verts[1].x.round).to_f / original_verts[1].x.round
		dy = (delta.y.round + original_verts[1].y.round).to_f / original_verts[1].y.round
			# p [dx,dy]
			# puts [dx.abs - dy.abs]
			# yes: as expected dx and dy are almost the exact same value
			# puts delta
		# TODO: should only really compute either dx or dy
		# TODO: consider using (delta / old + 1) rather than (delta + old / old) to get dx or dy
		
		# Bounding box seems to be snapping back to wrap around the entities during resize
			# I think this is because of the code in the Group#update that says Group should always be trying to limit it's size to the extent of the BB around all member Entities
		
		rect_memos = 
			rects.collect do |entity, original_verts|
				# resize based on original vert * percentage change of container
				p = entity[:physics].shape.vert(1) * dx
				
				# PLAN: this would handle both Rectangle and Text objects. The method would be polymorphic, and perform necessarily Text-specific calculations.
				# NOTE: this method needs to be separate from the #resize! on shape, because that is defined in terms of general rect geometry, which doesn't know about the peculiarities of Text resizing.
				entity.resize!(
					CP::Vec2.new(1,1), :local_space, point:p, lock_aspect:true,
					minimum_dimension:min
				)
				
				# NOTE: want to handle Groups with the same interface as Rectangles though, so do Groups really need a separate branch? Would the Groups branch just under the same polymorphic interface, but for Groups it would essentially trigger recursion?
				# NOTE: currently nested Groups are triggered in this branch. no separate case.
			end
		
		circle_memos = 
			circles.each do |entity, original_radius|
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
					p.x = range_remap(value:p.x, input_range:x_in, output_range:x_out)
					p.y = range_remap(value:p.y, input_range:y_in, output_range:y_out)
				
				
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
			
			
			# original_body
			# NOTE: I think 'original body' is actually only used to transform points into normalized local space? so you don't really need that, as much as you need to make sure that the shape just goes back to exactly the way it was before.
			
			# original_width 
			# original_height
			# NOTE: same for original width / height
			
			
			# original_positions
			
			
			
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
