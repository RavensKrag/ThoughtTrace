# add(constraint, enumerator_type, visualization_type, *entity_list)-

@collection.add Nothing, Directed, DrawEdge, entities




constraints = ThoughtTrace::Constraints::Collection.new

constraints.add(
	Nothing.new, Directed, DrawEdge,
	e1,e2
)


constraints.add(
	LimitHeight.new(->(h){ h*0.80 }), Directed, DrawEdge,
	e1,e2
)







# send-it-a-lambda style
limit = LimitHeight.new(->(h){ h*0.80 })

constraints.add(limit, Directed, DrawEdge, [e1,e2])






# block style
limit = LimitHeight.new do |h|
	h * 0.80
end

constraints.add(limit, Directed, DrawEdge, [e1,e2])









# fake functional style
# (function that returns a function)

limit = limit_height{ |h| h*0.80  }

constraints.add(limit, Directed, DrawEdge, [e1,e2])






constraints.add(limit_height{ |h| h*0.80  }, Directed, DrawEdge, [e1,e2])














# current interface
constraints.add LimitHeight.new(->(h){ h*0.80 }), Directed.new([e1,e2]), DrawEdge.new


# maybe this is better?
constraints.add LimitHeight.new(->(h){ h*0.80 }), DrawEdge.new, Directed.new([e1,e2])


# constraint these two elements
# limit the height, such that b.height <= 0.8 * a.height
# and draw a single simple edge between them




# constraint these two elements, drawing a simple edge between them.
# Limit the height, such that b.height <= 0.8 * a.height
