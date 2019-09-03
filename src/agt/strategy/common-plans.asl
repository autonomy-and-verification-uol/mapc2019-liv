relative_right(n,e) :- true.
relative_right(s,w) :- true.
relative_right(e,s) :- true.
relative_right(w,n) :- true.

+!go_around(OldDir)
	: not common::avoid(_) & relative_right(OldDir, Dir) & not exploration::check_obstacle_all(Dir)
<-
	+avoid(1);
	!action::move(Dir);
	!!go_around(OldDir, Dir);
	.
	
+!go_around(OldDir)
	: not common::avoid(_)
<-
	+avoid(1);
	!action::move(OldDir);
	!!go_around(OldDir, Dir);
	.
	
+!go_around(OldDir, Dir)
	: common::avoid(Av) & Av < 3
<-
	-avoid(Av);
	+avoid(Av+1);
	!action::move(OldDir);
	!!go_around(OldDir, Dir);
	.
	
+!go_around(OldDir, Dir)
	: common::avoid(3) & OldDir \== Dir & exploration::remove_opposite(Dir,NewDir)
<-
	-avoid(3);
	!action::move(NewDir);
	.
	
+!go_around(OldDir, Dir)
	: common::avoid(3)
<-
	-avoid(3);
	!action::move(OldDir);
	.