{ include("common-cartago.asl") }
{ include("common-moise.asl") }
{ include("org-obedient.asl", org) }
{ include("action/actions.asl",action) }
{ include("strategy/identification.asl",identification) }
{ include("strategy/exploration.asl",exploration) }
	
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
	: true <- 
//	!!always_move_north;
	!!exploration::explore([n,s,e,w]);
	.

    
//+!always_move_north
//	: true
//<-
//	!action::move(n);
//	!!always_move_north;
//	.
//-!always_move_north <- !!always_move_north.



	