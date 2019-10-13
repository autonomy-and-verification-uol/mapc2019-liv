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
{ include("strategy/planner.asl", planner) }
{ include("strategy/new-round.asl", newround) }
{ include("strategy/end-round.asl", endround) }
	
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
	task::origin  & 
	not task::committed(_,_) & default::obstacle(X,Y) & default::energy(Energy) & Energy >= 30
<-
	for(.range(I, 1, 3) & not task::committed(_,_)){
		if (retrieve::block(BX,BY)) {
			if (BX == X-1) {
				!action::clear(X+1,Y);
			}
			elif (BX == X+1) {
				!action::clear(X-1,Y);
			}
			elif (YX == Y-1) {
				!action::clear(X,Y+1);
			}
			elif (YX == Y+1) {
				!action::clear(X,Y-1);
			}
			else {
				if(not default::thing(X, Y, block, _) & 
				not default::thing(X-1, Y, block, _) &
				not default::thing(X+1, Y, block, _) &
				not default::thing(X, Y-1, block, _) &
				not default::thing(X, Y+1, block, _) &
				not default::thing(X, Y, entity, Team) & 
				not default::thing(X-1, Y, entity, Team) &
				not default::thing(X+1, Y, entity, Team) &
				not default::thing(X, Y-1, entity, Team) &
				not default::thing(X, Y+1, entity, Team)
				){
					!action::clear(X,Y);
				}
				else {
					!action::skip;
				}
			}
		}
		else {
			if(not default::thing(X, Y, block, _) & 
			not default::thing(X-1, Y, block, _) &
			not default::thing(X+1, Y, block, _) &
			not default::thing(X, Y-1, block, _) &
			not default::thing(X, Y+1, block, _) &
			not default::thing(X, Y, entity, Team) & 
			not default::thing(X-1, Y, entity, Team) &
			not default::thing(X+1, Y, entity, Team) &
			not default::thing(X, Y-1, entity, Team) &
			not default::thing(X, Y+1, entity, Team)
			){
				!action::clear(X,Y);
			}
			else {
				!action::skip;
			}
		}
	}
	!!always_skip;
	.

+!always_skip :
	common::my_role(retriever) &
	not retrieve::block(X, Y)
<-
	!!retrieve::retrieve_block;
	.
+!always_skip
	: true
<-
	!action::skip;
	!!always_skip;
	.
    
+!always_move_north
	: true
<-
	!action::move(n);
	!!always_move_north;
	.
