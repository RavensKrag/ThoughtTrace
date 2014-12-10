# add(constraint, enumerator_type, visualization_type, *entity_list)-

constraints = ThoughtTrace::Constraints::Collection.new
constraints.add()



# @collection.add SyncHeight, All, Underline, e1, e2, e3, e4, e5



ids = [1,5]
entities = ids.collect{ |i| @entites[i] }
# @collection.add Nothing, Directed, DrawEdge, entities
@collection.add(
	ThoughtTrace::Constraints::Nothing,
	ThoughtTrace::Constraints::Enumerators::Directed,
	ThoughtTrace::Constraints::Visualizations::DrawEdge,
	entities
)



ThoughtTrace::Constraints
ThoughtTrace::Constraints::Enumerators
ThoughtTrace::Constraints::Visualizations







a = [
	ThoughtTrace::Constraints,
	ThoughtTrace::Constraints::Enumerators,
	ThoughtTrace::Constraints::Visualizations
]

b = ['Nothing', 'Directed', 'DrawEdge']

c = 
	a.zip(b).collect do |container, const_name|
		klass = container.const_get const_name
	end

@collection.add *c, entities

# remove the first bit of the namespacing off the class names when serializing
# reduces the amount of noise to a significant degree














# -- sketch ideas for scanning paths
# in final interface, I don't think you generally want to be specifying these things in code
# probably want to just pick a constraint from a list or something
# (but yeah, lists can get pretty bad, so better interface than that, but you get the point)
# (the point is that you shouldn't have to memorize a bunch of constant names, and then have to type out of the whole identifier all the time)
containers = {
	:constraints => [
		ThoughtTrace::Constraints
	],
	
	:enumerators => [
		ThoughtTrace::Constraints::Enumerators
	],
	
	:visualizations => [
		ThoughtTrace::Constraints::Visualizations
	]
}




containers[:constraints]
containers[:enumerators]
containers[:visualizations]


