{ include("common-cartago.asl") }
{ include("common-moise.asl") }
{ include("org-obedient.asl", org) }
{ include("action/actions.asl", action) }
{ include("strategy/identification.asl", identification) }
{ include("strategy/exploration.asl", exploration) }
{ include("strategy/task.asl", task) }
{ include("strategy/when_to_stop.asl", stop) }
{ include("strategy/stock.asl", retrieve) }
{ include("strategy/map.asl", map) }
{ include("strategy/common-plans.asl", common) }
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

+default::actionID(_)
	: not start
<- 
	+start;
	.wait(1000);
//	!always_skip;
	!!exploration::explore([n,s,e,w]);
	.
	
	
+!always_skip :
	not task::origin & default::attached(0, 1) & default::team(Team) & (default::thing(1, 1, entity, Team) | default::thing(-1, 1, entity, Team))
<-
	!action::rotate(cw);
	while(not default::lastActionResult(success)){
		!action::rotate(cw);
	}
	!action::rotate(cw);
	while(not default::lastActionResult(success)){
		!action::rotate(cw);
	}
	!action::rotate(cw);
	while(not default::lastActionResult(success)){
		!action::rotate(cw);
	}
	!action::rotate(cw);
	while(not default::lastActionResult(success)){
		!action::rotate(cw);
	}
	!!always_skip;
	.
+!always_skip
	: true
<-
	!action::move(z);
	!!always_skip;
	.
-!always_skip <- !!always_skip.
    
+!always_move_north
	: true
<-
	!action::move(n);
	!!always_move_north;
	.
-!always_move_north <- !!always_move_north.
