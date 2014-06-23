class String

[:strip, :rstrip, :lstrip].each do |strip|
	define_method "multiline_#{strip}" do
		self.lines.collect{ |line| line.send strip }.join("\n")
	end
end

# Convert from camel_case to ConstantCase
def constantize
	self.split('_').collect{|i| i.capitalize}.join
end


end