{ include("common-cartago.asl") }
{ include("common-moise.asl") }
{ include("org-obedient.asl", org) }
{ include("action/actions.asl", action) }
{ include("strategy/identification.asl", identification) }
{ include("strategy/exploration.asl", exploration) }
{ include("strategy/retrieve_block.asl", retrieve) }
{ include("strategy/when_to_stop.asl", stop) }
{ include("strategy/stock.asl", stock) }
{ include("strategy/map.asl", map) }
{ include("strategy/new-round.asl", newround) }
	
+!register(E)
	: .my_name(Me)
<- 
	!newround::new_round;
    .print("Registering...");
    register(E);
	.

+default::name(ServerMe)
	: .my_name(Me)
<-
	addServerName(Me,ServerMe);
	.

+default::actionID(0)
	: true 
<- 
	!!exploration::explore([n,s,e,w]);
	.
    
//+!always_move_north
//	: true
//<-
//	!action::move(n);
//	!!always_move_north;
//	.
//-!always_move_north <- !!always_move_north.



	