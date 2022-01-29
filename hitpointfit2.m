function  [const hitpointxy] = hitpointfit2(x,y,const0)
const = lsqcurvefit(@linear2,const0,x,y);
modely = linear2(const,x);
hitpointxy =[-const(1,1) 1;-const(2,1) 1]\[const(1,2);const(2,2)];
plot(x,y,x,modely);
