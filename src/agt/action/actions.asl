{ include("reasoning-engine.asl") }

// ##### MOVE ACTION #####
+!move(Direction)
<-
	!action::commit_action(move(Direction));
	.
-!move(Direction)[code(.fail(action(Action),result(failed_parameter)))] <- .print("Direction ",Direction," is not valid, it should be one of {n,s,e,w}.").
// Improve this failure to drop disjunction into two different plans
-!move(Direction)[code(.fail(action(Action),result(failed_path)))] <- .print("Destination is blocked, or one of my attached things is blocking.").	

// ##### ATTACH BLOCK ACTION #####
+!attach(Direction)
<-
	!action::commit_action(attach(Direction));
	.
-!attach(Direction)[code(.fail(action(Action),result(failed_parameter)))] <- .print("Direction ",Direction," is not valid, it should be one of {n,s,e,w}.").
-!attach(Direction)[code(.fail(action(Action),result(failed_target)))] <- .print("There is nothing to attach in direction ",Direction).
// Improve this failure to drop disjunction into two different plans
-!attach(Direction)[code(.fail(action(Action),result(failed)))] <- .print("Too many things attached, or it is already attached to an opponent.").

// ##### ATTACH BLOCK ACTION #####
+!detach(Direction)
<-
	!action::commit_action(detach(Direction));
	.
-!detach(Direction)[code(.fail(action(Action),result(failed_parameter)))] <- .print("Direction ",Direction," is not valid, it should be one of {n,s,e,w}.").
-!detach(Direction)[code(.fail(action(Action),result(failed_target)))] <- .print("There is nothing to detach in direction ",Direction).
-!detach(Direction)[code(.fail(action(Action),result(failed)))] <- .print("The thing can't be detached because it is not attached.").

// ##### ROTATE ACTION #####
+!rotate(Direction)
<-
	!action::commit_action(rotate(Direction));
	.
-!rotate(Direction)[code(.fail(action(Action),result(failed_parameter)))] <- .print("Rotation ",Direction," is not valid, it should be one of {cw,cww}.").
// Improve this failure to drop disjunction into two different plans
-!rotate(Direction)[code(.fail(action(Action),result(failed)))] <- .print("One of the things attached cannot rotate, or the agent is attached to another agent.").

// ##### CONNECT ACTION #####
+!connect(Agent,X,Y)
<-
	!action::commit_action(connect(Agent,X,Y));
	.
// Improve this failure to drop disjunction into two different plans
-!connect(Agent,X,Y)[code(.fail(action(Action),result(failed_parameter)))] <- .print(Agent," is not in our team, or ",X," and ",Y," are not valid integers.").
// Improve this failure to drop disjunction into two different plans
-!connect(Agent,X,Y)[code(.fail(action(Action),result(failed_partner)))] <- .print("The other agent didn't send connect action, or failed randomly, or it had wrong parameters.").
// Improve this failure to drop disjunction into two different plans
-!connect(Agent,X,Y)[code(.fail(action(Action),result(failed_target)))] <- .print("No blocks at given position, or not attached to the agent, or already attached to the other agent").
// Improve this failure to drop disjunction into two different plans
-!connect(Agent,X,Y)[code(.fail(action(Action),result(failed)))] <- .print("Position is too far, or agents are already connected, or violates the attach limit.").

// ##### REQUEST BLOCK ACTION #####
+!request(Direction)
<-
	!action::commit_action(request(Direction));
	.
-!request(Direction)[code(.fail(action(Action),result(failed_parameter)))] <- .print("Direction ",Direction," is not valid, it should be one of {n,s,e,w}.").
-!request(Direction)[code(.fail(action(Action),result(failed_target)))] <- .print("There is no dispenser in direction ",Direction).
-!request(Direction)[code(.fail(action(Action),result(failed_blocked)))] <- .print("The dispenser is blocked.").

// ##### SUBMIT TASK ACTION #####
+!submit(Task)
<-
	!action::commit_action(submit(Task));
	.
-!submit(Task)[code(.fail(action(Action),result(failed_target)))] <- .print("There is no active task named ",Task).
// Improve this failure to drop disjunction into two different plans
-!submit(Task)[code(.fail(action(Action),result(failed)))] <- .print("At least one block is missing, or the agent is not in a goal terrain.").

// ##### CLEAR ACTION #####
+!clear(X,Y)
<-
	!action::commit_action(clear(X,Y));
	.
-!clear(X,Y)[code(.fail(action(Action),result(failed_parameter)))] <- .print(X," and ",Y," are not valid integers.").
-!clear(X,Y)[code(.fail(action(Action),result(failed_target)))] <- .print("Target location is not within the agent's vision or outside the grid.").
-!clear(X,Y)[code(.fail(action(Action),result(failed_status)))] <- .print("Energy is too low.").
