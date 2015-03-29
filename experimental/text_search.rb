 
# find text objects with the desired string inside
def search(target_string)
	text_objects = @space.entities.select{|x| x.is_a? ThoughtTrace::Text }
	text_objects.select!{ |text|  text.string.include? target_string }
	
	
	highlight_mapping = 
		text_objects.map do |text|
			i = text.string.index target_string
			
			[text, i, i+target_string.size] if i
		end
	highlight_mapping.compact!
	
	
	
	# highlight the portions of the string the match the search query
	color = Gosu::Color.argb(0x99FF0000)
	
	highlight_mapping.each do |text, start_i, end_i|
		# NOTE: width_of_first may break for i=1, because it handles conversion weird. need to totally overhaul that
		ax = text.width_of_first(start_i)
		bx = text.width_of_first(end_i)
		
		height = text[:physics].shape.height
		offset = height / 2
		
		p = text[:physics].body.p
		a = CP::Vec2.new(ax, offset) + p
		b = CP::Vec2.new(bx, offset) + p
		
		ThoughtTrace::Drawing.draw_line(
			$window, a,b, 
			color:color, thickness:height, line_offset:0.5, z_index:0
		)
	end
end



def fuzzy_search
	# do this way later
	# can't just highlight fuzzy things, you need to list possible matches
	# for that, I need to be able to generate a GUI list, and populate it
end