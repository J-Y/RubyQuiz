STDIN.read.gsub(/(\b[A-Za-z])([A-Za-z']*)([A-Za-z])/){[$1,$3,$2.split(//).sort_by{rand}.join].values_at(0,2,1).join}.display
