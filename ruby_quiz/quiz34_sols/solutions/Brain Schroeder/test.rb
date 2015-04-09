#!/usr/bin/ruby

def html_tag(*names)
  names.each do | name |
    name = name.to_s
    eval %(
    def #{name}(*attr, &block)
      raise "Expected hash or nothing" if attr.length > 1
      attributes = (attr[0] || {}).map { | k, v | %s(\#{k}="\#{v}") }.join(" ")
      if block_given?
	puts "<#{name} \#{attributes}>"
	yield
	puts "</#{name}>"
      else
	puts "<#{name} \#{attributes}/>"
      end
    end)
  end
end
html_tag :html, :head, :title, :body, :h1, :h2, :h3, :p

html do
  head do
    title do
      puts "Whiteout test case"
    end
  end
  body do
    [["It's a ruby quiz!",
    "Nice idea, James!", 
    "Keep on the good work!"],

    ["And some lorem ipsum dolor...",
    "Oh, and remember, I need a lot more lines of ruby code to show that zlib compression really has an advantage.",
    "But creating lots and lots of text is no problem."]].each do | paragraph |
      h1 do puts paragraph[0] end
      p do ||
	puts paragraph[1..-1]
      end
    end
  end
end
