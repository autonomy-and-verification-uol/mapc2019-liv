// test plan, should be removed later on
+default::step(X)
	: X mod 100 = 0
<-
	!get_dispensers(List);
	.print(List);
	.
	
+default::thing(X, Y, dispenser, Type)
	: map::myMap(Me)
<-
	getMyPos(MyX,MyY);
	updateMap(Me, Type, MyX+X, MyY+Y);
	.

+!get_dispensers(List)
	: map::myMap(Me)
<-
	getDispensers(Me, List);
	.