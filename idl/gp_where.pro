function gp_where,x,q

i=where(abs(double(x)-double(q)) EQ min(abs(double(x)-double(q))))
return,i
end
