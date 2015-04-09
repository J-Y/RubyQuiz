alias :old_sleep :sleep
$sleep=0

def sleep(n)
 $sleep+=n
 if $sleep>0
   old_sleep($sleep)
   $sleep=0
   true
 else
   $sleep
 end
end
