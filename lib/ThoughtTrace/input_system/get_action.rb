module ThoughtTrace


class GetAction
	def initialize(action_argument_map)
		@conversions = action_argument_map
	end
	
	
	# find a target, and extract an action from it
	def foo(document, point, action_name, target_type_string)
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
		
		
		
		return ThoughtTrace::Actions::NullAction.new if action_name == nil or action_name == ''
		
		
		
		
		# translate type string into class object
		desired_type = parse_type_string(document, target_type_string)
		
		
		puts "action name: #{action_name}"
		# p target_type_string
		puts "target type string: #{target_type_string}"
		puts "want to find this type class: #{desired_type.inspect}"
		
		
		# determine target object based on type
		target = determine_target(document, point, desired_type)
		
		# TODO: possible short-circuit when target == nil
		
		
		
		
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
		
		# TODO: consider always using one 'target' parameter for Actions called simply '@target'
		
		
		
		# this is the part where things start to get really weird 
		
		# REMEMBER: some of this needs to be re-packed into an ActionFactory class, so that actions can be chained, and things can be automated
		# current action factory does not have the required functionality, so it will break some things
		
		
		
		
		action_class = get_action(target, desired_type, action_name)
		# NOTE: may return ThoughtTrace::Actions::NullAction
		
		# under new system,
		# if you say "I want an Entity action"
		# that means "treat the target as an Entity, and get the action"
		# but if you say "I want a Text action" that means you specifically want the Text version of the polymorphic function
		
		# so between Text and Entity, when you say "Entity" -> Text action
		# between Group and Entity when you say "Entity" -> Entity action
		# between group and Entity when you say "Entity" -> Group action
		
		
		
		
		
		
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
	
	
	# for a known target, find the action associated with it
	def baz(target_obj, action_name, treat_as_type=nil)
		desired_type = 
			if treat_as_type
				treat_as_type
			else
				if target_obj.is_a? ThoughtTrace::ComponentContainer and target_obj[:query]
					target_obj[:query].class
				else
					target_obj.class
				end
			end
		
		
		
		puts "action name: #{action_name}"
		puts "want to find this type class: #{desired_type.inspect}"
		
		
		target = target_obj
		
		
		
		conversions = @conversions.clone # shallow copy is what you want
		# conversions = {
		# 	:selection => @selection,
		# 	:text_input => @text_input,
			
		# 	:space => @document.space,
		# 	:clone_factory => @document.prototypes,
		# 	:styles => @document.named_styles
		# }
		
		conversions[:entity] = target
		conversions[:group] = target if target.is_a? ThoughtTrace::Groups::Group
		
		
		
		
		
		
		
		action_class = get_action(target, desired_type, action_name)
		
		
		
		
		args   = action_class.argument_type_list.collect{|type| conversions[type] }
		action = action_class.new(*args)
		
		warn "#{target.class.inspect} does not define action '#{action_name}'" if action.null_action?
		
		return action
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
					if desired_type == ThoughtTrace::Queries::Query and x[:query]
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
	
	# determine what polymorphic version of the action to fire,
	# based only on the name of the action, and the type of the caller
	# obj           - what should be effected by the action
	# action_name   - look for this interface name
	# treat_as_type - treat obj as this type when dealing with polymorphism
	# 					if nil, use the class of obj
	def get_action(obj, action_name, treat_as_type=nil)
		# entity actions
			# manipulating
			# creating new entities from prototypes
			# creating new entities from existing ones
		# group actions
		# query actions
		# constraint actions
		# camera actions
		# space actions
		
		
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
		
		
		type = 
			if treat_as_type
				treat_as_type
			else
				if obj[:query]
					obj[:query].class
				else
					obj.class
				end
			end
		
		
		
		action = nil
		
		if type.is_a? ThoughtTrace::Queries::Query
			action = get_action_query_recursion(type, action_name)
		end
		
		if action.nil?
			action = get_action_entity_recursion(obj.class, action_name)
		end
		
		
		
		if action == ThoughtTrace::Actions::NullAction
			# by this point, the action will be set, but it may be the NullAction
			# if it's a NullAction, the system does not recognize this action name and obj pairing
			warn "#{obj.class} does not define #{action_name || '<NIL>'}, nor does it's ancestors"
		end
		
		return action
	end
	
	# recurse on main Entity chain
	def get_action_entity_recursion(type, action_name)
		begin
			return klass::Actions.const_get action_name
		rescue NameError => e
			if type == ThoughtTrace::Entity
				# BASE CASE
				# everything is eventually an Entity
				# (wait, what about Query?)
				return ThoughtTrace::Actions::NullAction
			elsif type == Selection
				# currently, selection is not a group, it HAS a group
				# this allows it to add and remove the Group from the Space as needed
				# but you can't easily grab the group and know if it is the selection?
				# I guess you can just compare the two objects? (via pointer, not equivalence)
				# 
				# also necessary so that Selection can be bound to the ActionFactory on init
				
			else
				parent_type = type.superclass
				return get_action_entity_recursion(parent_type, action_name)
			end
		end
	end
	
	# recurse on Query
	def get_action_query_recursion(type, action_name)
		begin
			return klass::Actions.const_get action_name
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
	
	
	
	
	
	
	
	
	
	
	
	
	
	BASE_CLASSES = [
		ThoughtTrace::Entity, ThoughtTrace::Actions::EmptySpace, ThoughtTrace::Groups::Group
	]
	# Recursively looks for an Action of a particular name.
	# Should not dig deeper than Entity, as Entity is what holds the Action structure.
	# 
	# name styled after things like "const_get" and "instance_variable_get"
	# 
	# ideally, the exception flow will percolate back "down" the inheritance chain
	# to the child class (the class that originally launched the call)
	# so that the error message on the backtrace can accurately report
	# what class was trying to access what action
	# 
	# obj    -- object trying to fire an Action
	# klass  -- current class under which we're looking for Action objects (changes with recursion)
	# name   -- name of the Action desired
	def get_action(obj, klass, name)
		# expects names as standard symbols, rather than in constant-symbol format
		# ex) expected    -  :move_over_there
		#     rather than -  :MoveOverThere
		
		# NOTE: I think this is a cleaner interface, but it requires a bunch of string manipulation. As this is something that needs to be called very often, it may become a major source of latency.
		# The weird part is really that you're using symbols in a not-very-symbol-like way
		# so the solution may actually be just to use Strings instead
		# as constant lookup can also be done using strings
		
		
		name_const = name.to_s.constantize
		# p [klass, name, name_const]
		
		begin
			return klass::Actions.const_get name_const
		rescue NameError => e
			# Traverse the hierarchy to find a class that can yield the desired Action.
			# Mostly, you will traverse the class inheritance hierarchy,
			# but there are some exceptions.
			
			if BASE_CLASSES.include? klass
				# you have reached the bottom of the chain,
				# the root of the the tree.
				# The recursion stops here
				
				# end of the road:
				# this is the base of the entire Action search system.
				# If no action has been found by this point, the action is not defined.
				warn "#{obj.class} does not define #{name || '<NIL>'}, nor does it's ancestors"
				return ThoughtTrace::Actions::NullAction
			else
				# trigger recursion to find the Action in question
				parent = get_parent(obj, klass)
				
				return get_action(obj, parent, name)
			end
		end
	end
	
	# helper method for get_action
	# ( obj and klass are the same as defined by get_action )
	def get_parent(obj, klass)
		# NOTE: the klass check prevents infinite looping.
			# first time:  obj.class != klass => triggers recursion on non-standard 'parent'
			# other times: obj.class == klass => standard superclass traversal
			# ( without check, you would always get the first case, because it's listed first )
		
		# --- try taking specially defined exceptions
		if klass == ThoughtTrace::Queries::Query and obj[:query]
			# if the base object has a Query component
			# you need to check the base object's class, as well as the core Query class
			return obj.class
		elsif klass == ThoughtTrace::Groups::Group and @selection.include? obj
			# Group doesn't define an action, then just use the Entity action instead.
			return obj.class
		# -------------------------------
		else  # but if there aren't any, just go the standard way 
			return klass.superclass
			
			# NOTE: Modules do not have a 'superclass', so if you end up calling this on a module, it will break. Currently do not have a need to do that, but it may come up in the future.
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
end


end