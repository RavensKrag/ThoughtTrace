module ThoughtTrace


class GetAction
	def initialize(action_argument_map)
		@conversions = action_argument_map
	end
	
	
	# two ways of looking at types
	# 
	# type under which to look for targets (what things are of this type?)
	# type under which to look for actions (how can I interpret this target?)
	
	
	# find a target, and extract an action from it
	def foo(document, point, action_name, target_type_string, typecast_type: nil)
		# TODO: deal with spawn actions
		# should they be moved somewhere else?
		# where are they currently?
			 # ThoughtTrace -> Actions -> EmptySpace -> Actions
			# this system can not currently find them, because it expects Entity -> spawn etc
		# (also note that each spawn action currently has a different name, like "SpawnText" because they are all currently under one namespace)
		
		
		
		
		# must consider groups, queries, and individual entities
		
		# TODO: must consider groups as well.
		# Need to take into consideration the abstraction level
		# - you found a group: do you want to treat it as a group or an entity?
			# (should be able to do both)
		# - do you want to look at the group itself, or peel back the abstraction?
		
		
		
		if action_name == nil or action_name == ''
			warn "no action specified"
			return ThoughtTrace::Actions::NullAction.new
		end
		
		
		
		
		# translate type string into class object
		desired_type = parse_type_string(document, target_type_string)
		
		
		puts "action name: #{action_name}"
		# p target_type_string
		puts "target type string: #{target_type_string}"
		puts "searching for target using type class: #{desired_type.inspect}"
		
		
		# determine target object based on type
		target = determine_target(document, point, desired_type)
		puts "found target: #{target.inspect}"
		
		
		# TODO: rework this when the concept of coordinate spaces is more defined
		if target.nil? and desired_type == ThoughtTrace::Camera
			target = document.camera
		end
		
		
		if target.nil? and desired_type != :none
			# short-circuit when target == nil, but the Action requires a target
			# (if you don't need a target, nil is an acceptable value. handled in #baz)
			warn "No valid targets found"
			return ThoughtTrace::Actions::NullAction.new
		end
		
		
		
		
		
		
		# NOTE: typecast_type is not currently being set
		return baz(target, action_name, typecast_type: typecast_type)
	end
	
	
	# for a known target, find the action associated with it
	def baz(target, action_name, typecast_type: nil)
		# action = @action_factory.create(target, action_name)
		# TODO: examine action factory, and consider that part of the pathway
		
		# ===== below is code from ActionFactory#create
		
		conversions = @conversions.clone # shallow copy is what you want
		# conversions = {
		# 	:selection => @selection,
		# 	:text_input => @text_input,
			
		# 	:space => @document.space,
		# 	:clone_factory => @document.prototypes,
		# 	:styles => @document.named_styles
		# }
		
		
		# TODO: warn if any of these variables are nil
		# (or maybe only have to warn when args are nil?)
		# (maybe warn when empty, and not just nil?)
		
		
		# entity conversion must be specified here, because it is dynamic
		# (as opposed to in the initializer, which would be static)
		conversions[:entity] = target
		conversions[:group] = target if target.is_a? ThoughtTrace::Groups::Group
		# NOTE: this method of group specification should take into abstraction layering
		
		conversions[:action_factory] = self
		
		# TODO: consider always using one 'target' parameter for Actions called simply '@target'
		
		
		
		# this is the part where things start to get really weird 
		
		# REMEMBER: some of this needs to be re-packed into an ActionFactory class, so that actions can be chained, and things can be automated
		# current action factory does not have the required functionality, so it will break some things
		
		
		
		eval_type = 
			if target.nil?
				ThoughtTrace::Actions::EmptySpace
			elsif typecast_type
				puts "typcast #{target} to #{typecast_type}"
				treat_as_type(target, typecast_type)
			else
				type(target)
			end
		
		puts "searching for Action object..."
		puts "interface name: #{action_name}"
		puts "type: #{eval_type.inspect}"
		
		
		
		
		action_class = get_action(eval_type, action_name)
		# NOTE: may return ThoughtTrace::Actions::NullAction
		
		
		
		
		
		
		# may be able to keep the following code wholesale
		# not sure that any of it really needs to change
		
		
		# NOTE: remember that the action class holds both the argument list, and the obj allocator
		args   = action_class.argument_type_list.collect{|type| conversions[type] }
		action = action_class.new(*args)
		
		
		# warn about undefined actions
		# not something you want to throw an exception for
		# (some buttons just don't have things bound to them, and that's ok)
		warn "#{target.class.inspect} does not define action '#{action_name}'" if action.null_action?
		
		# NOTE: this warning is also happening deeper inside the action system somewhere
		# (specifically, under #get_action)
		
		
		
		# if no action is found, the NullAction will be returned
		# this way, the rest of the pathway will still work,
		# even though it's stubbed
		return action
	end
	
	
	
	
	
	
	
	

	
	
	
	def determine_target(document, point, desired_type)
		# determine target object based on type
		case desired_type
			when :none
				nil
			when ThoughtTrace::Camera
				document.camera
			else
				# only really need to do this when you trigger an action with an Entity target
				potental_targets = get_target_list(document.space, point)
				# TODO: make a tighter condition for when this fires, as an optimization
				
				
				# get list of potential targets
				# this list has already been sorted by some criteria,
				# so any additional manipulations on this list must not alter that
				# (currently calculating position of center, and surface area)
				
				
				# select the target based on some criteria, including the known type
				# (NOTE: need to save the target somehow for the drag transition)
				# if you need the original mouse position, it will have to be fed into this block
				
				
				
				
				
				# find a target from the list of potential targets based on class
				potental_targets.find do |x|
					if desired_type == ThoughtTrace::Queries::Query and is_query?(x)
						# looking for a query, and potential target has a query component attached to it
						true
					elsif x.is_a? desired_type
						# not looking for a query, but found an object of the right type
						true
					else
						false
					end
				end
		end
	end
	
	
	
	def get_target_list(space, point)
		layers=CP::ALL_LAYERS
		group=CP::NO_GROUP
		
		selection = space.point_query(point, layers, group, limit_to:nil, exclude:nil)		
		
		return selection if selection.empty?
		
		
		# Sort by area
		selection.sort_by! do |x|
			x[:physics].shape.area
		end
		
		# Get the smallest area values, within a certain threshold
		# Results in a certain margin of what size is acceptable,
		# relative to the smallest object
			# NOTE: This is where the number of Entities being considered can drop.
			
		first_area = selection.first[:physics].shape.area
		size_margin = 1.8 # percentage
		# TODO: Tweak margin
		
		selection = selection.select do |o|
			o[:physics].shape.area.between? first_area, first_area*(size_margin)
		end
		
		selection.sort_by! do |x|
			# Assuming that the shapes all have their center on their local origin
			# TODO: need to update this to use proper #center calculations
			distance = x[:physics].body.pos.dist point
			
			# Listed in order of precedence, but sort order needs to be reverse of that
			[x[:physics].shape.area, distance].reverse
		end
		
		
		return selection
	end
	
	
	
	
	
	
	
	
	
	private
	
	
	# return an actual type (class) or nil based on a String
	def parse_type_string(document, type_string)
		# translate type string into class object
		if type_string == 'none'
			:none
		elsif type_string == 'Camera'
			ThoughtTrace::Camera
		elsif type_string == 'Query'
			ThoughtTrace::Queries::Query
		else
			if basic_type?(type_string)
				# puts "basic type detected"
				# p BASIC_TYPE_ASSOC
				# p BASIC_TYPE_ASSOC.assoc(type_string)
				BASIC_TYPE_ASSOC.assoc(type_string).last
			elsif prefab_type?(document, type_string)
				# TODO: remember to search linked documents for prefab definition as well, once linked documents have been implemented
				raise "Using prefab types as action targets has not yet been implemented"
			else
				raise "Unexpected error"
			end
		end
	end
	
	# order in this list determines type precedence.
	# system will infer that an entity is of a higher type before a lower one
	BASIC_TYPE_ASSOC = [
		['Circle',    ThoughtTrace::Circle],
		['Text',      ThoughtTrace::Text],
		['Rectangle', ThoughtTrace::Rectangle],
		['Entity',    ThoughtTrace::Entity]
	]
	# returns true if type is among one of the core types defined by the system
	# (query is not considered a basic type, as it is a component)
	def basic_type?(entity_type_string)
		BASIC_TYPE_ASSOC.any?{  |a| a.first == entity_type_string  }
	end
	
	# returns true if the type is one defined by a prefab in the document
	def prefab_type?(document, entity_type_string)
		return false
	end
	
	# either output the specified type, or raise an exception
	def treat_as_type(obj, type)
		# see if obj can be interpreted as this other type
		if obj.is_a? type
			return type
		elsif type.is_a? ThoughtTrace::Queries::Query and is_query?(obj)
			return type
		end
		
		raise "Don't know how to treat #{obj} as an instance of type #{type}"
	end
	
	# determine type for this object, based on default assumptions
	def type(obj)
		if is_query?(obj)
			obj[:query].class
		else
			obj.class
		end
	end
	
	def is_query?(obj)
		if obj.is_a? ThoughtTrace::ComponentContainer and obj[:query]
			return true
		end
		
		return false
	end
	
	# TODO: really need to make Query into a decorator. This is ridiculous. If it was a decorator, could simply use is_a? all the time without any problems.
	# NOTE: this has the interesting side-effect that it would be possible to attach multiple query callbacks to one Entity.
	# NOTE: need to be careful when making Query a decorator. Need to be able to remove and add the Entity to the Space without losing z-index data.
	
	
	
	
	
	
	
	# determine what polymorphic version of the action to fire,
	# based only on the name of the action, and the type of the caller
	# obj           - what should be effected by the action
	# action_name   - look for this interface name
	def get_action(type, action_name)
		# entity actions
			# manipulating
			# creating new entities from prototypes
			# creating new entities from existing ones
		# group actions
		# query actions
		# constraint actions
		# camera actions
		# space actions
		action_name = action_name.to_s.constantize
		
		# some actions have no explicit target (lasso select)
		# some actions can be oddly coerced into having a target (spawn text)
		# some actions have a definite target (edit)
		# some actions have an unexpected target (creating constraints targets entities)
		
			# want to hold Actions in the class that is the target
			# but that makes creating constraints rather odd, because the spawn_constraints would be on Entity, rather than Constraint
			
			# could specify constraint creation as zero target.
			# "selection" is zero target because it creates it's own targets inside the action
			# would make sense that "constrain" is zero target, and acquires it's own targets
			# but it needs to use logic that is exactly the same as in the input manager
			# 
			# not sure where that function should ultimately be stored
		
		action = nil
		
		if type.is_a? ThoughtTrace::Queries::Query
			action = get_action_query_recursion(type, action_name)
		end
		
		if action.nil?
			action = get_action_entity_recursion(type, action_name)
		end
		
		
		
		if action == ThoughtTrace::Actions::NullAction
			# by this point, the action will be set, but it may be the NullAction
			# if it's a NullAction, the system does not recognize this action name and obj pairing
			warn "#{type} does not define #{action_name || '<NIL>'}, nor does it's ancestors"
		end
		
		return action
	end
	
	# recurse on main Entity chain
	def get_action_entity_recursion(type, action_name)
		begin
			return type::Actions.const_get action_name
		rescue NameError => e
			if type == ThoughtTrace::Entity
				# BASE CASE
				# everything is eventually an Entity
				# (wait, what about Query?)
				return ThoughtTrace::Actions::NullAction
			# elsif type == Selection
			# 	# currently, selection is not a group, it HAS a group
			# 	# this allows it to add and remove the Group from the Space as needed
			# 	# but you can't easily grab the group and know if it is the selection?
			# 	# I guess you can just compare the two objects? (via pointer, not equivalence)
			# 	# 
			# 	# also necessary so that Selection can be bound to the ActionFactory on init
				
			else
				parent_type = type.superclass
				return get_action_entity_recursion(parent_type, action_name)
			end
		end
	end
	
	# recurse on Query
	def get_action_query_recursion(type, action_name)
		begin
			return type::Actions.const_get action_name
		rescue NameError => e
			if type == ThoughtTrace::Queries::Query
				# BASE CASE
				# if it's not found in the root Query type,
				# need to try root entity chain next
				return nil
			else
				parent_type = type.superclass
				return get_action_query_recursion(parent_type, action_name)
			end
		end
	end
end


end