module ThoughtTrace



# TODO: figure out if there is a way the abstract types can be loaded without firing up the entire Space. This would be very useful for loading styles / prefabs from one Document in another Document
class Document
	attr_reader :camera, :space, :prototypes, :prefabs, :named_styles
	attr_accessor :project_directory
	
	def initialize
		@space = ThoughtTrace::Space.new
			# style component
			# entity
			# group
		
		
		# Raw parameterized constraints
		@constraint_objects  = ThoughtTrace::Constraints::BackendCollection.new
		
		# Constraints to be actively executed
		@constraint_packages = ThoughtTrace::Constraints::PackageCollection.new 
		
		
		@prototypes   = ThoughtTrace::CloneFactory.new    # create copies of simple entities
		@prefabs      = ThoughtTrace::PrefabFactory.new   # spawn complex entity types
		@named_styles = ThoughtTrace::StyleCollection.new # styles not bound to physical entities
		                                                  # (ex: base query style)
		
		# NOTE: prefabs and named styles might make sense to only when you're opening a saved file and have custom data, but the prototype data needs to be "seeded" with an initial configuration, otherwise you'll have initial files that aren't good for anything, because you can't ever spawn basic Entity types
		# (if you load from a system default config, that should get rid of this weird need to always start projects by cloning an old one as the base)
		# need to traverse to the root of the ThoughtTrace project, and then maybe you can use a relative path from there? can't use an absolute path, because you don't know where ThroughtTrace files will be installed
		
		# wait
		# but this gets weird
		# because the load code calls init
		# so all loads will first try to load up the default clone factory config
		# before loading the project-level config file
		# (maybe this isn't actually a big deal? maybe it doesn't add that much extra time?)
		# (this also effects the named styles collection, which has a default "Shared Query Style" definition defined in code in this file. maybe that should be moved to an external config file? sounds like it should be)
		
		
		
		
		
		
		# NOTE: the constraints factory may still have to be made, but it will need a different name, now that the @constraints variable is used to house active constraints
		
		# @constraints  = ThoughtTrace::ConstraintFactory.new
			# only need to define the constraint factory if constraints can be defined graphically
			# then the constraint factory would be like the prefab factory.
			# Not sure if you would need an equivalent of CloneFactory as well or not
			# (probably not, because constraints should always be applied to some entities on init)
		
		
		
		
		
		
		
		
		
		
		# NOTES:
		# it is possible that all basic entity types will be defined by the core library
		# this means that the clone factory should look for type definitions in the library dir
		# rather than in the project dir
		# 
		# but it might also be nice to allow for user definitions of starting values for entities
		# in which you want to maintain the current behavior, and scan project dir
		
		
		
		
		# TODO: consider expanding this to a whole list of cameras, for rendering different parts of the scene, or whatever
		
		
		
		# idea:
			# save camera centroid (ie, the point the camera is looking at )
			# when the document is bound to a window,
			# bind the active camera
			# on bind, the camera viewport size should match the size of the actual viewport
		# (like all other serialization, the camera centroid can be serialized in this class. that's actually better than doing it in the Camera class, because it requires transformation from local shape space, to global world space. Can't do that without the physics Space anyway.)
		# Only need to save the centroid. All other data is unnecessary
		# NOTE: if there are multiple camera types, the class of the camera will need to be saved
		@camera = ThoughtTrace::Camera.new
		
		
		
		
		style = ThoughtTrace::Style::StyleObject.new("Shared Query Style")
		style.tap do |s|
			s[:color] = Gosu::Color.argb(0xaa7A797A)
		end
		
		@named_styles.add style
	end
	
	# called automatically on #load,
	# but can also be called at any time to refresh closure definition
	# TODO: figure out if this method should be private or not
	def define_constraint_closures
		# load constraint code from files in a particular directory inside the project
		closure_directory = File.expand_path './closures/*.rb', @project_directory
		Dir[closure_directory].each do |filepath|
			# execute the file, and get the necessary data out
			uuid, proc = eval(File.read(filepath))
			# http://polishinggems.blogspot.com/2011/06/how-to-evaluate-ruby-script-file-from.html
			
			# pass constraint closure to the proc to be parameterized
			proc.call(@constraint_objects[uuid])
		end
	end
	
	
	
	
	def update
		@constraint_packages.update
		@space.update
	end
	
	def draw
		$window.gl 0 do
			# Set the background color to something other than pure black
			color = Gosu::Color.argb 0xff161616 # 24 bit color + alpha (8 bits per channel)
			Gl.glClearColor(*color.to_opengl) # RGBA, all GLclampf
			GL.Clear(GL::GL_COLOR_BUFFER_BIT)
		end
		$window.flush
		
		# TODO: consider passing window reference through this function, down into all other systems ( but in that case, the variable is practically global anyway so... not sure )
		@camera.draw do
			@space.draw
			$window.flush
			@constraint_packages.draw
			yield
			
			
			# text_search("constraint")
		end
	end
	
	
	def bind_to_window(window)
		@camera.bind_to_window window
	end
	
	
	def gc
		@space.gc
	end
	
	
	
	
	# find text objects with the desired string inside
	def text_search(target_string)
		text_objects = @space.entities.select{|x| x.is_a? ThoughtTrace::Text }
		
		highlight_mapping = 
			text_objects.map do |text|
				i = text.string.index target_string
				
				[text, i, i+target_string.size] if i
			end
		highlight_mapping.compact!
		
		
		
		# highlight the portions of the string the match the search query
		color = Gosu::Color.argb(0x99FF0000)
		
		highlight_mapping.each do |text, start_i, end_i|
			# NOTE: width_of_first may break for i=1, because it handles conversion weird. need to totally overhaul that
			ax = text.width_of_first(start_i)
			bx = text.width_of_first(end_i)
			
			height = text[:physics].shape.height
			offset = height / 2
			
			p = text[:physics].body.p
			a = CP::Vec2.new(ax, offset) + p
			b = CP::Vec2.new(bx, offset) + p
			
			ThoughtTrace::Drawing.draw_line(
				$window, a,b, 
				color:color, thickness:height, line_offset:0.5, z_index:0
			)
		end
	end
	
	
	
	# def draw(camera_name=nil)
		
	# 	camera =
	# 		if camera_name
	# 			@cameras[camera_name]
	# 		else
	# 			@default_camera
	# 		end
		
	# 	camera.draw do
	# 		@space.draw
	# 	end
	# end
end


end
