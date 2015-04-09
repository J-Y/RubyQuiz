#!/usr/bin/env ruby
require 'set'
require 'optparse'

dict = nil

ARGV.options do |opts|
  opts.banner = "Usage: ruby #{__FILE__} [options] [input files]"
  opts.on('Options:')
  opts.on('--dictionary DICTFILE', '-d', 'Specify dictionary file') { |file|
    File.open(file) { |f| dict = f.readlines }
  }
  opts.on("--help", "-h", "This text") { puts opts; exit 0 }
  
  opts.parse!
end

l2n = {}
%w{ABC DEF GHI JKL MNO PQRS TUV WXYZ}.each_with_index { |letters, num|
  letters.scan(/./).each { |c|
    l2n[c] = "#{num + 2}"
  }
}

dict = %w{use ruby a quick brown fox jumped over the lazy laz laxx dog lazyfox f azyfox} unless dict

num_dict = {}
dict.each { |word|
  num_word = ''
  upword = word.chomp.upcase
  upword.scan(/./).each { |c|
    num_word << l2n[c]
  }
  (num_dict[num_word] ||= []) << upword
}

def build_word_list(position_list, phnumber, words = Set.new, word = '')
  position = word.length - word.count('-')
  if position >= position_list.size
    word.chop! while word[-1, 1] == '-'
    words << word
    return
  end
  position_list[position].each { |word_ary|
    next unless word_ary
    word_ary.each { |w|
      new_word = word.empty? ? "#{w}" : "#{word}-#{w}"
      build_word_list(position_list, phnumber, words, new_word)
      build_word_list(position_list, phnumber, words, "#{new_word}-#{phnumber[position + w.length, 1]}")
    }
  }
  words
end

while phone = gets
  next if phone.gsub!(/[^\d]/, '').empty?
  digits = phone.scan(/./)
  position_list = Array.new(digits.size)
  digits.each_with_index { |d, i|
    length_list = position_list[i] = Array.new(digits.size - i)
    num_word = ''
    (i...digits.size).each { |j|
      num_word << digits[j]
      length_list[j - i] = num_dict[num_word]
    }
  }
  
  build_word_list(position_list, phone, build_word_list(position_list, phone), phone[0,1]).each { |w|
    puts w
  }
end
