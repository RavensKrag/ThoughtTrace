#!/usr/bin/env ruby
Dir.chdir File.dirname(__FILE__)

require 'rubygems'
require 'gosu'

require 'DIS'

require 'chipmunk'
require 'require_all'

require './Meta'

require_all './Chipmunk'
require_all './Gosu'

require_all './Input'
require_all './actions'

require './PaintBox'

require './Line'
require './ConnectingLine'

require './Camera'

require './Selection'

require './Font'
require './Text'

require './SelectionQueries'
require './selection/CharacterSelection'
require './Space'

require './PickCallbacks'

require 'set'

module DIS
	def self.timestamp
		Gosu::milliseconds
	end
end

class Window < Gosu::Window
	include InputManager
	
	attr_reader :camera, :mouse
	attr_reader :space
	
	def initialize
		$window = self
		
		height = 900
		width = (height.to_f*16/9).to_i
		fullscreen = false
		
		update_interval = 1/60.0 * 1000
		
		super(width, height, fullscreen, update_interval)
		self.caption = "TextSpace"
		
		
		
		@paint_box = TextSpace::PaintBox.new
		
		
		TextSpace::Text.default_font = TextSpace::Font.new "Lucida Sans Unicode"
		TextSpace::Text.paint_box = @paint_box
		
		@camera = TextSpace::Camera.new
		
		@selection = TextSpace::Selection.new
		
		
		@debug_font = Gosu::Font.new self, "Arial", 30
		
		
		# Load all the data
		filepath = File.join(File.dirname(__FILE__), "data", "save_data.yml")
		
		@space = TextSpace::Space.load filepath
		
		
		
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
		
		
		
		
		
		
		
		@character_selection = CharacterSelection.new @paint_box
		
		# TOOD: consider moving actions under an "Actions" module?
		@actions = ActionGroup.new
		@actions.add(
			TextSpace::BoxSelect.new(@space),
			TextSpace::CutText.new(@space, @actions, @character_selection),
			TextSpace::HighlightText.new(@space, @character_selection),
			TextSpace::MoveCaretAndSelectObject.new(@space),
			TextSpace::MoveText.new(@space),
			TextSpace::PanCamera.new,
			TextSpace::Resize.new(@space),
			TextSpace::SpawnNewText.new(@space)
			# TextSpace::TextBox.new(@space)
		)
		
		
		
		@mouse = MouseHandler.new @space, @selection, @paint_box
		
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
		@mouse.bind @actions, @inpman, {
			TextSpace::BoxSelect				=> :shift_left_click,
			TextSpace::CutText					=> :right_click,
			TextSpace::HighlightText			=> :shift_left_click,
			TextSpace::MoveCaretAndSelectObject	=> :left_click,
			TextSpace::MoveText					=> :right_click,
			TextSpace::PanCamera				=> :middle_click,
			TextSpace::Resize					=> :shift_right_click,
			TextSpace::SpawnNewText				=> :left_click,
			# TextSpace::TextBox					=> :left_click
		}
		
		
		
		
		
		bind_color_change_functionality()
		
		
		
		
		
		
		
		if @space.empty?
			# Create text objects for all events
			data_type = Struct.new(:callback, :text)
			
			
			labels = Hash.new
			@mouse.action_callbacks.each do |name, callback|
				next if name =~ /change_color/
				
				t = TextSpace::Text.new
				t.string = name.to_s.gsub("_", " ")
				
				
				labels[name] = data_type.new callback, t
			end
			
			
			
			labels.each do |name, data|
				@space << data.text
			end
			
			
			# Link together the text objects which are not colliding
			collision_fields = [:pick_callback, :click, :drag]
			connections = Array.new
			labels.each do |name1, data1|
				labels.each do |name2, data2|
					next if data1.callback == data2.callback
					
					
					if data1.callback.collide_with data2.callback, collision_fields
						connections << TextSpace::ConnectingLine.new(
							data1.text, data2.text,
							5, -1000, @paint_box[:connection]
						)
					end
				end
			end
			@lines = connections
		else
			filepath = File.join(File.dirname(__FILE__), "data", "connections.yml")
			
			@lines = YAML.load_file(filepath)
		end
	end
	
	def update
		@space.update
		@character_selection.update
		
		@mouse.update
		@actions.update
		@inpman.update
	end
	
	def draw
		@camera.draw do
			@lines.each do |l|
				l.draw
			end
			
			@space.draw
			
			render_draw_queue
			
			@character_selection.draw 10000
		end
	end
	
	def button_down(id)
		case id
			when Gosu::KbEscape
				close
		end
		
		@inpman.button_down id
	end
	
	def button_up(id)
		@inpman.button_up id
	end
	
	def needs_cursor?
		true
	end
	
	def shutdown
		@mouse.shutdown
		@space.gc
		
		
		# dump lines
		filepath = File.join(File.dirname(__FILE__), "data", "connections.yml")
			
		File.open(filepath, "w") do |f|
			f.puts YAML::dump(@lines)
		end
		
		
		filepath = File.join(File.dirname(__FILE__), "data", "save_data.yml")
		@space.dump filepath
	end
	
	
	
	# Queue up drawing operations to be drawn during the draw step
	def draw_in_space(*args)
		@draw_queue ||= Array.new
		
		raise "Too few arguments: require (name_of_draw_method, *draw_arguments)" if args.size < 2
		
		name = args.shift
		@draw_queue << [
			name,
			args
		]
	end
	
	def render_draw_queue
		@draw_queue ||= Array.new
		
		@draw_queue.each do |item|
			# p item
			name = item.first
			args = item.last
			
			self.send "draw_#{name}", *args
		end
		
		@draw_queue.clear
	end
	
	
	
	
	def debug_puts(*args)
		output = ""
		args.each do |x|
			output += x.to_s
		end
		
		debug_z = 10000 # something really large
		@debug_font.draw output, 0,0,debug_z, 1,1, @paint_box[:debug_font]
	end
	
	
	
	
	private
	
	def bind_color_change_functionality
		# Bind F-keys (function keys) to colors switching
		fkey_symbols = (1..8).collect{ |i| "KbF#{i}".to_sym }
		
			actions = 	fkey_symbols.collect do |keysym|
							button_id = Gosu.const_get(keysym)
							
							# Create mouse event class
							class_name = "ChangeColorToSwatch#{button_id}"
							
							new_class =		Class.new(TextSpace::Action) do
												def initialize(space, color_name)
													super()
													
													@color_name = color_name
													
													
													@pick_callback = TextSpace::PickCallbacks::Space.new(space)
												end
												
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
												
												def on_press(text)
													text.color = @color[@color_name]
												end
												
												# def on_hold
													
												# end
												
												# def on_release
													
												# end
											end
							
							# Store mouse event class reference under module with the rest of them
							# (must set constant first, to solidify anonymous class)
							TextSpace.const_set(class_name, new_class)
							
							
							color_name = button_id
							
							
							
							
							
							new_class.new(@space, color_name)
						end
			
			inputs =	fkey_symbols.collect do |keysym|
							button_id = Gosu.const_get(keysym)
							
							
							
							DIS::Sequence.new(keysym).tap do |s|
								s.press_events = [
									DIS::Event.new(button_id, :down)
								]
								
								s.release_events = [
									DIS::Event.new(button_id, :up)
								]
							end
						end
		
		# Register actions
		@actions.add *actions
		
		# Track all inputs
		inputs.each{ |i| @inpman.add i }
		
		# Bind actions to inputs
		action_names = actions.collect{ |a| a.class }
		input_names = inputs.collect{ |i| i.name }
		bindings = Hash[action_names.zip input_names]
		
		@mouse.bind @actions, @inpman, bindings
	end
end

x = Window.new
x.show
x.shutdown