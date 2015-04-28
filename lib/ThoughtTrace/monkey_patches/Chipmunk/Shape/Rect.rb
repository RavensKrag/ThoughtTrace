module CP
	module Shape
		class Rect < Poly
			def initialize(body, width, height, offset=CP::Vec2.new(0,0))
				@width = width
				@height = height
				
				
				super(body, new_geometry(width, height), offset)
			end
			
			
			
		# verts named in "x+ right, y+ up" coordinate space
		[:top_left, :top_right, :bottom_right, :bottom_left].each_with_index do |corner, i|
			define_method "#{corner}_vert" do
				self.vert(i)
			end
		end
			
			
			# returns the center of this shape, in local space
			def center
				top_right_vert / 2
			end
			
			# Returns the two verts that specify an edge.
			# Edge is specified using 'resize' grab handle format.
			def edge(grab_handle)
				type, target_indidies = VEC_TO_TRANSFORM_DATA[grab_handle.to_a]
				raise "Coordinates do not specify an edge" unless type == :edge
				
				return target_indidies.collect{|i|  self.vert(i)  }
			end
			
			
			
			
			def width
				(self.top_right_vert- self.bottom_left_vert).x
			end
			
			def height
				(self.top_right_vert- self.bottom_left_vert).y
			end
			
			
			# TODO: fully depreciate this method
			# NOTE: currently very important to Text entities
			def resize!(width, height, offset=CP::Vec2.new(0,0))
				new_verts = new_geometry(width, height)
				
				self.set_verts! new_verts, offset
			end
			
			
			
			
			# vert order: bottom left, bottom right, top right, top left (Gosu render coordinate space)
			# NOTE: may want to just use neg and pos so you don't have to specify what is "UP"
			
			# all 9 slices in order:
			# top to bottom, left to right
			VEC_TO_TRANSFORM_DATA = {
				[-1.0, -1.0] => [:vert,     [3]],
				[ 0.0, -1.0] => [:edge,     [2,3]],
				[ 1.0, -1.0] => [:vert,     [2]],
				[-1.0,  0.0] => [:edge,     [3,0]],
				[ 0.0,  0.0] => [:center,   [0,1,2,3]],
				[ 1.0,  0.0] => [:edge,     [1,2]],
				[-1.0,  1.0] => [:vert,     [0]],
				[ 0.0,  1.0] => [:edge,     [0,1]],
				[ 1.0,  1.0] => [:vert,     [1]]
			}
			# NOTE: list numbers as floats, not ints, because that's how CP::Vec2 data is stored.
			
			# NOTE: little bit of jitter on counter-steering
			
			
			# Transform the rectangle based on a transformation delta
			def resize_by_delta!(grab_handle, delta, minimum_dimension)
				type, target_indidies = VEC_TO_TRANSFORM_DATA[grab_handle.to_a]
				
				
				verts = self.verts()
				original_verts = verts.collect{ |vec|  vec.clone  }
				
				case type
					when :edge
						# scale the edge along the axis shared by it's verts
						a,b = target_indidies.collect{|i| verts[i] }
						axis = ( a.x == b.x ? :x : :y )
						
						
						target_indidies.each do |i|
							eval "verts[#{i}].#{axis} += delta.#{axis}"
						end
						
					when :vert
						# move one main vert on both axis,
						# and two secondary verts one axis each, in accordance with the main one.
						i = target_indidies.first
						
						main  = verts[i]
						
						other = verts.select.with_index{ |vert, index| index != i  }
						a = other.find{ |vert|  vert.x == main.x }
						b = other.find{ |vert|  vert.y == main.y }
						
						
						
						main.x += delta.x
						main.y += delta.y
						a.x += delta.x
						b.y += delta.y
					when :center
						# do nothing
				end
				
				
				clamp_dimensions!(verts, original_verts, minimum_dimension)
				commit_verts!(verts)
			end
			
			
			# Transform the rectangle by moving a grab handle to match up with a point
			# (as best as possible while maintaining the properties of a rectangle)
			# 
			# code is pretty much identical to #resize_by_delta!()
			# except it uses '=' instead of '+=' to transform the verts
			# (and obviously it uses 'point' instead of 'delta')
			def resize_to_point!(grab_handle, point, minimum_dimension)
				type, target_indidies = VEC_TO_TRANSFORM_DATA[grab_handle.to_a]
				
				
				verts = self.verts()
				original_verts = verts.collect{ |vec|  vec.clone  }
				
				case type
					when :edge
						# scale the edge along the axis shared by it's verts
						a,b = target_indidies.collect{|i| verts[i] }
						axis = ( a.x == b.x ? :x : :y )
						
						
						target_indidies.each do |i|
							eval "verts[#{i}].#{axis} = point.#{axis}"
						end
						
					when :vert
						# move one main vert on both axis,
						# and two secondary verts one axis each, in accordance with the main one.
						i = target_indidies.first
						
						main  = verts[i]
						
						other = verts.select.with_index{ |vert, index| index != i  }
						a = other.find{ |vert|  vert.x == main.x }
						b = other.find{ |vert|  vert.y == main.y }
						
						
						
						main.x = point.x
						main.y = point.y
						a.x = point.x
						b.y = point.y
					when :center
						# do nothing
				end
				
				
				clamp_dimensions!(verts, original_verts, minimum_dimension)
				commit_verts!(verts)
			end
			
			
			
			private
			
			
			
			def transform_verts!(verts, type, target_indidies)
				case type
					when :edge
						# scale the edge along the axis shared by it's verts
						a,b = target_indidies.collect{|i| verts[i] }
						axis = ( a.x == b.x ? :x : :y )
						
						
						target_indidies.each do |i|
							eval "verts[#{i}].#{axis} += delta.#{axis}"
						end
						
					when :vert
						# move one main vert on both axis,
						# and two secondary verts one axis each, in accordance with the main one.
						i = target_indidies.first
						
						main  = verts[i]
						
						other = verts.select.with_index{ |vert, index| index != i  }
						a = other.find{ |vert|  vert.x == main.x }
						b = other.find{ |vert|  vert.y == main.y }
						
						
						
						main.x += delta.x
						main.y += delta.y
						a.x += delta.x
						b.y += delta.y
					when :center
						# do nothing
				end
			end
			
			# limit minimum size (like a clamp, but lower bound only)
			def clamp_dimensions!(verts, original_verts, minimum_dimension)
				vec = (verts[1] - verts[3])
				width  = vec.x
				height = vec.y
				
				
				verts.zip(original_verts).each do |vert, original|
					[
						[:x, width],
						[:y, height]
					].each do |axis, length|
						
						
						if vert.send(axis) != original.send(axis)
							# vert has been transformed on the given axis
							
							# if the dimension on this axis is too short...
							if length < minimum_dimension
								# counter-steer in the direction of the original vert
								direction = ( vert.send(axis) > original.send(axis) ? 1 : -1 )
								# by an amount that would make the dimension equal the minimum
								delta = minimum_dimension - length
								
								
								eval "vert.#{axis} += #{delta} * #{direction} * -1"
							end
						end
						
						
					end
				end
				
			end
			
			def commit_verts!(new_verts)
				offset = new_verts[3] * -1
				# this vert is by default (0,0) in local space,
				# so you need to restore it to it's default position as the local origin.
				# if you don't, then width / height calculations get weird
				
				self.set_verts!(new_verts, offset)
				self.body.p -= offset
			end
			
			
			
			
			
			
			
			def new_geometry(width, height)
				l = 0
				b = 0
				r = width
				t = height
				
				# cw winding
				verts = [
					CP::Vec2.new(l, t),
					CP::Vec2.new(r, t),
					CP::Vec2.new(r, b),
					CP::Vec2.new(l, b)
				]
				
				# raise "Problem with specified verts." unless CP::Shape::Poly.valid? verts
				
				return verts
			end
		end
	end
end