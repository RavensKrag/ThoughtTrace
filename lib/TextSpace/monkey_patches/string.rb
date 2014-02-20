class String

[:strip, :rstrip, :lstrip].each do |strip|
	define_method "multiline_#{strip}" do
		self.lines.collect{ |line| line.send strip }.join("\n")
	end
end


end