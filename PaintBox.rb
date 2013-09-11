# Manage different colors and pallets
module TextSpace
	class PaintBox
		def initialize
			# @colors = Hash.new # pallet => color
			
			@colors = {
				:example => {
					:color1 => Gosu::Color.argb(0xffff0000),
					:color2 => Gosu::Color.argb(0xff00ff00),
					:color3 => Gosu::Color.argb(0xff0000ff)
				},
				
				:default_pallet => {
					:default_font => Gosu::Color.argb(0xffFFFFFF),
					
					:text_caret => Gosu::Color::RED,
					
					:active => Gosu::Color.argb(0xffFF0000),
					:mouseover => Gosu::Color.argb(((0xff * 0.2).to_i << 24) | 0x0000ff),
					
					:debug_font => Gosu::Color.argb(0xffFF0000),
					:highlight => Gosu::Color.argb(0x77FFFF00),
					:box_select => Gosu::Color.argb(0x33E1DBA9),
					
					
					Gosu::KbF1 => Gosu::Color.argb(0xffFFFFFF),
					Gosu::KbF2 => Gosu::Color.argb(0xffD579E4),
					Gosu::KbF3 => Gosu::Color.argb(0xffE4DD79),
					Gosu::KbF4 => Gosu::Color.argb(0xff7997E4),
					Gosu::KbF5 => Gosu::Color.argb(0xff79E4D1),
					Gosu::KbF6 => Gosu::Color.argb(0xff446E51),
					Gosu::KbF7 => Gosu::Color.argb(0xff6E195B),
					Gosu::KbF8 => Gosu::Color.argb(0xff000000)
				}
			}
			
			@active_pallet = :default_pallet
		end
		
		# Return name given a color
		def color_name(c)
			return @colors[@active_pallet].find{ |name, color| color == c }.first
		end
		
		def [](color_name)
			raise "Color does not exist" unless @colors[@active_pallet][color_name]
			
			return @colors[@active_pallet][color_name]
		end
		
		def []=(name, color)
			@colors[@active_pallet][name] = color
		end
		
		private
		
		class Pallet
			def initialize
				
			end
		end
	end
end