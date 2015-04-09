class Hash
  def to_ostruct
    copy = dup
    copy.each do |key, value|
      copy[key] = value.to_ostruct if value.respond_to? :to_ostruct
    end
    return copy
  end
end
