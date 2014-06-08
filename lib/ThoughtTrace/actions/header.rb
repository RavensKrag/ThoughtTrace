# similar to a C header file,
# requiring this file will require all the files necessary
# to use the new Action system.

path_to_file = File.expand_path(File.dirname(__FILE__))

Dir.chdir path_to_file do
	[
		'./entity',
		'./group',
		'./query',
		'./constraint',
		
		
		'./click_and_drag_controller',
		'./action_flow_controller'
		
	].each do |path|
		begin
			# if it's a path, require_all
			# if it's a file, require
			# ---------------------------
			if File.directory? path
				# puts "LOAD DIR: #{path}"
				require_all path
			# TODO: Figure out why File.file? doesn't work sans extensions like require
			# elsif File.file? path
			else
				# puts "LOAD FILE: #{path}"
				require path
			end
		rescue LoadError => e
			puts "LOAD ERROR: Failed to load #{path}"
			
			raise e
		end
	end
end