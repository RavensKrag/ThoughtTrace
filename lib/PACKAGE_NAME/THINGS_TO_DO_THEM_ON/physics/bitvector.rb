# Bitvector for usage with chipmunk layers
# should be a 32 bit bitvector
class BitVector
	FULL_OFF		= "00000000000000000000000000000000".to_i(2)
	FULL_ON			= "11111111111111111111111111111111".to_i(2)
	
	attr_reader :int
	
	def initialize
		@int = 0b00000000000000000000000000000000
		# @int = 0b11111111111111111111111111111111
	end
	
	def [](i)
		
	end
	
	def []=(i, bit)
		
	end
	
	def to_s
		
	end
	
	def to_i
		# print the binary form of the bitvector, including leading zeros
		"%.32b" % @int
	end
	
	def -(other)
		# a = @int
		# b = other.int
		 
		# return a & ~b
		
		@int &= ~other.int
	end
	
	def +(other)
		@int |= other
	end
end


# good source on bitvector manipulation
# src: http://stackoverflow.com/questions/12015598/how-to-set-unset-a-bit-at-specific-position-of-a-long-in-java


# bv = BitVector.new(32)
# # switch on one bit
# bv.set(12, true)
# bv[12].on
# bv[12] = true
# # switch on a series of bits
# bv.set((0..12), true)
# bv[(0..12)].on # returns a set of bits, and that set delegates to each bit and flips it
