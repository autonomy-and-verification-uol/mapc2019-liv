relative_right(n,e) :- true.
relative_right(s,w) :- true.
relative_right(e,s) :- true.
relative_right(w,n) :- true.

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
	: not common::avoid(_) & relative_right(OldDir, Dir) & not exploration::check_obstacle_all(Dir)
<-
	+avoid(1);
	.print("First avoid, no obstacles, direction ",Dir);
	!action::move(Dir);
	!go_around(OldDir, Dir);
	.
	
+!go_around(OldDir)
	: not common::avoid(_)
<-
	+avoid(1);
	.print("First avoid, with obstacles");
	!action::move(OldDir);
	!go_around(OldDir, OldDir);
	.
	
+!go_around(OldDir, Dir)
	: common::avoid(Av) & Av < 3
<-
	-avoid(Av);
	+avoid(Av+1);
	!action::move(OldDir);
	!go_around(OldDir, Dir);
	.
	
+!go_around(OldDir, Dir)
	: common::avoid(3) & OldDir \== Dir & exploration::remove_opposite(Dir,NewDir)
<-
	-avoid(3);
	.print("@@@@@@@@@@ Finished go around");
	!action::move(NewDir);
	.
	
+!go_around(OldDir, Dir)
	: common::avoid(3)
<-
	-avoid(3);
	.print("@@@@@@@@@@ Finished go around");
	!action::move(OldDir);
	.
	
+!escape
	: default::vision(V) & find_empty_position(X,Y,1,V)
<-
	+escape;
	getMyPos(MyX,MyY);
	!move_to_escape(MyX,MyY,MyX+X,MyY+Y);
	-escape;
	.
+!escape
	: true
<-
	+escape;
	!no_escape;
	-escape;
	.
	
+!no_escape : not default::thing(0,0,marker,clear) & not default::thing(0,0,marker,ci).
+!no_escape <- !action::commit_action(move(z)); !no_escape.
	
+!move_to_escape(MyX,MyY,MyX,MyY).
+!move_to_escape(MyX,MyY,X,Y) : not default::thing(0,0,marker,clear) & not default::thing(0,0,marker,ci).
+!move_to_escape(MyX,MyY,X,Y)
	: default::thing(X-MyX, Y-MyY, Thing, _) & Thing \== dispenser & (X-MyX = 1 | X-MyX = -1 | Y-MyY = 1 | Y-MyY = -1) & default::vision(V) & find_empty_position(XNew,YNew,1,V)
<-
	!move_to_escape(MyX,MyY,XNew,YNew);
	.
+!move_to_escape(MyX,MyY,X,Y)
	: X < MyX 
<-
	!action::move(w);
	getMyPos(MyXNew,MyYNew);
	!move_to_escape(MyXNew,MyYNew,X,Y);
	.
+!move_to_escape(MyX,MyY,X,Y)
	: X > MyX 
<-
	!action::move(e);
	getMyPos(MyXNew,MyYNew);
	!move_to_escape(MyXNew,MyYNew,X,Y);
	.
+!move_to_escape(MyX,MyY,X,Y)
	: Y < MyY 
<-
	!action::move(n);
	getMyPos(MyXNew,MyYNew);
	!move_to_escape(MyXNew,MyYNew,X,Y);
	.
+!move_to_escape(MyX,MyY,X,Y)
	: Y > MyY 
<-
	!action::move(s);
	getMyPos(MyXNew,MyYNew);
	!move_to_escape(MyXNew,MyYNew,X,Y);
	.