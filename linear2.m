function Y = linear2(para,x);

%e=1:40; %dummy
%para =[1 2; 3 -4]; %dummy
y1 = para(1,1)*x + para(1,2);
y2 = para(2,1)*x + para(2,2);
for i=1:1:length(x);
if y1(i)>y2(i)
    Y(i) = y1(i);
elseif y1(i)<=y2(i)
    Y(i) = y2(i);
end
end
Y=Y';
%plot(x',Y,'o');