set i Node Indexes /1*6/;
set k vehicles /1*3/;
alias(i,j,h);

variable time   Objective Function Value;

*12 Constraint
positive variable s(i,k), w(i,k), y(i,k);

*13 Constraint
binary   variable x(i,j,k) 1 if edge between i to j is active 0 otherwise;

parameters R Source Node       /1/, N Destination Node /6/;

table t(i,j) Transportation minute from node i to j

    1   2   3   4   5   6
1   0   30  55  10  10  60
2   30  0   45  20  20  60
3   55  45  0   45  45  60
4   10  30  45  0   1   60
5   10  20  45  1   0   60
6   60  60  60  60  60  0
;

parameter Q(k)
/1  50
 2  60
 3  90
/;

parameter d(i)
/1  0
 2  66
 3  74
 4  52
 5  0
 6  0
/;

scalar
*Q /76/
BIGM /1000000/
u /1.18/;

equations objective_function, same_node(i,j), source_node(i,k),destination_node(j,k), flow_constraint(j,k);
equations visit_at_least_once(i), demand(k), quantity_of_demand(i,k), TW2(i,j,k), waiting(i,k), equal_demand(i),equal_demand2(k),carry_up_to_cap(j,k);


*Objective Function 
objective_function..                           time =E= sum((i,j,k),x(i,j,k)*t(i,j))+sum((i,k),w(i,k));

*1 constraint 
destination_node(j,k)$(ord(j)=N)..               sum(i,x(i,j,k)) =E= 1;
same_node(i,j)$(ord(i)=ord(j))..               sum(k,x(i,j,k)) =e= 0;

*2 contraint
demand(k)..     sum((i)$(ord(i)<>1 and ord(i)<>N),y(i,k))=L=Q(k);

*3 contraint
source_node(i,k)$(ord(i)=1)..                    sum(j,x(i,j,k)) =E= 1;

*4 constraint
flow_constraint(j,k)$(ord(j)<>1 and ord(j)<>N).. sum(i,x(i,j,k)) =E= sum(h,x(j,h,k));

*5 constraint (visit multiple)
visit_at_least_once(i)$(ord(i)<>1 and ord(i)<>N).. sum((j,k),x(i,j,k)) =G= 1;

*6 constraint
TW2(i,j,k)$(ord(j)<>R)..    s(i,k)+w(i,k)+t(i,j)-BIGM*(1-x(i,j,k))=L= s(j,k);

*7 constraint
waiting(j,k)$(ord(j)<>R and ord(j)<>N)..  w(j,k)=E= u*y(j,k);

*8 constraint
quantity_of_demand(i,k)$ (ord(k)<>1)..     sum((j)$(ord(i)<>1 and ord(i)<>N), x(i,j,k)*d(i))=G= y(i,k); 

*9 constraint
equal_demand(i)$ (ord(i)<> 1 and ord(i)<>N) ..    sum((k), y(i,k)) =E= d(i) ; 

*10 constraint
equal_demand2(k) ..   sum((i)$(ord(i)<>1 and ord(i)<> N), y(i,k)) =L=Q(k) ;

*11 constraint
carry_up_to_cap(j,k)$(ord(j)<>R and ord(j)<>N)..  y(j,k)=L=Q(k)*sum(i,x(i,j,k));



model   routing /all/;
solve   routing using mip minimizing time;
display time.l,x.l,s.l,w.l,y.l;