# Given a wondrous number Integer, produce the sequence (in an Array).  A
# wondrous number is a number that eventually reaches one, if you apply the
# following rules to build a sequence from it.  If the current number in the
# sequence is even, the next number is that number divided by two.  When the
# current number is odd, multiply that number by three and add one to get the next
# number in the sequence.  Therefore, if we start with the wondrous number 15, the
# sequence is [15, 46, 23, 70, 35, 106, 53, 160, 80, 40, 20, 10, 5, 16, 8, 4, 2,
# 1].
#...+....|....+....2....+....|....+....|....+....5....+....|....+....|....+....8
q=quiz; x=[q]; until x[-1]==1 do x << ( q= q%2==0 ? q/2 : 3 * q + 1 ); end; x

