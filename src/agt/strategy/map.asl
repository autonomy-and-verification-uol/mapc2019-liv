// test plan, should be removed later on
+default::step(X)
	: X mod 100 = 0
<-
	!get_goal(List);
	.print(List);
	.
	
+default::thing(X, Y, dispenser, Type)
	: map::myMap(Me)
<-
	getMyPos(MyX,MyY);
	updateMap(Me, Type, MyX+X, MyY+Y);
	.
	
+default::goal(X,Y)
	: map::myMap(Me)
<-
	getMyPos(MyX,MyY);
	updateMap(Me, goal, MyX+X, MyY+Y);
	.

+!get_dispensers(List)
	: map::myMap(Me)
<-
	getDispensers(Me, List);
	.
	
+!get_goal(List)
	: map::myMap(Me)
<-
	getGoal(Me, List);
	.
	