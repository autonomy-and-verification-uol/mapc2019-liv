{ include("common-cartago.asl") }
{ include("common-moise.asl") }
{ include("org-obedient.asl", org) }
{ include("action/actions.asl",action) }
{ include("action/identification.asl",identification) }
	
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

/*+default::actionID(0)
	: .my_name(Me) & Me == agent1 <- 
	+pippo(Me);
	!action::connect(agentA2, 1, 0);
	!action::move(e);
	!action::move(e).
	//!!always_move_south.
 +default::actionID(0)
	: .my_name(Me) & Me == agent2<-
	+pappo;
	!action::connect(agentA1, -1, 0);
	!action::detach(w);
	!action::move(w).
	//!!always_move_north.*/

// Commented Angelo's agent detection for now
//+default::actionID(_)
//	: .my_name(Me) <- 
//	!identification::check_things.
//	//.random(N);
//	//!random_move(N).
//	//!!always_move_south.

+default::actionID(0)
	: True <- 
	!!always_move_south.

+!random_move(N) : N <= 0.25 <- .print("go north"); !action::move(n).
+!random_move(N) : N <= 0.5 <- .print("go south"); !action::move(s).
+!random_move(N) : N <= 0.75 <- .print("go west"); !action::move(w).
+!random_move(N) <- .print("go east"); !action::move(e).

+!always_move_south
	: True
<-
	!action::move(s);
	!!always_move_south;
	.
-!always_move_south <- !!always_move_south.
    
+!always_move_north
	: True
<-
	!action::move(n);
	!!always_move_north;
	.
-!always_move_north <- !!always_move_north.



	