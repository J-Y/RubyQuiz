docs = {
  :doc1 => "The quick brown fox",
  :doc2 => "Jumped over the brown dog",
  :doc3 => "Cut him to the quick"
}

# building word list
lst = docs.map {|k,v| v.split(/[^\w']+/) }.flatten.uniq

# building index
index = docs.inject(Hash.new(0)) do |hash, (k, v)|
  lst.each { |x| hash[k] |= 2**lst.index(x) if v.index(x) }
  hash
end

# query the string
q = ARGV[0] || "Cut"

res = index.map { |k,v| k if (v & 2**lst.index(q)) > 0 }.compact
p res
