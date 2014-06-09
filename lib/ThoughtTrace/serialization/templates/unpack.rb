# extract Entity class constant for a particular entity
# add a new instance method to that class


# have to do this with metaprogramming
# so that way you don't have to know class hierarchy
# of the thing you're trying to add methods to

klass = ThoughtTrace.const_get(:CLASS_NAME)
klass.instance_eval do
self.instance_eval do

	def unpack(ARGS)


BODY {
	
}.strip_blank_lines!

return OBJECT



end
end
end