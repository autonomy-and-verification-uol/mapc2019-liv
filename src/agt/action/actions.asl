{ include("reasoning-engine.asl") }

// ##### MOVE ACTION #####
// Check if you can get out of a clear immediate (<= 2 steps)

// Get out of a clear marker
//+!move(Direction)
//	: (default::thing(0,0,marker,clear) | default::thing(0,0,marker,ci))  & not common::escape
//<-
//	getMyPos(MyX, MyY);
//	if (retrieve::block(X,Y)) {
//		+rotate_block(X,Y);
//	}
//	!common::escape;
//	!common::move_to_pos(MyX, MyY);
//	if (action::rotate_block(X,Y)) {
//		while (not retrieve::block(X,Y)) {
//			!rotate(cw);
//		}
//		-rotate_block(X,Y);
//	} 
//	!move(Direction);
//	.
// Avoid clear markers moving north
+!move(n)
	: not default::thing(0,0,marker,clear) & not default::thing(0,0,marker,ci) & ((default::thing(0,-1,marker,clear) | default::thing(0,-1,marker,ci)) | (retrieve::block(0,-1) & (default::thing(0,-2,marker,clear) | default::thing(0,-2,marker,ci))))
<-
	!skip;
	!move(n);
	.
// Avoid clear markers moving south
+!move(s)
	: not default::thing(0,0,marker,clear) & not default::thing(0,0,marker,ci) & ((default::thing(0,1,marker,clear) | default::thing(0,1,marker,ci)) | (retrieve::block(0,1) & (default::thing(0,2,marker,clear) | default::thing(0,2,marker,ci))))
<-
	!skip;
	!move(s);
	.
// Avoid clear markers moving east
+!move(e)
	: not default::thing(0,0,marker,clear) & not default::thing(0,0,marker,ci) & ((default::thing(1,0,marker,clear) | default::thing(1,0,marker,ci)) | (retrieve::block(1,0) & (default::thing(2,0,marker,clear) | default::thing(2,0,marker,ci))))
<-
	!skip;
	!move(e);
	.
// Avoid clear markers moving west
+!move(e)
	: not default::thing(0,0,marker,clear) & not default::thing(0,0,marker,ci) & ((default::thing(-1,0,marker,clear) | default::thing(-1,0,marker,ci))  | (retrieve::block(-1,0) & (default::thing(-2,0,marker,clear) | default::thing(-2,0,marker,ci))))
<-
	!skip;
	!move(w);
	.	
//// Go around a friendly agent
//+!move(Direction)
//	: exploration::check_agent(Direction) & not common::avoid(_)
//<-
//	!common::go_around(Direction);
//	!action::commit_action(move(Direction));
//	.
// Default move behaviour
+!move(Direction)
<-
	!action::commit_action(move(Direction));
	.
-!move(Direction)[code(.fail(action(Action),result(failed_parameter)))] <- .print("Direction ",Direction," is not valid, it should be one of {n,s,e,w}.").
// Improve this failure to drop disjunction into two different plans
-!move(Direction)[code(.fail(action(Action),result(failed_path)))] : common::direction_block(Direction,X,Y) & retrieve::block(X,Y) & not common::check_obstacle_bounds(Direction) <- .print("Destination is out of bounds for my block."); +action::out_of_bounds(Direction).
-!move(Direction)[code(.fail(action(Action),result(failed_path)))] <- .print("Destination is blocked, or one of my attached things is blocking.").
-!move(Direction)[code(.fail(action(Action),result(failed_forbidden)))] <- .print("Destination is out of bounds."); +action::out_of_bounds(Direction).
-!move(Direction)[code(.fail(action(Action),result(failed_status)))] <- .print("Agent is disabled."); !move(Direction).	

// ##### ATTACH BLOCK ACTION #####
+!attach(Direction)
<-
	!action::commit_action(attach(Direction));
	if (default::lastAction(attach) & default::lastActionResult(success) & common::direction_block(Direction,X,Y)) {
		+retrieve::block(X,Y);
	}
	.
-!attach(Direction)[code(.fail(action(Action),result(failed_parameter)))] <- .print("Direction ",Direction," is not valid, it should be one of {n,s,e,w}.").
-!attach(Direction)[code(.fail(action(Action),result(failed_target)))] <- .print("There is nothing to attach in direction ",Direction).
// Improve this failure to drop disjunction into two different plans
-!attach(Direction)[code(.fail(action(Action),result(failed)))] <- .print("Too many things attached, or it is already attached to an opponent.").
-!attach(Direction)[code(.fail(action(Action),result(failed_status)))] <- .print("Agent is disabled."); !attach(Direction).	

// ##### ATTACH BLOCK ACTION #####
+!detach(Direction)
<-
	!action::commit_action(detach(Direction));
	if (default::lastAction(detach) & default::lastActionResult(success) & common::direction_block(Direction,X,Y)) {
		-retrieve::block(X,Y);
	}
	.
-!detach(Direction)[code(.fail(action(Action),result(failed_parameter)))] <- .print("Direction ",Direction," is not valid, it should be one of {n,s,e,w}.").
-!detach(Direction)[code(.fail(action(Action),result(failed_target)))] <- .print("There is nothing to detach in direction ",Direction).
-!detach(Direction)[code(.fail(action(Action),result(failed)))] <- .print("The thing can't be detached because it is not attached.").
-!detach(Direction)[code(.fail(action(Action),result(failed_status)))] <- .print("Agent is disabled."); !detach(Direction).

// ##### ROTATE ACTION #####
// Get out of a clear marker
//+!rotate(Direction)
//	: (default::thing(0,0,marker,clear) | default::thing(0,0,marker,ci)) & not common::escape & retrieve::block(X,Y)
//<-
//	getMyPos(MyX, MyY);
//	!common::escape;
//	!common::move_to_pos(MyX, MyY); 
//	while (not retrieve::block(X,Y)) {
//		!rotate(Direction);
//	}
//	!rotate(Direction);
//	.
// Avoid clear markers when rotating
+!rotate(Direction)
	: not default::thing(0,0,marker,clear) & not default::thing(0,0,marker,ci) & common::rotate_direction(Direction,X,Y) & (default::thing(X,Y,marker,clear) | default::thing(X,Y,marker,ci))
<-
	!skip;
	!rotate(Direction);
	.
// Default rotate behaviour
+!rotate(Direction)
<-
	!action::commit_action(rotate(Direction));
	if (default::lastAction(rotate) & default::lastActionResult(success) & retrieve::block(X,Y) & common::rotate_direction(Direction,NewX,NewY)) {
		-retrieve::block(X,Y);
		+retrieve::block(NewX,NewY);
	}
	.
-!rotate(Direction)[code(.fail(action(Action),result(failed_parameter)))] <- .print("Rotation ",Direction," is not valid, it should be one of {cw,cww}.").
// Improve this failure to drop disjunction into two different plans
//-!rotate(Direction)[code(.fail(action(Action),result(failed)))] : task::origin <- .print("One of the things attached cannot rotate, or the agent is attached to another agent."); !rotate(Direction).
-!rotate(Direction)[code(.fail(action(Action),result(failed)))] <- .print("One of the things attached cannot rotate, or the agent is attached to another agent."). //; !rotate(Direction).
-!rotate(Direction)[code(.fail(action(Action),result(failed_status)))] <- .print("Agent is disabled."); !rotate(Direction).

// ##### CONNECT ACTION #####
+!connect(Agent,X,Y)
<-
	getServerName(Agent,AgentServer);
	!action::commit_action(connect(AgentServer,X,Y));
	.
// Improve this failure to drop disjunction into two different plans
-!connect(Agent,X,Y)[code(.fail(action(Action),result(failed_parameter)))] <- .print(Agent," is not in our team, or ",X," and ",Y," are not valid integers.").
// Improve this failure to drop disjunction into two different plans
-!connect(Agent,X,Y)[code(.fail(action(Action),result(failed_partner)))] <- .print("The other agent didn't send connect action, or failed randomly, or it had wrong parameters. Trying again."); !connect(Agent,X,Y).
// Improve this failure to drop disjunction into two different plans
-!connect(Agent,X,Y)[code(.fail(action(Action),result(failed_target)))] <- .print("No blocks at given position, or not attached to the agent, or already attached to the other agent").
// Improve this failure to drop disjunction into two different plans
-!connect(Agent,X,Y)[code(.fail(action(Action),result(failed)))] <- .print("Position is too far, or agents are already connected, or violates the attach limit.").
-!connect(Agent,X,Y)[code(.fail(action(Action),result(failed_status)))] <- .print("Agent is disabled."); !connect(Agent,X,Y).

// ##### DISCONNECT ACTION #####
+!disconnect(X1,Y1,X2,Y2)
<-
	!action::commit_action(disconnect(X1,Y1,X2,Y2));
	.
-!disconnect(X1,Y1,X2,Y2)[code(.fail(action(Action),result(failed_parameter)))] <- .print(X1," and ",Y1," and ",X2," and ",Y2," are not valid integers.").
// Improve this failure to drop disjunction into two different plans
-!disconnect(X1,Y1,X2,Y2)[code(.fail(action(Action),result(failed_target)))] <- .print("Target locations are not attachments, or they are not attached to each other directly").
-!disconnect(X1,Y1,X2,Y2)[code(.fail(action(Action),result(failed_status)))] <- .print("Agent is disabled."); !disconnect(X1,Y1,X2,Y2).

// ##### REQUEST BLOCK ACTION #####
+!request(Direction)
<-
	!action::commit_action(request(Direction));
	.
-!request(Direction)[code(.fail(action(Action),result(failed_parameter)))] <- .print("Direction ",Direction," is not valid, it should be one of {n,s,e,w}.").
-!request(Direction)[code(.fail(action(Action),result(failed_target)))] <- .print("There is no dispenser in direction ",Direction).
-!request(Direction)[code(.fail(action(Action),result(failed_blocked)))] <- .print("The dispenser is blocked.").
-!request(Direction)[code(.fail(action(Action),result(failed_status)))] <- .print("Agent is disabled."); !request(Direction).

// ##### SUBMIT TASK ACTION #####
+!submit(Task)
<-
	!action::commit_action(submit(Task));
	if (default::submit(submit) & default::lastActionResult(success)) {
		.abolish(retrieve::block(_,_));
	}
	.
-!submit(Task)[code(.fail(action(Action),result(failed_target)))] <- .print("There is no active task named ",Task).
// Improve this failure to drop disjunction into two different plans
-!submit(Task)[code(.fail(action(Action),result(failed)))] <- .print("At least one block is missing, or the agent is not in a goal terrain.").
-!submit(Task)[code(.fail(action(Action),result(failed_status)))] <- .print("Agent is disabled."); !submit(Task).

// ##### CLEAR ACTION #####
+!clear(X,Y)
<-
	!action::commit_action(clear(X,Y));
	.
-!clear(X,Y)[code(.fail(action(Action),result(failed_parameter)))] <- .print(X," and ",Y," are not valid integers.").
-!clear(X,Y)[code(.fail(action(Action),result(failed_target)))] <- .print("Target location is not within the agent's vision or outside the grid.").
-!clear(X,Y)[code(.fail(action(Action),result(failed_status)))] : default::energy(Energy) & Energy < 30 <- .print("Energy is too low.").
-!clear(X,Y)[code(.fail(action(Action),result(failed_status)))] <- .print("Agent is disabled."); !clear(X,Y).

// ##### SKIP ACTION #####
+!skip
	: ((default::thing(0,0,marker,clear) | default::thing(0,0,marker,ci)) | (retrieve::block(X,Y) & (default::thing(X,Y,marker,clear) | default::thing(X,Y,marker,ci)))) & not common::escape
<-
	if (common::my_role(origin)) {
		?common::safe_origin_pos(X,Y);
		if (X \== 0 & Y \== 0 & retrieve::block(_,_)) {
			+common::escape;
			!common::move_to_escape(X,Y,MoveBackX,MoveBackY);
			-common::escape;
			if (common::rotate_back(RB)) {
			     for ( .range(I,1,RB) ) {
			     	!action::rotate(ccw);
			     }
			     -common::rotate_back(RB);
			}
			!common::move_back(MoveBackX,MoveBackY);
		}
		else {
			!action::commit_action(skip); 
		}
	}
	else {
		!common::escape(MoveBackX,MoveBackY);
		!common::move_back(MoveBackX,MoveBackY);
	}

	.
+!skip
<-
	!action::commit_action(skip);
	.
-!skip[code(.fail(action(Action),result(failed_status)))] <- .print("Agent is disabled.").
-!skip[code(.fail(action(Action),result(failed_random)))] <- .print("Skip failed random, but we don't care.").

