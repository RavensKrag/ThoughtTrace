->(){
return [
	"ad0d6e9e-5a2e-4cfb-9be6-76a764e0cbe4",

	->(constraint){
		constraint.closure # ThoughtTrace::Constraints::LimitHeight
		.let :a => 0.8 do |vars, h|
			# 0.8*h
			vars[:a]*h
		end
	}
]
}[]