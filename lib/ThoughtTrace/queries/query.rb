module ThoughtTrace
	module Queries


class Query
	# use bind / unbind because hijacking the destructor in Ruby is really weird
	# side effect: one query can easily be passed around between different Entity objects
			# no need to delete and re-create
	# also, this means that the initialization of Queries feels like Action / Component
	
	def initialize(space)
		@@collision_handler ||= CollisionHandler.new
		@@collision_type ||= :query
		
		
		@space = space
	end
	
	
	
	
	
	def update
		
	end
	
	def draw
		# the main Entity may already be drawn
		# this should render only the information specific to viewing the Query
		
		# or put another way, it should render for the Query view
	end
	
	
	
	
	
	attr_reader :bound_entity
	
	# connect an Entity to this query
	# TODO: figure out if binding multiple Entities to one Query is permissible or not
	# NOTE: currently, only one Entity can be bound at a time
	def bind(entity)
		# ===== start
		raise "#{self} already has one Entity bound to it." if @bound_entity
		raise_errors_if_depencies_unmet entity
		
		@bound_entity = entity
		
		
		# ===== body
		# -- physics
			# Establish collision callbacks between any Entity, and any Query
			# The collision handler is written very generally
			# Specifics are delegated to each Query object
			
			# clobbering of collision handlers is acceptable, as it's always the same handler object
			# it is a bit inefficient though
			
			# NOTE: This style allows for Entities with diverse collision_type properties. If the collision type of each Entity is always going to be the same, this step can be performed once in #initialize, rather than being performed on each bind.
			@space.add_collision_handler(
				@@collision_type,
				@bound_entity[:physics].shape.collision_type,
				
				@@collision_handler
			)
			
			@bound_entity[:physics].shape.sensor = true
		# -- style
			# TODO: find a way to revert the style that doesn't clash with things like mouseover
			# TODO: move query style definition somewhere else. don't want it in my flow code
			@bound_entity[:style].mode = :query
			@bound_entity[:style].edit(:query) do |s|
				s[:color] = Gosu::Color.argb(0xaaFF0000)
			end
		
		
		
		
		
		# ===== cleanup
		
		return self
	end
	
	# Remove the linkage between the Query an it's Entity
	# NOTE: if multiple Entities can be bound to one Query, you should only unbind one. In that case, you would need to specify which Entity you want unbound.
		# I suppose you could take zero args to unbind all?
		# but unbind all is a rather different sort of procedure, so it should be it's own thing
	def unbind
		# ===== start
		
		
		
		# ===== body
		# -- physics
			# TODO: consider restoring the shape's previous sensor status instead of forcing false
			@bound_entity[:physics].shape.sensor = false
		# -- style
			@bound_entity[:style].mode = :default
		
		
		# ===== cleanup
		@bound_entity = nil
		
		return self
	end
	
	
	
	
	
	
	# ===== serialization =====
	# convert ONE object to / from array on pack / unpack
	def pack(entity_to_id_table)
		puts "packing query"
		entity_id = entity_to_id_table[@bound_entity]
		
		
		return [entity_id]
	end
	
	
	class << self
		def unpack(id_to_entity_table, space, # provided by system
			id # loaded from file
		)
		puts "unpacking query"
			# 'args' array contains only elements stored in the file on disk
			query = self.new(space)
			
			
			
			entity = id_to_entity_table[id]
			
			query.bind(entity)
			
			
			return query
		end
	end
	# =========================
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	# ===== callbacks for particular query events =====
	# called once when the Query first detects an Entity
	# --- these (unfortunately) have to be public, because they are called by the CollisionHandler
	
	def on_add(entity)
		
	end
	
	# called every tick while the Query is aware of the Entity
	def on_tick(entity)
		# maybe this should be in #update?
		# maybe #update should only be for updating the Query itself?
		
	end
	
	# called once when the Query first loses track of an Entity
	def on_remove(entity)
		
	end
	
	
	
	
	
	
	
	# add / remove things from the set of things to be queried
	class CollisionHandler
		def begin(arbiter)
			query_object, entity = parse_arbiter(arbiter)
			
			if true # some condition for collision
				query_object.on_add entity
				
				
				return true
			else 
				return false
			end
		end

		def pre_solve(arbiter)
			query_object, entity = parse_arbiter(arbiter)
			
			query_object.on_tick entity
		end

		# def post_solve(arbiter)
		# 	query_object, entity = parse_arbiter(arbiter)
			
			
		# end

		def separate(arbiter)
			query_object, entity = parse_arbiter(arbiter)
			
			query_object.on_remove entity
		end
		
		
		private
		
		
		def parse_arbiter(arbiter)
			query_object = arbiter.a.obj
			entity       = arbiter.b.obj
			
			
			return query_object, entity
		end
	end
	
	
	private
	
	# TODO: Move dependencies list to the top of the file somehow
	def raise_errors_if_depencies_unmet(entity)
		[
			:physics,
			:style
		].each do |component_name|
			unless entity[component_name]
				raise "#{entity} does not have a #{component_name.to_s.capitalize} component"
			end
		end
	end
end



end
end