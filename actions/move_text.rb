module TextSpace
	class MoveText < Action
		def initialize(space)
			super()
			
			@pick_callback = PickCallbacks::Space.new(space)
		end
		
		# accepts either a point in space, or an object to be moved
		
		# TODO: make sure the state does not advance when no suitable target found for action. This applies to all actions which rely on querying the space before main execution.
		# should probably return some sort of signal of completion?
		# like, returns true if transition / processing of input successful?
		
		# this instance of needing to having a query interface and a direct object interface shows
		# that perhaps there should be a new method for the query interface,
		# and #press should always be the direct object interface
		def pick(point)
			obj = @pick_callback.pick(point)
			if obj
				press obj
				return true
			else
				return false
			end
		end
		
		private
		
		def on_press(obj)
			@text = obj
			
			# select @drag_selection
			# establish basis for drag
			@move_text_basis = @mouse.position_in_world
			# store original position of text
			@original_text_position = @text.physics.body.p.clone
		end

		def on_hold
			# calculate movement delta
			delta = @mouse.position_in_world - @move_text_basis
			# displace text object by movement delta
			@text.physics.body.p = @original_text_position + delta
		end

		# def on_release
			
		# end
	end
end