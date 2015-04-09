#### My one liner (and I spend quite some time to shorten it from 76 to 70 chars, damn, but then again, I never tried to write as-short-as-possible-one-liners before)

1.upto(100){|i|a=(i%3==0?"fizz":"")+(i%5==0?"buzz":"");puts a[1]?a:i}
