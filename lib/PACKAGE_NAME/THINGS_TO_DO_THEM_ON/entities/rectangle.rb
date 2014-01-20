require 'state_machine'
require File.expand_path '../../../utilities/serialization/serializable', __FILE__

module TextSpace
	module Component
		# Rectangular physics controller with nine-slice-style editing controls
		# 
		# Origin for the physics shape lies in the upper left to simplify this interface.
		# If you need to get the center, you could use the BB center, or try to computer the shape center
		
		
		# if this is supposed to be a physics system only, then it should just have a passable draw
		# (sort of for debug purposes)
		# but at that point, it's basically a rectangle entity
		# so why shouldn't it be an entity...?
		# the only reason is so that the methods to alter the geometry are properly namespaced
		
		
		
		# should it be like Unity-ish in that all Entities have collision?
		# it could be blended into the Entity
		# or it could still a component (proper namespacing)
		# 
		# not really going to be able to build any fancy draw code on top of this level anyway
		class RectangleCollider < Physics
			def initialize(parent, body)
				# body = CP::Body.new(Float::INFINITY, Float::INFINITY)
				shape = CP::Shape::Poly.new body, new_geometry(), CP::Vec2.new(0,0)
							
				
				super(parent, body, shape)
			end
			
			def update
				
			end
			
			def draw(color, z=0)
				super(color, z)
			end
			
			
			
			
			
			# ==========================
			# ===== Position stuff =====
			# ==========================
			
			# return the vector (in world space) for the center of this rectangle
			def center
				@shape.bb.center
			end
			
			
			# ==========================
			
			
			
			
			
			# ====================================
			# ===== Base geometry generation =====
			# ====================================
			def recompute_geometry(width, height)
				# stretch the right end of the geometry to meet the required distance
				
				@width = width
				@height = height
				
				verts = [
					CP::Vec2.new(0,0),
					CP::Vec2.new(@width,0),
					CP::Vec2.new(@width,@height),
					CP::Vec2.new(0,@height)
				]
				
				
				raise "Problem with specified verts." unless CP::Shape::Poly.valid? verts
				
				
				@shape.set_verts! verts
			end
			# ====================================
			
			
			
			
			# =================================
			# ===== Size modification API =====
			# =================================
			# note that the origin of the physics object is in the top left
			# (assuming +x right, +y down)
			# which means that stretching up/left requires moving the physics object
			
			def stretch_right(stretch)
				recompute_geometry @width+stretch, @height
				
				self.displace CP::Vec2.new(stretch,0)
			end
			
			def stretch_left(stretch)
				recompute_geometry @width+stretch, @height
			end
			
			def stretch_up(stretch)
				recompute_geometry @width, @height+stretch
				
				self.displace CP::Vec2.new(0,stretch)
			end
			
			def stretch_down(stretch)
				recompute_geometry @width, @height+stretch
			end
			
			
			# TODO: see if maybe the stretch distance on diagonal should be the diagonal distance, and not the value that gets applied to both x and y
			def stretch_diagonal_up_left(stretch)
				stretch_up		stretch
				stretch_left	stretch
			end
			
			def stretch_diagonal_up_right(stretch)
				stretch_up		stretch
				stretch_right	stretch
			end
			
			def stretch_diagonal_down_left(stretch)
				stretch_down	stretch
				stretch_left	stretch
			end
			
			def stretch_diagonal_down_right(stretch)
				stretch_down	stretch
				stretch_right	stretch
			end
			
			# Stretch in all directions at once, maintaining the current center position
			# TOOD: Finish implementation of #stretch
			def stretch
				recompute_geometry @width, @height
			end
			
			# =================================
			
			
			# shift position by a certain displacement (CP::Vec2)
			def displace(d)
				@body.p += d
			end
		end
	end
end