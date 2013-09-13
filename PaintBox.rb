# Manage different colors and palettes
module TextSpace
	class PaintBox
		def initialize
			# @colors = Hash.new # palette => color
			
			@colors = {
				:example => {
					:color1 => Gosu::Color.argb(0xffff0000),
					:color2 => Gosu::Color.argb(0xff00ff00),
					:color3 => Gosu::Color.argb(0xff0000ff)
				},
				
				:default_palette => {
					:default_font => Gosu::Color.argb(0xffFFFFFF),
					
					:text_background => Gosu::Color.argb(((0xff * 0.2).to_i << (8*3)) | 0x0000ff),
					
					:text_caret => Gosu::Color.argb(0xff8E68A4),
					
					:active => Gosu::Color.argb(0xffFF0000),
					:mouseover => Gosu::Color.argb(((0xff * 0.2).to_i << (8*3)) | 0x0000ff),
					
					:debug_font => Gosu::Color.argb(0xffFF0000),
					:highlight => Gosu::Color.argb(0x77FFFF00),
					:box_select => Gosu::Color.argb(0x33E1DBA9),
					
					:connection => Gosu::Color.argb(((0xff * 0.4).to_i << (8*3)) | 0x79E4D1),
					
					
					Gosu::KbF1 => Gosu::Color.argb(0xffFFFFFF),
					Gosu::KbF2 => Gosu::Color.argb(0xffE4DD79),
					Gosu::KbF3 => Gosu::Color.argb(0xff79E4D1),
					Gosu::KbF4 => Gosu::Color.argb(0xffD579E4),
					Gosu::KbF5 => Gosu::Color.argb(0xff7997E4),
					Gosu::KbF6 => Gosu::Color.argb(0xff446E51),
					Gosu::KbF7 => Gosu::Color.argb(0xff6E195B),
					Gosu::KbF8 => Gosu::Color.argb(0xff000000)
				}
			}
			
			@active_palette = :default_palette
		end
		
		# Return name given a color
		def color_name(c)
			return @colors[@active_palette].find{ |name, color| color == c }.first
		end
		
		def [](color_name)
			raise "Color does not exist" unless @colors[@active_palette][color_name]
			
			return @colors[@active_palette][color_name]
		end
		
		def []=(name, color)
			@colors[@active_palette][name] = color
		end
		
		private
		
		class Palette
			def initialize
				
			end
		end
	end
end