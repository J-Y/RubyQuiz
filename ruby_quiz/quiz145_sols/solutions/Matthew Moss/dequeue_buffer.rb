class DequeBuffer
	def initialize(data = "", i = 0)
		@prev, @post = data[0, i].unpack("c*"), data[i..-1].unpack("c*").reverse
		@curs = 0
	end

	def insert_before(ch)
		sync
		@prev.push(ch)
	end

	def insert_after(ch)
		sync
		@post.push(ch)
	end

	def delete_before
		sync
		@prev.pop
	end

	def delete_after
		sync
		@post.pop
	end

	def left
		@curs -= 1 if @curs > -@prev.length
	end

	def right
		@curs += 1 if @curs <  @post.length
	end
	
	def up
		sync
		c = @prev.rindex(?\n)
		if c
			c -= @prev.length
			sift(c)					# move to end of prev line
			d = (@prev.rindex(?\n) || -1) - @prev.length - c
			sift(d) if d < 0		# move to column
			true
		end
	end

	def down
		sync
		c = @post.rindex(?\n)
		if c
			c -= @post.length
			sift(-c)					# move to start of next line
			d = (@post.rindex(?\n) || -1) - @post.length - c
			sift(-d) if d < 0		# move to column
			true
		end
	end

	def to_s
		(@prev + @post.reverse).pack("c*")
	end

	private

	def sift(n)
		if n < 0
			@post.concat(@prev.slice!( n, -n).reverse)
		elsif n > 0
			@prev.concat(@post.slice!(-n,  n).reverse)
		end
	end

	def sync
		sift(@curs)
		@curs = 0
	end
end
