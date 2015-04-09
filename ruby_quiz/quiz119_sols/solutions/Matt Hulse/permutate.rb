module Permutate

	def Permutate.generate(n)
		permutations = Array.new
		perm = Array.new

		#first permutation
		(1..n).each{|i|
			perm << i
		}

	#	print "#{perm}\n"
		permutations << perm.to_s

		(2..(fact(n))).each do |i|
			m = n - 2

			while (perm[m] > perm[m+1])
				m = m - 1
			end
			k = n - 1

			while perm[m] > perm[k]
				k = k - 1
			end
			swap(perm,m,k)
			p = m + 1
			q = n - 1
			while p < q
				swap(perm,p,q)
				p = p + 1
				q = q - 1
			end
	#		print "#{perm}\n"
			permutations << perm.to_s
		end
		permutations
	end

	def Permutate.swap(array, a, b)
		temp = array[a]
		array[a] = array[b]
		array[b] = temp
	end

	def Permutate.fact(n)
		return 1 if n == 0
		result = 1
		(2..n).each do |i|
			result *= i
		end
		result
	end

end
