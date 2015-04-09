#!/usr/bin/env ruby
#
#  Created by Colin A. Bartlett on 2007-06-03.
#  Copyright (c) 2007. All rights reserved.
#  Released under the terms of the MIT license.

(1..100).each do |n|
 ret = ""
 ret += "Fizz" if n.divmod(3).last == 0
 ret += "Buzz" if n.divmod(5).last == 0
 ret = n if ret == ""
 puts ret
end
