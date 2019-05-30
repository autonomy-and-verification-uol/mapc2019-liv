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

+default::steps(Steps)
	: True
<- 
	.print("Hello World!");
	!always_move_north;
    .
    
+!default::always_move_north
	: True
<-
	!action::move_north;
	!always_move_north;
	.
    