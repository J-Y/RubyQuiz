class Integer;def d(v)r=0;times{r+=1+rand(v)};r;end;end;x,y=
$*;e=x.gsub('%',"100").gsub(/(^|\D|\))d/,'\\11d').gsub(/d(\d
*)/x){$1==""? ".d": ".d(#$1)"};puts ("1"..y).map{eval e}*" "
