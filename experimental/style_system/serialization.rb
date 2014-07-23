# test format for style serialization
# (one style per line, lower styles have priority over higher styles, like in CSS)

# --cascade name
# style_a
# style_b
# style_c
# ---



string = "
--foo
style_a
style_b
style_c
---
--baz
style_x
style_y
style_z
---
"

((--(?<name>.*)\n)(?<vars>(.*\n)+?)(---))+
# => returns matchdata object where params can be accessed like a hash





# http://stackoverflow.com/questions/6804557/how-do-i-get-the-match-data-for-all-occurrences-of-a-ruby-regular-expression-in

"abc12def34ghijklmno567pqrs".to_enum(:scan, /\d+/).map { Regexp.last_match }




# this is some crazy functional programming wizardry
# I presume "last_match" means "the match that was found the last time you used regex to search"
# rather than "the final match out of a list of matches"

# > this seems to be correct



# thus, the final code is..




str = "
--foo
style_a
style_b
style_c
---
--baz
style_x
style_y
style_z
---
"
regexp = /
	(
		(--(?<name>.*)\n) # header
		(?<vars>(.*\n)*?) # body
		(---)             # footer
	)+
/
matches = str.to_enum(:scan, regexp).map{ Regexp.last_match }
data = matches.map{|i| [i[:name], i[:vars].split("\n")].flatten }





str =
<<-EOF
---
- - test
  - :a
  - :b
  - :c
- - foo
  - :x
  - :y
  - :z
EOF