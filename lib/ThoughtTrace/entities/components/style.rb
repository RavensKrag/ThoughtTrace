module ThoughtTrace
	module Components



class Style < Component
	interface_name :style
	
	
	def initialize
		@active_mode = :default
		
		@cascades = {
			:default => ThoughtTrace::Style::Cascade.new
		}
	end
	
	def mirror(other)
		@active_mode = other.mode
		@cascades = other.each_cascade.to_h
	end
	
	
	
	
	# read from active cascade
	def [](property)
		return active_cascade[property]
	end
	
	# write to active cascade
	def []=(property, value)
		active_cascade[property] = value
		
		return self
	end
	
	
	
	
	
	# Different style modes can be used for things like mouseover, on_click, etc
	def mode=(cascade_name)
		@active_mode = cascade_name
		
		# Make sure there is always a Cascade available at the mode you're switching to,
		# even if you need to create a new Cascade for the new mode.
		@cascades[@active_mode] ||= ThoughtTrace::Style::Cascade.new
	end
	
	def mode
		@active_mode
	end
	
	# find out if a particular cascade exists, based on the given name
	def include_cascade?(cascade_name)
		@cascades[cascade_name].include? cascade_name
	end
	
	# retrieve cascade by name
	def cascade(cascade_name)
		# create new cascade if necessary
		@cascades[cascade_name] ||= ThoughtTrace::Style::Cascade.new
		
		return @cascades[cascade_name]
	end
	
	# retrieve the active cascade
	def active_cascade
		return @cascades[@active_mode]
	end
	
	
	# allow editing of one cascade by name
	# will not change the active mode
	def edit(cascade_name, &block)
		# self.cascade(mode).tap do |c|
		# 	block.call c
		# end
		
		self.cascade(cascade_name).tap &block
	end
	
	# delete one cascade by name
	def delete(cascade_name)
		@cascades.delete cascade_name
		
		if @active_mode == cascade_name
			self.mode = :default
		end
	end
	
	
	
	
	
	
	def each_cascade(&block)
		# iterate and return self, or return an iterator
		if block
			@cascades.each &block
			return self
		else
			return @cascades.each
		end
	end
	
	
	
	
	def inspect
		cascade_list = @cascades.collect{ |name, cascade|  name }
		
		"#<#{self.class}:#{object_space_id_string} @active_mode=#{@active_mode.inspect} @cascades=#{cascade_list.inspect}>"
	end
end


end
end