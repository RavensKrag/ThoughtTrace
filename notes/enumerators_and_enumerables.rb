# http://blog.arkency.com/2014/01/ruby-to-enum-for-enumerator/
	# TL;DR
	# stick this magic sauce in your #each to make it spit out an Enumerator
	return enum_for(:each) unless block_given?
	
	
	
	
	fib = Enumerator.new do |y|
	  a = b = 1
	  loop do
	    y << a
	    a, b = b, a + b
	  end
	end

	fib.take(10) # => [1, 1, 2, 3, 5, 8, 13, 21, 34, 55]


	# What do you need to remember?


	# Not much actually. Whenever your method yields values, just use #to_enum (or #enum_for as you already know there are identical) to create Enumerator based on the method itself, if block code is not provided. Sounds complicated? It is not. Have a look at the example.

	require 'digest/md5'

	class UsersWithGravatar
	  def each
	    return enum_for(:each) unless block_given? # Sparkling magic!

	    User.find_each do |user|
	      hash  = Digest::MD5.hexdigest(user.email)
	      image = "http://www.gravatar.com/avatar/#{hash}"
	      yield user unless Net::HTTP.get_response(URI.parse(image)).body == missing_avatar
	    end
	  end


	  private

	  def missing_avatar
	    @missing_avatar ||= begin
	      image_url = "http://www.gravatar.com/avatar/fake"
	      Net::HTTP.get_response(URI.parse(image_src)).body
	    end
	  end
	end




# https://practicingruby.com/articles/building-enumerable-and-enumerator
	# BAD ARTICLE
	# but notes that a lazy Enumerator could be used with the Fiber class to make cool things
	# ( would be similar to the Eventually monad from https://github.com/tomstuart/monads )
	# ( that monad is generally called the 'continuation monad' )




# http://patshaughnessy.net/2013/4/3/ruby-2-0-works-hard-so-you-can-be-lazy
	# an explination of lazy enumeration,
	# that also explains pretty well how the whole Enumerator / Enumerable system works
	
	enum = Enumerator.new do |y| # y is of type Yielder
		y.yield 1
		y.yield 2
	end
	
	# This is a pretty good style because it shows the similarity between Yielder and Proc
	


# http://blog.carbonfive.com/2012/10/02/enumerator-rubys-versatile-iterator/
	# shows off many different types of classes that return Enumerators
	
	# shows that you could just have an Enumerator that yielded a set list of static values, if you really wanted to do that
		
	enum = Enumerator.new do |yielder|
	  yielder << "a"
	  yielder << "b"
	  yielder << "c"
	end
	
	# This style feels more like C++ stream manipulation, when that's not really what's happening.




# Notice that #count is part of Enumerable,
# and tallies up the number of entries in a collection by iterating using #each.
# So it's not the exact same as Array#size / Array#length

# this is a cool thing you can do as a result:
[4, 1, 2, 0].to_enum(:count).each_with_index{|elem, index| elem == index}

# src: http://stackoverflow.com/questions/19499066/how-does-to-enummethod-receive-its-block-here
