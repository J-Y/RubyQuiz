puts <<EOF
100 100 translate

/s 400 def
/colors [ 0.7 0.5 0.3 ] def

/phi 5 sqrt 1 sub 2 div def

/box { /i exch def
  0 0 moveto
  i 0 lineto
  i i lineto
  0 i lineto
  closepath
} def


0 1 9 { %for
    colors exch 3 mod get setgray
    s box
    gsave fill grestore
    0 setgray stroke

    0.8 0.4 0 setrgbcolor
    0 s s 270 360 arc stroke

    s s translate
    90 rotate
    phi phi scale
    currentlinewidth 1 phi div mul setlinewidth   % keep linewidth
} for

showpage
EOF
