#!/usr/bin/env ruby

path_to_file = File.expand_path(File.dirname(__FILE__))
Dir.chidir path_to_file

require './style'
require './cascading'








# Style object should have unique IDs
# those IDs should persists across sessions,
# they should be unique among all Style objects within the same space


# a style space holds all known Style objects
# many spaces can be initialized at one time,
# which can allow for namespacing
# (could alternatively use c-style prefix-namespacing on Style name if you would prefer)
# (though, I think it's always better to have an actual namespacing facility)

# Style objects are grouped into particular blobs.
# Blobs maintain cascade priority / searching for a particular property
# among multiple Style objects that are cascasding together to form a single, cohesive unit

