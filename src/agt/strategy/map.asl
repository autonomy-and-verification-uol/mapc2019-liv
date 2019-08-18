// test plan, should be removed later on
+default::step(X)
	: X \== 0 & X mod 25 = 0
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
	!map::get_dispensers(Dispensers);
	!map::update_dispenser_in_map(Type, MyX+X, MyY+Y, Dispensers).

+!map::update_dispenser_in_map(Type, GlX, GlY, Dispensers) : 
	.member(dispenser(Type, GlX, GlY), Dispensers) 
<-
	true.
+!map::update_dispenser_in_map(Type, GlX, GlY, Dispensers) : 
	map::myMap(Me)
<-
	!stop::new_dispenser_trigger(Type, Dispensers);
	updateMap(Me, Type,GlX, GlY).
	
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
	