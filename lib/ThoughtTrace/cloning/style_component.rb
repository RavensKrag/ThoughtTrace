module ThoughtTrace
	module Components



class Style < Component
	# deep copy
	def clone
		obj = self.new
		
		
		each_cascade.each do |name, this_cascade| # for each mode, take the cascade and...
			obj.edit(name) do |other_cascade|     # create a duplicate cascade on the new component
				this_cascade.each_with_index do |this_style, i|
					# then, copy data between corresponding sockets
					# create style objects in order to match the structure of original cascade
					other_style = other_cascade.read_socket(i)
					unless other_style
						other_style = ThoughtTrace::Style::StyleObject.new
						other_cascade.socket(i, other_style)
					end
					
					# now just need to transfer the properties from
					# other_style to this_style
					# and the process is complete
				end
			end
		end
		
		# make sure to set the correct active mode
		obj.mode = self.mode
		
		
		return obj
	end
end


end
end