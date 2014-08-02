# Establishes a hierarchy of Styles
# 
# style properties can be queried though this object
# as if you were polling one Style
class Cascade
	def initialize
		@styles = Array.new
	end
	
	# add a new style to the cascade
	def add(style)
		@styles << style
	end
	
	# search cascade order for a particular property
	def [](property)
		# find the first style object in the cascade order which has the desired property
		style = @styles.each.find{ |style| style.has_property? property }
		return style[property]
	end
end