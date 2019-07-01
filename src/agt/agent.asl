{ include("common-cartago.asl") }
{ include("common-moise.asl") }
{ include("org-obedient.asl", org) }
{ include("action/actions.asl",action) }
	
+!register(E)
	: .my_name(Me)
<- 
    .print("Registering...");
    register(E);
	.

+default::name(ServerMe)
	: .my_name(Me)
<-
	addServerName(Me,ServerMe);
	.

+default::actionID(0)
	: True
<- 
	!!always_move_north;
    .

    
+!always_move_north
	: True
<-
	!action::move(n);
	!!always_move_north;
	.
-!always_move_north <- !!always_move_north.


+default::thing(X, Y, entity, Team)
	: default::team(Team)
<-
	.print("I see another agent of my team at ",X,",",Y);
	.
	