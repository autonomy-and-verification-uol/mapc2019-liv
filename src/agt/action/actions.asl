{ include("reasoning-engine.asl") }

// ##### MOVE ACTION #####
+!move(Direction)
<-
	!action::commit_action(move(Direction));
	.
-!move(Direction)[code(.fail(action(Action),result(failed_parameter)))] <- .print("Direction ",Direction," is not valid, it should be one of {n,s,e,w}.").
// Improve this failure to drop disjunction into two different plans
-!move(Direction)[code(.fail(action(Action),result(failed_path)))] <- .print("Destination is blocked, or one of my attached things is blocking.").
-!move(Direction)[code(.fail(action(Action),result(failed_forbidden)))] <- .print("Destination is out of bounds."); +action::out_of_bounds(Direction).
-!move(Direction)[code(.fail(action(Action),result(failed_status)))] <- .print("Agent is disabled.").	

// ##### ATTACH BLOCK ACTION #####
+!attach(Direction)
<-
	!action::commit_action(attach(Direction));
	.
-!attach(Direction)[code(.fail(action(Action),result(failed_parameter)))] <- .print("Direction ",Direction," is not valid, it should be one of {n,s,e,w}.").
-!attach(Direction)[code(.fail(action(Action),result(failed_target)))] <- .print("There is nothing to attach in direction ",Direction).
// Improve this failure to drop disjunction into two different plans
-!attach(Direction)[code(.fail(action(Action),result(failed)))] <- .print("Too many things attached, or it is already attached to an opponent.").
-!attach(Direction)[code(.fail(action(Action),result(failed_status)))] <- .print("Agent is disabled.").	

// ##### ATTACH BLOCK ACTION #####
+!detach(Direction)
<-
	!action::commit_action(detach(Direction));
	.
-!detach(Direction)[code(.fail(action(Action),result(failed_parameter)))] <- .print("Direction ",Direction," is not valid, it should be one of {n,s,e,w}.").
-!detach(Direction)[code(.fail(action(Action),result(failed_target)))] <- .print("There is nothing to detach in direction ",Direction).
-!detach(Direction)[code(.fail(action(Action),result(failed)))] <- .print("The thing can't be detached because it is not attached.").
-!detach(Direction)[code(.fail(action(Action),result(failed_status)))] <- .print("Agent is disabled.").

// ##### ROTATE ACTION #####
+!rotate(Direction)
<-
	!action::commit_action(rotate(Direction));
	.
-!rotate(Direction)[code(.fail(action(Action),result(failed_parameter)))] <- .print("Rotation ",Direction," is not valid, it should be one of {cw,cww}.").
// Improve this failure to drop disjunction into two different plans
-!rotate(Direction)[code(.fail(action(Action),result(failed)))] <- .print("One of the things attached cannot rotate, or the agent is attached to another agent.").
-!rotate(Direction)[code(.fail(action(Action),result(failed_status)))] <- .print("Agent is disabled.").

// ##### CONNECT ACTION #####
+!connect(Agent,X,Y)
<-
	getServerName(Agent,AgentServer);
	!action::commit_action(connect(AgentServer,X,Y));
	.
// Improve this failure to drop disjunction into two different plans
-!connect(Agent,X,Y)[code(.fail(action(Action),result(failed_parameter)))] <- .print(Agent," is not in our team, or ",X," and ",Y," are not valid integers.").
// Improve this failure to drop disjunction into two different plans
-!connect(Agent,X,Y)[code(.fail(action(Action),result(failed_partner)))] <- .print("The other agent didn't send connect action, or failed randomly, or it had wrong parameters.").
// Improve this failure to drop disjunction into two different plans
-!connect(Agent,X,Y)[code(.fail(action(Action),result(failed_target)))] <- .print("No blocks at given position, or not attached to the agent, or already attached to the other agent").
// Improve this failure to drop disjunction into two different plans
-!connect(Agent,X,Y)[code(.fail(action(Action),result(failed)))] <- .print("Position is too far, or agents are already connected, or violates the attach limit.").
-!connect(Agent,X,Y)[code(.fail(action(Action),result(failed_status)))] <- .print("Agent is disabled.").

// ##### DISCONNECT ACTION #####
+!disconnect(X1,Y1,X2,Y2)
<-
	!action::commit_action(disconnect(X1,Y1,X2,Y2));
	.
-!disconnect(X1,Y1,X2,Y2)[code(.fail(action(Action),result(failed_parameter)))] <- .print(X1," and ",Y1," and ",X2," and ",Y2," are not valid integers.").
// Improve this failure to drop disjunction into two different plans
-!disconnect(X1,Y1,X2,Y2)[code(.fail(action(Action),result(failed_target)))] <- .print("Target locations are not attachments, or they are not attached to each other directly").
-!disconnect(X1,Y1,X2,Y2)[code(.fail(action(Action),result(failed_status)))] <- .print("Agent is disabled.").

// ##### REQUEST BLOCK ACTION #####
+!request(Direction)
<-
	!action::commit_action(request(Direction));
	.
-!request(Direction)[code(.fail(action(Action),result(failed_parameter)))] <- .print("Direction ",Direction," is not valid, it should be one of {n,s,e,w}.").
-!request(Direction)[code(.fail(action(Action),result(failed_target)))] <- .print("There is no dispenser in direction ",Direction).
-!request(Direction)[code(.fail(action(Action),result(failed_blocked)))] <- .print("The dispenser is blocked.").
-!request(Direction)[code(.fail(action(Action),result(failed_status)))] <- .print("Agent is disabled.").

// ##### SUBMIT TASK ACTION #####
+!submit(Task)
<-
	!action::commit_action(submit(Task));
	.
-!submit(Task)[code(.fail(action(Action),result(failed_target)))] <- .print("There is no active task named ",Task).
// Improve this failure to drop disjunction into two different plans
-!submit(Task)[code(.fail(action(Action),result(failed)))] <- .print("At least one block is missing, or the agent is not in a goal terrain.").
-!submit(Task)[code(.fail(action(Action),result(failed_status)))] <- .print("Agent is disabled.").

// ##### CLEAR ACTION #####
+!clear(X,Y)
<-
	!action::commit_action(clear(X,Y));
	.
-!clear(X,Y)[code(.fail(action(Action),result(failed_parameter)))] <- .print(X," and ",Y," are not valid integers.").
-!clear(X,Y)[code(.fail(action(Action),result(failed_target)))] <- .print("Target location is not within the agent's vision or outside the grid.").
-!clear(X,Y)[code(.fail(action(Action),result(failed_status)))] <- .print("Energy is too low.").
-!clear(X,Y)[code(.fail(action(Action),result(failed_status)))] <- .print("Agent is disabled.").
