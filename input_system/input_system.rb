module TextSpace
	class InputSystem
		# TODO: Move actions outside of the input system.  They should be programatically accessible without going through the input system.
		
		attr_reader :input_manager, :mouse
		
		def initialize(space, actions)
			@inpman = DIS::InputManager.new
				left_click =	DIS::Sequence.new(:left_click).tap do |input|
									input.callbacks[:default].tap do |c|
										c.on_press do
											puts "left DOWN #{DIS.timestamp}"
										end
										
										c.on_hold do
											puts "left #{DIS.timestamp}"
										end
									end
									
									input.press_events = [
										DIS::Event.new(Gosu::MsLeft, :down)
									]
									input.release_events = [
										DIS::Event.new(Gosu::MsLeft, :up)
									]
								end
				
				middle_click =	DIS::Sequence.new(:middle_click).tap do |input|
									input.callbacks[:default].tap do |c|
										c.on_hold do
											puts "middle #{DIS.timestamp}"
										end
									end
									
									input.press_events = [
										DIS::Event.new(Gosu::MsMiddle, :down)
									]
									input.release_events = [
										DIS::Event.new(Gosu::MsMiddle, :up)
									]
								end
				
				right_click =	DIS::Sequence.new(:right_click).tap do |input|
									input.callbacks[:default].tap do |c|
										c.on_press do
											puts "right DOWN #{DIS.timestamp}"
										end
										
										c.on_hold do
											puts "right #{DIS.timestamp}"
										end
									end
									
									input.press_events = [
										DIS::Event.new(Gosu::MsRight, :down)
									]
									
									input.release_events = [
										DIS::Event.new(Gosu::MsRight, :up)
									]
								end
				
				
				
				shift =			DIS::Sequence.new(:shift).tap do |input|
									input.callbacks[:default].tap do |c|
										c.on_hold do
											puts "shift #{DIS.timestamp}"
										end
									end
									
									input.press_events = [
										DIS::Event.new(Gosu::KbLeftShift, :down)
									]
									
									input.release_events = [
										DIS::Event.new(Gosu::KbLeftShift, :up)
									]
								end
					
			
			
				shift_left_click = DIS::Accelerator.new :shift_left_click, shift, left_click
				shift_middle_click = DIS::Accelerator.new :shift_middle_click, shift, middle_click
				shift_right_click = DIS::Accelerator.new :shift_right_click, shift, right_click
			
			[
				left_click, middle_click, right_click,
				shift,
				shift_left_click, shift_middle_click, shift_right_click
			]
			.each{ |i| @inpman.add i }
			
			
			
			@mouse = TextSpace::MouseHandler.new space
			
			# this interface is much less noisy than the suggested interface from Experimental
			# but it kinda assumes that bindings are going to be declared all at one, in text
			# 
			# it might facilitate loading from JSON though
			# for the sake of file loading though, it might be better if the data was all symbols,
			# or all strings, or something of that nature
			# not sure how well classes serialize
			# (maybe YAML would work with that?)
			
			# really only need input manager while binding
			
			# NOTE: Using strings as Action IDs is problematic, because it totally ignores namespacing. Using the class objects themselves avoids this problem.
			@mouse.bind actions, @inpman, {
				# TextSpace::MoveCaretAndSelectObject	=> :left_click,
				TextSpace::MoveText					=> :right_click,
				# TextSpace::PanCamera				=> :middle_click,
				# TextSpace::SpawnNewText				=> :left_click
			}
			
		end
		
		def update
			@mouse.update
			@inpman.update
		end
		
		def shutdown
			
		end
		
		
		def button_down(id)
			case id
				when Gosu::KbEscape
					$window.close
			end
			
			@inpman.button_down id
		end
		
		def button_up(id)
			@inpman.button_up id
		end
		
		def needs_cursor?
			true
		end
	end
end