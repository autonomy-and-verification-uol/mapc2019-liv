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

@perceivedispenser[atomic]
+default::thing(X, Y, dispenser, Type)
	: true
<-
	getMyPos(MyX,MyY);
	!map::get_dispensers(Dispensers);
	!map::update_dispenser_in_map(Type, MyX+X, MyY+Y, Dispensers);
	.

+!map::update_dispenser_in_map(Type, GlX, GlY, Dispensers) : .member(dispenser(Type, GlX, GlY), Dispensers) <- true.
+!map::update_dispenser_in_map(Type, GlX, GlY, Dispensers) 
	: map::myMap(Leader)
<-
	.send(Leader, achieve, map::add_map(Type, GlX, GlY));
	.

@perceivegoal[atomic]
+default::goal(X,Y)
	: true
<-
	getMyPos(MyX,MyY);
	!map::get_goal(Goals);
	!map::update_goal_in_map(MyX+X, MyY+Y, Goals);
	.
	
+!map::update_goal_in_map(GlX, GlY, Goals) : .member(goal(GlX, GlY), Goals) <- true.
+!map::update_goal_in_map(GlX, GlY, Goals) 
	: map::myMap(Leader)
<-
	.send(Leader, achieve, map::add_map(goal, GlX, GlY));
	.
	
@addmap[atomic]
+!add_map(Type, GlX, GlY)
	: .my_name(Me) & map::myMap(Me)
<-
	!map::get_dispensers(Dispensers);
	updateMap(Me, Type, GlX, GlY);
	?identification::identified(IdList);
	if (Type \== goal & not .member(dispenser(Type,_,_),Dispensers)) {
		for (.member(Ag,IdList)) {
			.send(Ag, achieve, stop::new_dispenser_or_merge);
		}
		!stop::new_dispenser_or_merge;
	}
	.
@addmapnotme[atomic]
+!add_map(Type, GlX, GlY)
	: map::myMap(Leader)
<-
	.send(Leader, achieve, map::add_map(Type, GlX, GlY));
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
	