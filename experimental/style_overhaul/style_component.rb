require 'forwardable'


module Components



class Style
	def initialize
		@active_mode = :default
		
		@cascades = {
			:default => Cascade.new
		}
		@active_cascade = @cascades[@active_mode]
	end
	
	# Different style modes can be used for things like mouseover, on_click, etc
	def mode=(mode_name)
		@active_mode = mode_name
		
		# Make sure there is always a Cascade available at the mode you're switching to,
		# even if you need to create a new Cascade for the new mode.
		@cascades[@active_mode] ||= Cascade.new
		
		
		@active_cascade = @cascades[@active_mode]
	end
	
	def mode
		@active_mode
	end
	
	
	
	def primary_style
		return @active_cascade.primary
	end
	
	
	extend Forwardable
	def_delegators :@active_cascade,
		:read, :write, :socket, :each_style, :move, :move_up, :move_down
	# TODO: make sure that you always use def_delegators, and not the Object monkeypatch I wrote. That is not nearly robust enough, especially with the introduction of kwargs to ruby 2.0
end


end