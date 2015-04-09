def solve(start, finish)
	paths = [[start, start+2], [start, start*2]];
	paths.push([start, start/2]) if (start%2 == 0);
	allNum = paths.flatten.uniq;
	loop {
	    newP = Array.new();
	    paths.each{ |path|
	        curN = path.last;
	        unless(allNum.include?(curN+2))
	            return path.push(curN+2) if (curN+2 == finish);
	            allNum.push(curN+2);
	            newP.push(path.clone.push(curN+2));
	        end
	        unless (allNum.include?(curN*2))
	            return path.push(curN*2) if (curN*2 == finish);
	            allNum.push(curN*2);
	            newP.push(path.clone.push(curN*2));
	        end
	        if (curN%2 == 0 and not allNum.include?(curN/2))
	            return path.push(curN/2) if (curN/2 == finish);
	            allNum.push(curN/2);
	            newP.push(path.clone.push(curN/2));
	        end
	    }
	    paths = newP;
	}
end
