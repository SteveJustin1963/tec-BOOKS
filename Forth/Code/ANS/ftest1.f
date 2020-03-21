\ test of multiline input in ftran109.f
marker -test

fvariable a  
fvariable b
fvariable c
fvariable x  
fvariable y


: test1   f" c=a + b* sqrt(c^(x+y))" ;

: test2   f" a= sqrt(x) + cosh(c^x) / sinh(b/y)"  ;

: test3
   f" a = sqrt(x) + sqrt(y) + cosh(c^x)
       + sinh(b/y)"
       
;
