#!/usr/local/bin/ruby -npKu
gsub(/\B((?![\d_])\w){2,}\B/){$&.split(//).sort_by{rand}}
