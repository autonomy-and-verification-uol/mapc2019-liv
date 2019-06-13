{ include("reasoning-engine.asl") }

// ##### MOVE NORTH ACTION #####
+!move(Direction)
<-
	!action::commit_action(move(Direction));
	.

