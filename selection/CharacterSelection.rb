require 'set'

require 'rubygems'
require 'range_operators'

class CharacterSelection
	def initialize(paint_box)
		@color = paint_box
		
		# text object => array of text index ranges ex [(0..1), (5..10)]
		# ranges are not stored directly, but are contained inside TextSegment objects
		@seletion = Hash.new # Text => TextSegment (highlighted sub sector)
	end
	
	def update
		
	end
	
	def draw(z_index=0)
		@seletion.each do |text, segments|
			segments.each do |s|
				s.draw(z_index)
			end
		end
	end
	
	# Collection management
	def add(text, range)
		# @seletion[text] = range
		
		# TODO: convert the incoming range to array first, in attempt to reduce duplication between #add and #delete
		# x = range.to_a
		# x += #more stuff 
		
		
		# if @seletion[text]
		# 	# add range, instead of just overriding existing
		# 	x =	@seletion[text]									# either a range, or an array of ranges
		# 		.inject(Array.new){|all, i| all + i.to_a}	# expand into a single array
		# 		.send(:+, range.to_a) 						# remove the elements of the new range
		# 		.rangify									# convert back to array of ranges
		# 	@seletion[text] = x
		# else
		# 	# create new entry
		# 	@seletion[text] = range
		# end
		
		
		
		
		
		
		if @seletion[text]
			segments = @seletion[text]
			
			# add new segment
			# coalesce segments with overlapping ranges
			
			
			# each selection should contain one element,
			# as coalescing is performed all the time,
			# so no value will ever appear in more than one range
			includes_low_end = segments.select{ |s| s.range.include? range.min }.first
			includes_high_end = segments.select{ |s| s.range.include? range.max }.first
			
			
			if includes_low_end && includes_high_end
				# range already accounted for
			elsif includes_low_end
				# overlaps on low end, but not high end
				# stretch higher
				old_range = includes_low_end.range
				includes_low_end.range = ((old_range.min)..(range.max))
			elsif includes_high_end
				# overlaps on high end, but not low end
				# stretch lower
				old_range = includes_high_end.range
				includes_high_end.range = ((range.min)..(old_range.max))
			else
				# new range
				segments << TextSegment.new(@color, text, range)
			end
			
			
			@seletion[text] = segments
		else
			# create new entry
			segments = Array.new
			segments << TextSegment.new(@color, text, range)
			
			@seletion[text] = segments
		end
	end
	
	# remove single
	# can remove a whole text object at once, or just part of it
	def delete(text, range=nil)
		if range
			# x =	@seletion[text]									# either a range, or an array of ranges
			# 	.inject(Array.new){|all, i| all + i.to_a}	# expand into a single array
			# 	.send(:-, range.to_a) 						# remove the elements of the new range
			# 	.rangify									# convert back to array of ranges
			
			# if x.empty?
			# 	@seletion.delete text
			# else
			# 	@seletion[text] = x
			# end
			
			
			
			# remove selection highlight for the given range
			segments = @seletion[text]
			
			# add new segment
			# coalesce segments with overlapping ranges
			
			
			# each selection should contain one element,
			# as coalescing is performed all the time,
			# so no value will ever appear in more than one range
			includes_low_end = segments.select{ |s| s.range.include? range.min }.first
			includes_high_end = segments.select{ |s| s.range.include? range.max }.first
			
			
			if includes_low_end == includes_high_end
				# ranges matches the range being tracked by existing TextSegment
				# delete the whole segment
				segments.delete includes_low_end
			else
				# move occluded ranges out of the way
				# think of this as cutting piece of range out of the existing segments
				
				if includes_low_end
					# overlaps on low end
					# move the high end of the existing segment down and out of the way
					# (should be under the min of the input range)
					old_range = includes_low_end.range 
					includes_low_end.range = ((old_range.min)..(range.min-1))
				end
				
				if includes_high_end
					# overlaps on high end
					# move the low end of the existing segment up and out of the way
					# (should be over the max of the input range)
					old_range = includes_high_end.range 
					includes_high_end.range = ((range.max+1)..(old_range.max))
				end
			end
			
			
			# @seletion[text] = segments
		else
			# if no range specified, delete all highlights
			# for the given text object
			@seletion.delete text
		end
		
		
		
		
	end
	
	alias :remove :delete
	
	# remove all
	def clear
		@seletion.clear
	end
	
	
	def include?(text, range=nil)
		# check for partial ranges, or just whole ranges?
		return @seletion.include? text
	end
	
	# yeah, this needs a real name
	def convert_selection_to_actual_text_thing
		
	end
	
	# Bounding box around all currently active character selections
	def bb
		# find largest bounding box extents,
		# and then create BB based on that
		inf = Float::INFINITY
		l,b,r,t = [inf,inf,-inf,-inf]
		
		@seletion.each do |text, range_group|
			# find the BB around the specific sub-segment of text
			# compare that with the current bounds
		end
		
		return CP::BB.new(l,b,r,t)
	end
	
	
	private
	
	
	# part of a text object
	# should have a similar interface as Text
	# no need to draw the text portion again, only track the highlight
	class TextSegment
		attr_reader :text, :range
		
		def initialize(paint_box, text, range)
			@color = paint_box
			@text = text
			@range = range
			
			calculate_bb
		end
		
		def draw(z_index=0)
			@bb.draw @color[:highlight], z_index
		end
		
		
		def range=(r)
			@range = r
			calculate_bb
		end
		
		
		# Read properties from underlying text
		# useful for cut, etc
		[:font, :color, :height].each do |property|
			define_method property do
				@text.send property
			end
		end
		
		
		
		
		# def hide_bb
		# 	# @box_visible = false
		# end
		
		# def show_bb
		# 	# @box_visible = true
		# end
		
		private
		
		def calculate_bb
			start_offset = text.character_offset range.first
			end_offset = text.character_offset range.last
			
			
			height = text.height # pixels
			
			offset = text.position.clone
			offset.y += height / 2
			
			p0 = start_offset + offset
			p1 = end_offset + offset
			
			@bb = CP::BB.new(p0.x, p0.y-height/2, 
							p1.x, p1.y+height/2)
			@bb.reformat # TODO: Rename CP::BB#reformat
		end
	end
end