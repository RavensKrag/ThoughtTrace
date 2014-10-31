one   = StyleObject.new
two   = StyleObject.new
three = StyleObject.new



entity[:style].cascade(:other).tap do |cascade|
	cascade.socket(1, one)
	cascade.socket(2, two)
	cascade.socket(2, three)
end
