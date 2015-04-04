

Window
	def draw => {
		@document
			'from yield' => @input
	}


Documnent
	def draw => {
		@camera
			@space
			$camera.flush
			@constraint_packages
			yield => 
	}
	
	
	Space
		@space = CP::Space.new
		@groups = GroupList.new @space
		
		def draw => @groups



InputManager
	@selection

	def draw => @selection





# draw flow overview
Document
	# set background color
	Camera
		Space
		# $window.flush
		Constraints::PackageCollection
		yield => InputManager => @selection


# data overview
Window
	@input = InputManager
		@selection = Group
	@document = Document
		Space
			@space = CP::Space.new
			@groups = GroupList.new @space
				Group
	



# everything at once
Window # main
	@document = Document
		# set background color from Document
		$window.flush
		@camera = Camera
			yield => # goto: block in Document
		
		# LABEL black in Document
		@space = Space
			@space = CP::Space.new
			@groups = GroupList.new @space
				Group
		# $window.flush
		Constraints::PackageCollection
		yield => # goto: block from Main
	
	@input = InputManager # LABEL block in Main
		@actions
		@mouse_actions
		@text_input         # (caret)
		@selection = Group  # Group that controls current selection
	
# what objects require z index information from the Entity list?
Space @entities => Entity        i*ThoughtTrace::Space::EntityList::Z_PER_INDEX
Group                            min_z*ThoughtTrace::Space::EntityList::Z_PER_INDEX+ThoughtTrace::Space::EntityList::SELECTION_GROUP_OFFSET
                                 max_z*ThoughtTrace::Space::EntityList::Z_PER_INDEX+ThoughtTrace::Space::EntityList::SELECTION_INDIV_OFFSET




# where are groups? where is the selection?
# how does the current selection get turned into a permanent group?

# how do you select a group to perform actions on?
# when an object can be in multiple groups, how do you choose which one to act on?

# do you have one selection per window / per application?
# do you have one selection per document?