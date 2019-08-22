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
	!map::update_dispenser_in_map(Type, MyX, MyY, X, Y, Dispensers);
	.

+!map::update_dispenser_in_map(Type, MyX, MyY, X, Y, Dispensers) : .member(dispenser(Type, MyX+X, MyY+Y), Dispensers) <- true.
+!map::update_dispenser_in_map(Type, MyX, MyY, X, Y, Dispensers) 
	: map::myMap(Leader)
<-
	.send(Leader, achieve, map::add_map(Type, MyX, MyY, X, Y));
	.

@perceivegoal[atomic]
+default::goal(X,Y)
	: true
<-
	getMyPos(MyX,MyY);
	!map::get_goal(Goals);
	!map::update_goal_in_map(MyX, MyY, X, Y, Goals);
	.
	
+!map::update_goal_in_map(MyX, MyY, X, Y, Goals) : .member(goal(MyX+X, MyY+Y), Goals) <- true.
+!map::update_goal_in_map(MyX, MyY, X, Y, Goals) 
	: map::myMap(Leader)
<-
	.send(Leader, achieve, map::add_map(goal, MyX, MyY, X, Y));
	.
	
@addmap[atomic]
+!add_map(Type, MyX, MyY, X, Y)
	: .my_name(Me) & map::myMap(Me)
<-
	updateMap(Me, Type, MyX+X, MyY+Y);
	if (Type \== goal) {
		!map::get_dispensers(Dispensers);
		if (not .member(dispenser(Type,_,_),Dispensers)) {
			?identification::identified(IdList);
			for (.member(Ag,IdList)) {
				.send(Ag, achieve, stop::new_dispenser_or_merge);
			}
			!stop::new_dispenser_or_merge;
		}
	}
	.
@addmapnotme[atomic]
+!add_map(Type, MyX, MyY, X, Y)[source(Ag)]
	: true
<-
	.send(Ag, achieve, exploration::try_again(Type, X, Y));
	.

@trygoal[atomic]
+!try_again(goal, X, Y)
	: true
<-
	getMyPos(MyX,MyY);
	!map::get_goal(Goals);
	!map::update_goal_in_map(MyX, MyY, X, Y, Goals);
	.
@trydispenser[atomic]
+!try_again(Type, X, Y)
	: true
<-
	getMyPos(MyX,MyY);
	!map::get_dispensers(Dispensers);
	!map::update_dispenser_in_map(Type, MyX, MyY, X, Y, Dispensers);
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
	