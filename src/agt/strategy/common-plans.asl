relative_right(n,e) :- true.
relative_right(s,w) :- true.
relative_right(e,s) :- true.
relative_right(w,n) :- true.

common::safe_origin_pos(0,-1) :- not default::thing(0,-1,Thing,_).
common::safe_origin_pos(-1,0) :- not default::thing(-1,0,Thing,_).
common::safe_origin_pos(1,0) :- not default::thing(1,0,Thing,_).
common::safe_origin_pos(0,-2) :- not default::thing(0,-2,Thing,_).
common::safe_origin_pos(-2,0) :- not default::thing(-2,0,Thing,_).
common::safe_origin_pos(2,0) :- not default::thing(2,0,Thing,_).
common::safe_origin_pos(0,0) :- true.

direction_block(n,X,Y) :- X = 0 & Y = -1.
direction_block(s,X,Y) :- X = 0 & Y = 1.
direction_block(e,X,Y) :- X = 1 & Y = 0.
direction_block(w,X,Y) :- X = -1 & Y = 0.

check_obstacle_bounds(n) :- default::obstacle(0,-2) | (default::thing(0, -2, Type, _) & Type \== dispenser & Type \== marker).
check_obstacle_bounds(s) :- default::obstacle(0,2)  | (default::thing(0, 2, Type, _) & Type \== dispenser & Type \== marker).
check_obstacle_bounds(e) :- default::obstacle(2,0)  | (default::thing(2, 0, Type, _) & Type \== dispenser & Type \== marker).
check_obstacle_bounds(w) :- default::obstacle(-2,0) | (default::thing(-2, 0, Type, _) & Type \== dispenser & Type \== marker).

rotate_direction(cw,NewX,NewY) :- retrieve::block(0,-1) & NewX = 1 & NewY = 0.
rotate_direction(cw,NewX,NewY) :- retrieve::block(0,1) & NewX = -1 & NewY = 0.
rotate_direction(cw,NewX,NewY) :- retrieve::block(1,0) & NewX = 0 & NewY = 1.
rotate_direction(cw,NewX,NewY) :- retrieve::block(-1,0) & NewX = 0 & NewY = -1.
rotate_direction(ccw,NewX,NewY) :- retrieve::block(0,-1) & NewX = -1 & NewY = 0.
rotate_direction(ccw,NewX,NewY) :- retrieve::block(0,1) & NewX = 1 & NewY = 0.
rotate_direction(ccw,NewX,NewY) :- retrieve::block(1,0) & NewX = 0 & NewY = -1.
rotate_direction(ccw,NewX,NewY) :- retrieve::block(-1,0) & NewX = 0 & NewY = 1.

find_empty_position(X,Y,Count,Vision) :- Count > Vision & false. 
find_empty_position(X,Y,1,Vision) :- (not (default::thing(-1,1,Thing,_) & Thing \== dispenser) & not default::obstacle(-1,1) & X = -1 & Y = 1) |
(not (default::thing(-1,0,Thing,_) & Thing \== dispenser) & not default::obstacle(-1,0) & X = -1 & Y = 0) |
(not (default::thing(-1,1,Thing,_) & Thing \== dispenser) & not default::obstacle(-1,1) & X = -1 & Y = 1) |
(not (default::thing(0,-1,Thing,_) & Thing \== dispenser) & not default::obstacle(0,-1) & X = 0 & Y = -1) |
(not (default::thing(0,1,Thing,_) & Thing \== dispenser) & not default::obstacle(0,1) & X = 0 & Y = 1) |
(not (default::thing(1,-1,Thing,_) & Thing \== dispenser) & not default::obstacle(1,-1) & X = 1 & Y = -1) |
(not (default::thing(1,0,Thing,_) & Thing \== dispenser) & not default::obstacle(1,0) & X = 1 & Y = 0) |
(not (default::thing(1,1,Thing,_) & Thing \== dispenser) & not default::obstacle(1,1) & X = 1 & Y = 1)
.
find_empty_position(X,Y,2,Vision) :- (not (default::thing(-2,-2,Thing,_) & Thing \== dispenser) & not default::obstacle(-2,-2) & X = -2 & Y = -2) |
(not (default::thing(-1,-2,Thing,_) & Thing \== dispenser) & not default::obstacle(-1,-2) & X = -1 & Y = -2) |
(not (default::thing(0,-2,Thing,_) & Thing \== dispenser) & not default::obstacle(0,-2) & X = 0 & Y = -2) |
(not (default::thing(1,-2,Thing,_) & Thing \== dispenser) & not default::obstacle(1,-2) & X = 1 & Y = -2) |
(not (default::thing(2,-2,Thing,_) & Thing \== dispenser) & not default::obstacle(2,-2) & X = 2 & Y = -2) |
(not (default::thing(2,-1,Thing,_) & Thing \== dispenser) & not default::obstacle(2,-1) & X = 2 & Y = -1) |
(not (default::thing(2,0,Thing,_) & Thing \== dispenser) & not default::obstacle(2,0) & X = 2 & Y = 0) |
(not (default::thing(2,1,Thing,_) & Thing \== dispenser) & not default::obstacle(2,1) & X = 2 & Y = 1) |
(not (default::thing(-2,1,Thing,_) & Thing \== dispenser) & not default::obstacle(-2,1) & X = -2 & Y = 1) |
(not (default::thing(-2,0,Thing,_) & Thing \== dispenser) & not default::obstacle(-2,0) & X = -2 & Y = 0) |
(not (default::thing(-2,-1,Thing,_) & Thing \== dispenser) & not default::obstacle(-2,-1) & X = -2 & Y = -1) |
(not (default::thing(-2,2,Thing,_) & Thing \== dispenser) & not default::obstacle(-2,2) & X = -2 & Y = 2) |
(not (default::thing(-1,2,Thing,_) & Thing \== dispenser) & not default::obstacle(-1,2) & X = -1 & Y = 2) |
(not (default::thing(0,2,Thing,_) & Thing \== dispenser) & not default::obstacle(0,2) & X = 0 & Y = 2) |
(not (default::thing(1,2,Thing,_) & Thing \== dispenser) & not default::obstacle(1,2) & X = 1 & Y = 2) |
(not (default::thing(2,2,Thing,_) & Thing \== dispenser) & not default::obstacle(2,2) & X = 2 & Y = 2)
.
find_empty_position(X,Y,3,Vision) :- (not (default::thing(-2,-3,Thing,_) & Thing \== dispenser) & not default::obstacle(-2,-3) & X = -2 & Y = -3) |
(not (default::thing(-1,-3,Thing,_) & Thing \== dispenser) & not default::obstacle(-1,-3) & X = -1 & Y = -3) |
(not (default::thing(0,-3,Thing,_) & Thing \== dispenser) & not default::obstacle(0,-3) & X = 0 & Y = -3) |
(not (default::thing(1,-3,Thing,_) & Thing \== dispenser) & not default::obstacle(1,-3) & X = 1 & Y = -3) |
(not (default::thing(2,-3,Thing,_) & Thing \== dispenser) & not default::obstacle(2,-3) & X = 2 & Y = -3) |
(not (default::thing(3,-2,Thing,_) & Thing \== dispenser) & not default::obstacle(3,-2) & X = 3 & Y = -2) |
(not (default::thing(3,-1,Thing,_) & Thing \== dispenser) & not default::obstacle(3,-1) & X = 3 & Y = -1) |
(not (default::thing(3,0,Thing,_) & Thing \== dispenser) & not default::obstacle(3,0) & X = 3 & Y = 0) |
(not (default::thing(3,1,Thing,_) & Thing \== dispenser) & not default::obstacle(3,1) & X = 3 & Y = 1) |
(not (default::thing(3,2,Thing,_) & Thing \== dispenser) & not default::obstacle(3,2) & X = 3 & Y = 2) |
(not (default::thing(-3,2,Thing,_) & Thing \== dispenser) & not default::obstacle(-3,2) & X = -3 & Y = 2) |
(not (default::thing(-3,1,Thing,_) & Thing \== dispenser) & not default::obstacle(-3,1) & X = -3 & Y = 1) |
(not (default::thing(-3,0,Thing,_) & Thing \== dispenser) & not default::obstacle(-3,0) & X = -3 & Y = 0) |
(not (default::thing(-3,-1,Thing,_) & Thing \== dispenser) & not default::obstacle(-3,-1) & X = -3 & Y = -1) |
(not (default::thing(-3,-2,Thing,_) & Thing \== dispenser) & not default::obstacle(-3,-2) & X = -3 & Y = -2) |
(not (default::thing(-2,3,Thing,_) & Thing \== dispenser) & not default::obstacle(-2,3) & X = -2 & Y = 3) |
(not (default::thing(-1,3,Thing,_) & Thing \== dispenser) & not default::obstacle(-1,3) & X = -1 & Y = 3) |
(not (default::thing(0,3,Thing,_) & Thing \== dispenser) & not default::obstacle(0,3) & X = 0 & Y = 3) |
(not (default::thing(1,3,Thing,_) & Thing \== dispenser) & not default::obstacle(1,3) & X = 1 & Y = 3) |
(not (default::thing(2,3,Thing,_) & Thing \== dispenser) & not default::obstacle(2,3) & X = 2 & Y = 3)
.
find_empty_position(X,Y,4,Vision) :- (not (default::thing(-1,-4,Thing,_) & Thing \== dispenser) & not default::obstacle(-1,-4) & X = -1 & Y = -4) |
(not (default::thing(0,-4,Thing,_) & Thing \== dispenser) & not default::obstacle(0,-4) & X = 0 & Y = -4) |
(not (default::thing(1,-4,Thing,_) & Thing \== dispenser) & not default::obstacle(1,-4) & X = 1 & Y = -4) |
(not (default::thing(4,-1,Thing,_) & Thing \== dispenser) & not default::obstacle(4,-1) & X = 4 & Y = -1) |
(not (default::thing(4,0,Thing,_) & Thing \== dispenser) & not default::obstacle(4,0) & X = 4 & Y = 0) |
(not (default::thing(4,1,Thing,_) & Thing \== dispenser) & not default::obstacle(4,1) & X = 4 & Y = 1) |
(not (default::thing(-4,1,Thing,_) & Thing \== dispenser) & not default::obstacle(-4,1) & X = -4 & Y = 1) |
(not (default::thing(-4,0,Thing,_) & Thing \== dispenser) & not default::obstacle(-4,0) & X = -4 & Y = 0) |
(not (default::thing(-4,-1,Thing,_) & Thing \== dispenser) & not default::obstacle(-4,-1) & X = -4 & Y = -1) |
(not (default::thing(-1,4,Thing,_) & Thing \== dispenser) & not default::obstacle(-1,4) & X = -1 & Y = 4) |
(not (default::thing(0,4,Thing,_) & Thing \== dispenser) & not default::obstacle(0,4) & X = 0 & Y = 4) |
(not (default::thing(1,4,Thing,_) & Thing \== dispenser) & not default::obstacle(1,4) & X = 1 & Y = 4)
.
find_empty_position(X,Y,5,Vision) :- (not (default::thing(0,-5,Thing,_) & Thing \== dispenser) & not default::obstacle(0,-5) & X = 0 & Y = -5) |
(not (default::thing(0,5,Thing,_) & Thing \== dispenser) & not default::obstacle(0,5) & X = 0 & Y = 5) |
(not (default::thing(-5,0,Thing,_) & Thing \== dispenser) & not default::obstacle(-5,0) & X = -5 & Y = 0) |
(not (default::thing(5,0,Thing,_) & Thing \== dispenser) & not default::obstacle(5,0) & X = 5 & Y = 0)
.
find_empty_position(X,Y,Count,Vision) :- Count <= Vision & find_empty_position(X,Y,Count+1,Vision). 

+!go_around(OldDir)
	: not common::avoid(_) & relative_right(OldDir, Dir) & not exploration::check_obstacle_special(Dir)
<-
	+avoid(1);
	.print("First avoid, no obstacles, direction ",Dir);
	!retrieve::smart_move(Dir);
//	!action::move(Dir);
	if (default::lastActionResult(failed_path)) {
		!retrieve::smart_move(Dir);
//		!action::move(Dir);
	}
	!go_around(OldDir, Dir);
	.
	
+!go_around(OldDir)
	: not common::avoid(_) & retrieve::block(X,Y)
.
	
+!go_around(OldDir)
	: not common::avoid(_)
<-
	+avoid(1);
	.print("First avoid, with obstacles");
	!retrieve::smart_move(OldDir);
//	!action::move(OldDir);
	if (default::lastActionResult(failed_path)) {
		!retrieve::smart_move(OldDir);
//		!action::move(OldDir);
	}
	!go_around(OldDir, OldDir);
	.
	
//+!go_around(n, Dir)
//	: common::avoid(Av) & Av < 3 & retrieve::block(0,-1)
//<-
//	-avoid(Av);
//	+avoid(Av+1);
//	!retrieve::smart_move(Dir);
////	!action::move(OldDir);
//	if (default::lastActionResult(failed_path)) {
//		!retrieve::smart_move(Dir);
////		!action::move(OldDir);
//	}
//	!go_around(n, Dir);
//	.
//	
//+!go_around(s, Dir)
//	: common::avoid(Av) & Av < 3 & retrieve::block(0,1)
//<-
//	-avoid(Av);
//	+avoid(Av+1);
//	!retrieve::smart_move(Dir);
////	!action::move(OldDir);
//	if (default::lastActionResult(failed_path)) {
//		!retrieve::smart_move(Dir);
////		!action::move(OldDir);
//	}
//	!go_around(s, Dir);
//	.
//	
//+!go_around(e, Dir)
//	: common::avoid(Av) & Av < 3 & retrieve::block(1,0)
//<-
//	-avoid(Av);
//	+avoid(Av+1);
//	!retrieve::smart_move(Dir);
////	!action::move(OldDir);
//	if (default::lastActionResult(failed_path)) {
//		!retrieve::smart_move(Dir);
////		!action::move(OldDir);
//	}
//	!go_around(e, Dir);
//	.
//	
//+!go_around(w, Dir)
//	: common::avoid(Av) & Av < 3 & retrieve::block(-1,0)
//<-
//	-avoid(Av);
//	+avoid(Av+1);
//	!retrieve::smart_move(Dir);
////	!action::move(OldDir);
//	if (default::lastActionResult(failed_path)) {
//		!retrieve::smart_move(Dir);
////		!action::move(OldDir);
//	}
//	!go_around(w, Dir);
//	.
	
+!go_around(OldDir, Dir)
	: common::avoid(Av) & Av < 3
<-
	-avoid(Av);
	+avoid(Av+1);
	!retrieve::smart_move(OldDir);
//	!action::move(OldDir);
	if (default::lastActionResult(failed_path)) {
		!retrieve::smart_move(OldDir);
//		!action::move(OldDir);
	}
	!go_around(OldDir, Dir);
	.
	
+!go_around(OldDir, Dir)
	: common::avoid(3) & OldDir \== Dir & exploration::remove_opposite(Dir,NewDir)
<-
	-avoid(3);
	.print("@@@@@@@@@@ Finished go around no obstacle");
	!retrieve::smart_move(NewDir);
//	!action::move(NewDir);
	if (default::lastActionResult(failed_path)) {
		!retrieve::smart_move(NewDir);
//		!action::move(NewDir);
	}
	.
	
+!go_around(OldDir, Dir)
	: common::avoid(3)
<-
	-avoid(3);
	.print("@@@@@@@@@@ Finished go around");
	!action::move(OldDir);
	if (default::lastActionResult(failed_path)) {
		!action::move(OldDir);
	}
	.
	
+!escape(MoveBackX,MoveBackY)
	: default::vision(V) & find_empty_position(X,Y,1,V)
<-
	+escape;
	!move_to_escape(X,Y,MoveBackX,MoveBackY);
	-escape;
	.
+!escape(0,0)
	: true
<-
	+escape;
	!no_escape;
	-escape;
	.
	
+!no_escape : escape & not default::thing(0,0,marker,clear) & not default::thing(0,0,marker,ci) 
<-
	if (retrieve::block(X,Y)) {
		 if (default::thing(X,Y,marker,clear) | default::thing(X,Y,marker,ci)) {
			!action::skip; 
			!no_escape;
		}
	}
	.
+!no_escape : escape <- !action::skip; !no_escape.
	
+!move_to_escape(0,0,MoveBackX,MoveBackY).
//+!move_to_escape(MyX,MyY,X,Y)
//	: escape & default::thing(X-MyX, Y-MyY, Thing, _) & Thing \== dispenser & (X-MyX = 1 | X-MyX = -1 | Y-MyY = 1 | Y-MyY = -1) & default::vision(V) & find_empty_position(XNew,YNew,1,V)
//<-
//	!move_to_escape(MyX,MyY,XNew,YNew);
//	.
+!move_to_escape(MyX,MyY,X,Y) : escape & not default::thing(0,0,marker,clear) & not default::thing(0,0,marker,ci)
<-
	if(retrieve::block(X,Y) & (default::thing(X,Y,marker,clear) | default::thing(X,Y,marker,ci))) {
		!action::rotate(cw);
		if (common::my_role(origin) & default::lastAction(rotate) & default::lastActionResult(success)) {
			+rotate_back(1);
		}
		if(retrieve::block(X,Y) & (default::thing(X,Y,marker,clear) | default::thing(X,Y,marker,ci))) {
			!action::rotate(cw);
			if (common::my_role(origin) & default::lastAction(rotate) & default::lastActionResult(success)) {
				if (common::rotate_back(RB)) {
					-+rotate_back(RB+1);
				}
				else {
					+rotate_back(1);
				}
			}
		}
	}
	.
+!move_to_escape(X,Y,MoveBackX,MoveBackY)
	: escape & X < 0 
<-
	!action::move(w);
	if (default::lastAction(move) & default::lastActionResult(success)) {
		!move_to_escape(X+1,Y,MoveBackX+1,MoveBackY);
	}
	else {
		!move_to_escape(X,Y,MoveBackX,MoveBackY);
	}
	.
+!move_to_escape(X,Y,MoveBackX,MoveBackY)
	: escape & X > 0 
<-
	!action::move(e);
	if (default::lastAction(move) & default::lastActionResult(success)) {
		!move_to_escape(X-1,Y,MoveBackX-1,MoveBackY);
	}
	else {
		!move_to_escape(X,Y,MoveBackX,MoveBackY);
	}
	.
+!move_to_escape(X,Y,MoveBackX,MoveBackY)
	: escape & Y < 0 
<-
	!action::move(n);
	if (default::lastAction(move) & default::lastActionResult(success)) {
		!move_to_escape(X,Y+1,MoveBackX,MoveBackY+1);
	}
	else {
		!move_to_escape(X,Y,MoveBackX,MoveBackY);
	}
	.
+!move_to_escape(X,Y,MoveBackX,MoveBackY)
	: escape & Y > 0 
<-
	!action::move(s);
	if (default::lastAction(move) & default::lastActionResult(success)) {
		!move_to_escape(X,Y-1,MoveBackX,MoveBackY-1);
	}
	else {
		!move_to_escape(X,Y,MoveBackX,MoveBackY);
	}
	.

+!move_back(0, 0).
+!move_back(X, Y) : X < 0 
<- 
	!action::move(w);
	if (default::lastAction(move) & default::lastActionResult(success)) {
		!move_back(X+1,Y);
	}
	else {
	}
	.
+!move_back(X, Y) : X > 0 
<- 
	!action::move(e);
	if (default::lastAction(move) & default::lastActionResult(success)) {
		!move_back(X-1,Y);
	}
	else {
	}
	.
+!move_back(X, Y) : Y > 0 
<- 
	!action::move(s);
	if (default::lastAction(move) & default::lastActionResult(success)) {
		!move_back(X,Y-1);
	}
	else {
	}
	.
+!move_back(X, Y) : Y < 0 
<- 
	!action::move(n);
	if (default::lastAction(move) & default::lastActionResult(success)) {
		!move_back(X,Y+1);
	}
	else {
	}
	.

+!common::update_role_to(Role) : common::my_role(Role).
+!common::update_role_to(NewRole) :
	common::my_role(MyRole)
<-
	.print("My role is now: ", NewRole);
	-+common::previous_role(MyRole);
	-+common::my_role(NewRole);
	!action::skip;
	.
+!common::update_role_to(NewRole) :
	true
<-
	.print("My role is now: ", NewRole);
	-+common::my_role(NewRole)
	.
+!common::go_back_to_previous_role :
	common::previous_role(MyRole) & common::my_role(OldRole)
<-
	.print("Going back to role: ", OldRole);
	-+common::my_role(MyRole);
	-+common::previous_role(OldRole);
	!action::skip;
	.

@removeblockbelief[atomic]
+default::actionID(_)
	: retrieve::block(X,Y) & default::lastAction(rotate) & default::lastActionResult(success) & default::lastActionParams([Direction|List]) & common::rotate_direction(Direction,NewX,NewY) & not default::thing(NewX,NewY,block,_)
<-
	-retrieve::block(X,Y);
	.
	
@removeblockbeliefnorotate[atomic]
+default::actionID(_)
	: not default::lastAction(rotate) & retrieve::block(X,Y) & not default::thing(X,Y,block,_)
<-
	-retrieve::block(X,Y);
	.
	
	