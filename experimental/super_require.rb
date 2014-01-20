

require_resource_list <<-LIST_OF_RESOURCES
	./monkey_patches
	
	./THINGS_TO_DO_THEM_ON/cameras/camera
	./THINGS_TO_DO_THEM_ON/collections/group/selection
	
	./THINGS_TO_DO/actions
	./THINGS_TO_DO/input_system
	
	 './drawing
	
	./utilities/multires_caching/font # required by entities/text
	
	./space
	./THINGS_TO_DO_THEM_ON/entities
LIST_OF_RESOURCES




# -- process
# move to directory for this file
# pwd: bin
# UP
# pwd: ROOT
# cd ./lib
# pwd: ROOT/lib

Dir.chdir File.join(File.dirname(__FILE__), "../lib/PACKAGE_NAME") do
	resource_string = <<-LIST_OF_RESOURCES
		./monkey_patches
		
		./THINGS_TO_DO_THEM_ON/cameras/camera
		./THINGS_TO_DO_THEM_ON/collections/group/selection
		
		./THINGS_TO_DO/actions
		./THINGS_TO_DO/input_system
		
		 './drawing
		
		./utilities/multires_caching/font # required by entities/text
		
		./space
		./THINGS_TO_DO_THEM_ON/entities
	LIST_OF_RESOURCES
	
	resource_string.each_line do |line|
		# Remove comments
		
		# Remove trailing whitespace
		# (leading is already removed)
		line.rstrip
		# Ignore empty lines
		next if line.empty?
		
		
	end
	
	
	
	
	
	
	
	
	
	
	
	[
		'./monkey_patches',
		
		'./THINGS_TO_DO_THEM_ON/cameras/camera',
		'./THINGS_TO_DO_THEM_ON/collections/group/selection',
		
		'./THINGS_TO_DO/actions',
		'./THINGS_TO_DO/input_system',
		
		# './drawing',
		
		'./utilities/multires_caching/font', # required by entities/text
		
		'./space',
		'./THINGS_TO_DO_THEM_ON/entities'
	
	
	
	
	].each do |path|
		absolute_path = File.expand_path(path, Dir.pwd)
		
		
		# if it's a path, require_all
		# if it's a file, require
		
		
		if File.directory? absolute_path
			require_all absolute_path
		elsif File.file? absolute_path
			require absolute_path
		end
	end
end


# Make sure that the main program executes in the ROOT/bin directly,
# although files are loaded from under ROOT/lib