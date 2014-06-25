module ThoughtTrace
	module Actions
		# module Constraint
		# 	class << self
		# 		def action_get(action_name)
					
		# 		end
		# 	end
		# end
		
		# module EmptySpace
		# 	class << self
		# 		def action_get(action_name)
					
		# 		end
		# 	end
		# end
		
		# # module Entity
		# # 	class << self
		# # 		def action_get(action_name)
					
		# # 		end
		# # 	end
		# # end
		
		
		# module Group
		# 	class << self
		# 		def action_get(action_name)
					
		# 		end
		# 	end
		# end
		
		# module Query
		# 	class << self
		# 		def action_get(action_name)
					
		# 		end
		# 	end
		# end
		
		# module Selection
		# 	class << self
		# 		def action_get(action_name)
					
		# 		end
		# 	end
		# end
		
		
		
		[:Constraint, :EmptySpace, :Group, :Query, :Selection].each do |name|
			mod = Module.new
			const_set name, mod
			
			mod.instance_eval do
				def action_get(action_symbol_name)
					action_const_name = action_symbol_name.to_s.constantize
					
					
					mod = self
					
					begin
						return mod.const_get action_const_name
					rescue NameError => e
						# No acceptable action found.
						# Return a null object so that method chaining doesn't just fail
						
						return ThoughtTrace::Actions::NullAction
					end
				end
			end
		end
	end
end