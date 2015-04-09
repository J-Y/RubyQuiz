$stringify = []

def method_missing( method, *args, &block )
  if $stringify.include? method.to_s
    method.to_s
  else
    "I don't know the word '#{method}'."
  end
end

