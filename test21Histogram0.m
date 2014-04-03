y = randn(1,5001);
[nelements,xcenters] = hist(y);

dydx=diff(nelements)
plot (dydx)


[heights,centers] = hist(y);
hold on
set(gca,'XTickLabel',[])
n = length(centers);
w = centers(2)-centers(1);
t = linspace(centers(1)-w/2,centers(end)+w/2,n+1);
p = fix(n/2);
fill(t([p p p+1 p+1]),[0 heights([p p]),0],'w')
plot(centers([p p]),[0 heights(p)],'r:')
h = text(centers(p)-.2,heights(p)/2,'   h');
dep = -70;tL = text(t(p),dep,'L');
tR = text(t(p+1),dep,'R');
hold off

dt = diff(t);
Fvals = cumsum([0,heights.*dt]);

F = spline(t, [0, Fvals, 0]);

DF = fnder(F);  % computes its first derivative
set(h,'String','h(i)')
set(tL,'String','t(i)')
set(tR,'String','t(i+1)')
hold on
fnplt(DF, 'r', 2)
hold off
ylims = ylim; ylim([0,ylims(2)]);