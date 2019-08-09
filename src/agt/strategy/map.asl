// test plan, should be removed later on
+default::step(X)
	: X \== 0 & X mod 100 = 0
<-
	!get_dispensers(DList);
	!get_goal(GList);
	!get_map_size(Size);
	.print(DList);
	.print(GList);
	.print(Size);
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
	
+!get_map_size(Size)
	: map::myMap(Me)
<-
	getMapSize(Me, Size);
	.
	