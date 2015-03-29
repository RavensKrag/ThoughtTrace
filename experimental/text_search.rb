 
# find text objects with the desired string inside
def search(target_string)
	text_objects = @space.entites.select{|x| x.is_a? ThoughtTrace::Text }
	text_objects.select!{ |text|  text.string.include? target_string }
	
	
	# highlight the portions of the string the match the search query
	collection = Array.new text_objects.size
	
	text_objects.each_with_index do |text, i|
		collection[i] = Highlight.new
		collection[i]
	end
end



def fuzzy_search
	# do this way later
	# can't just highlight fuzzy things, you need to list possible matches
	# for that, I need to be able to generate a GUI list, and populate it
end
