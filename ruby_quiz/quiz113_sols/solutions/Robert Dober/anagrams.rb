# Given an Array of String words, build an Array of only those words that are
# anagrams of the first word in the Array.
#...+....|....+....2....+....|....+....|....+....5....+....|....+....|....+....8
quiz.select{ |ele| ele.split("").sort == quiz.first.split("").sort }
