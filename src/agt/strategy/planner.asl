+!generate_goal(0, 0) 
	: (common::my_role(stocker) | common::my_role(retriever)) & retrieve::collect_block
<- 
	!!retrieve::get_block;
	.
+!generate_goal(0, 0)
	: common::my_role(stocker) & .my_name(Me)
<- 
	.wait(not action::move_sent);
	getMyPos(MyX,MyY);
	?retrieve::gate(Gate);
	addStocker(Me, MyX, MyY, Gate);
	+task::stocker_in_position;
	if (retrieve::block(X,Y)) {
		?default::thing(X,Y,block,Type);
		addStockerBlock(Me, Type);
	}
	.send(Ag, tell, task::stocker(Me));
	!!default::always_skip;
	.
+!generate_goal(0, 0) 
	: common::my_role(helper) & .my_name(Me) & stop::first_to_stop(Ag)
<- 
	-moving_to_origin;
	.send(Ag, tell, task::helper(Me));
	!!default::always_skip;
	.
+!generate_goal(0, 0) 
	: .my_name(Me) & stop::first_to_stop(Me)
<- 
	-moving_to_origin;
	+task::origin;
	!!default::always_skip;
	.
+!generate_goal(0, 0) <- !!default::always_skip.
+!generate_goal(TargetX, TargetY)
	: .my_name(Me)
<-
	if(TargetX <= -5){
		LocalTargetX = -5;
	} elif(TargetX >= 5){
		LocalTargetX = 5;
	} else {
		LocalTargetX = TargetX;
	}
	if(TargetY <= -5){
		LocalTargetY = -5;
	} elif(TargetY >= 5){
		LocalTargetY = 5;
	} else {
		LocalTargetY = TargetY;
	}
	Sum = math.abs(LocalTargetX) + math.abs(LocalTargetY);
	if(Sum > 5){
		DeltaX = math.floor((Sum - 5) / 2);
		if(((Sum-5) mod 2) == 0) {
			DeltaY = DeltaX;
		} else {
			DeltaY = DeltaX + 1;	
		}
		if(LocalTargetX > 0){
			FinalLocalTargetX = LocalTargetX - DeltaX;
		} else {
			FinalLocalTargetX = LocalTargetX + DeltaX;
		}
		if(LocalTargetY > 0){
			FinalLocalTargetY = LocalTargetY - DeltaY;
		} else {
			FinalLocalTargetY = LocalTargetY + DeltaY;
		}
	} else {
		FinalLocalTargetX = LocalTargetX;
		FinalLocalTargetY = LocalTargetY;
	}
	.print("Where we'd like to go ", FinalLocalTargetX, ", ", FinalLocalTargetY);
	!generate_actual_goal(FinalLocalTargetX,FinalLocalTargetY,ActualFinalLocalTargetX,ActualFinalLocalTargetY);
	.print("Where we are actually going ", ActualFinalLocalTargetX, ", ", ActualFinalLocalTargetY);
	if (retrieve::block(BlockX,BlockY)) {
		if (default::energy(Energy) & Energy >= 30) {
			getPlanAgentToGoal(Me, ActualFinalLocalTargetX, ActualFinalLocalTargetY, BlockX, BlockY, Plan, true);
		}
		else {
			getPlanAgentToGoal(Me, ActualFinalLocalTargetX, ActualFinalLocalTargetY, BlockX, BlockY, Plan, false);
		}
	}
	else {
		if (default::energy(Energy) & Energy >= 30) {
			getPlanAgentToGoal(Me, ActualFinalLocalTargetX, ActualFinalLocalTargetY, Plan, true);
		}
		else {
			getPlanAgentToGoal(Me, ActualFinalLocalTargetX, ActualFinalLocalTargetY, Plan, false);
		}
	}
	.print("@@@@@@ Plan: ",Plan);
	
	!planner::execute_plan(Plan, TargetX, TargetY, ActualFinalLocalTargetX, ActualFinalLocalTargetY);
	.
	
+!generate_actual_goal(FinalLocalTargetX,FinalLocalTargetY,ActualFinalLocalTargetX,ActualFinalLocalTargetY)
	: not default::thing(FinalLocalTargetX, FinalLocalTargetY, block, _)
<-
	ActualFinalLocalTargetX = FinalLocalTargetX;
	ActualFinalLocalTargetY = FinalLocalTargetY;
	.
+!generate_actual_goal(FinalLocalTargetX,FinalLocalTargetY,ActualFinalLocalTargetX,ActualFinalLocalTargetY)
	: FinalLocalTargetY == 0 
<-
	!generate_actual_goal(0,5,ActualFinalLocalTargetX,ActualFinalLocalTargetY);
	.
+!generate_actual_goal(FinalLocalTargetX,FinalLocalTargetY,ActualFinalLocalTargetX,ActualFinalLocalTargetY)
<-
	!generate_actual_goal_left(FinalLocalTargetX,FinalLocalTargetY,ActualFinalLocalTargetX,ActualFinalLocalTargetY,1);
	.
+!generate_actual_goal_left(FinalLocalTargetX,FinalLocalTargetY,ActualFinalLocalTargetX,ActualFinalLocalTargetY,Counter)
	: FinalLocalTargetY > 0 & Counter < 6 & not default::thing(FinalLocalTargetX+Counter, FinalLocalTargetY-Counter, block, _)
<-
	ActualFinalLocalTargetY = FinalLocalTargetY - Counter;
	ActualFinalLocalTargetX = FinalLocalTargetX + Counter;
	.
+!generate_actual_goal_left(FinalLocalTargetX,FinalLocalTargetY,ActualFinalLocalTargetX,ActualFinalLocalTargetY,Counter)
	: FinalLocalTargetY > 0 & Counter < 6
<-
	!generate_actual_goal_left(FinalLocalTargetX,FinalLocalTargetY,ActualFinalLocalTargetX,ActualFinalLocalTargetY,Counter+1)
	.
+!generate_actual_goal_left(FinalLocalTargetX,FinalLocalTargetY,ActualFinalLocalTargetX,ActualFinalLocalTargetY,Counter)
	: FinalLocalTargetY > 0 & Counter == 6
<- 
	!generate_actual_goal_right(FinalLocalTargetX,FinalLocalTargetY,ActualFinalLocalTargetX,ActualFinalLocalTargetY,1);
	.
+!generate_actual_goal_left(FinalLocalTargetX,FinalLocalTargetY,ActualFinalLocalTargetX,ActualFinalLocalTargetY,Counter)
	: FinalLocalTargetY < 0 & Counter < 6 & not default::thing(FinalLocalTargetX+Counter, FinalLocalTargetY+Counter, block, _)
<-
	ActualFinalLocalTargetY = FinalLocalTargetY + Counter;
	ActualFinalLocalTargetX = FinalLocalTargetX + Counter;
	.
+!generate_actual_goal_left(FinalLocalTargetX,FinalLocalTargetY,ActualFinalLocalTargetX,ActualFinalLocalTargetY,Counter)
	: FinalLocalTargetY < 0 & Counter < 6
<-
	!generate_actual_goal_left(FinalLocalTargetX,FinalLocalTargetY,ActualFinalLocalTargetX,ActualFinalLocalTargetY,Counter+1)
	.
+!generate_actual_goal_left(FinalLocalTargetX,FinalLocalTargetY,ActualFinalLocalTargetX,ActualFinalLocalTargetY,Counter)
	: FinalLocalTargetY < 0 & Counter == 6
<- 
	!generate_actual_goal_right(FinalLocalTargetX,FinalLocalTargetY,ActualFinalLocalTargetX,ActualFinalLocalTargetY,1);
	.
+!generate_actual_goal_right(FinalLocalTargetX,FinalLocalTargetY,ActualFinalLocalTargetX,ActualFinalLocalTargetY,Counter)
	: FinalLocalTargetY > 0 & Counter < 6 & not default::thing(FinalLocalTargetX-Counter, FinalLocalTargetY-Counter, block, _)
<-
	ActualFinalLocalTargetY = FinalLocalTargetY - Counter;
	ActualFinalLocalTargetX = FinalLocalTargetX - Counter;
	.
+!generate_actual_goal_right(FinalLocalTargetX,FinalLocalTargetY,ActualFinalLocalTargetX,ActualFinalLocalTargetY,Counter)
	: FinalLocalTargetY > 0 & Counter < 6
<-
	!generate_actual_goal_right(FinalLocalTargetX,FinalLocalTargetY,ActualFinalLocalTargetX,ActualFinalLocalTargetY,Counter+1)
	.
+!generate_actual_goal_right(FinalLocalTargetX,FinalLocalTargetY,ActualFinalLocalTargetX,ActualFinalLocalTargetY,Counter)
	: FinalLocalTargetY < 0 & Counter < 6 & not default::thing(FinalLocalTargetX-Counter, FinalLocalTargetY+Counter, block, _)
<-
	ActualFinalLocalTargetY = FinalLocalTargetY + Counter;
	ActualFinalLocalTargetX = FinalLocalTargetX - Counter;
	.
+!generate_actual_goal_right(FinalLocalTargetX,FinalLocalTargetY,ActualFinalLocalTargetX,ActualFinalLocalTargetY,Counter)
	: FinalLocalTargetY < 0 & Counter < 6
<-
	!generate_actual_goal_right(FinalLocalTargetX,FinalLocalTargetY,ActualFinalLocalTargetX,ActualFinalLocalTargetY,Counter+1)
	.
+!generate_actual_goal_right(FinalLocalTargetX,FinalLocalTargetY,ActualFinalLocalTargetX,ActualFinalLocalTargetY,Counter)
	: Counter == 6
<- 
	.print("Fabio was wrong!!!!");
	.
	
+!execute_plan([], TargetX, TargetY, LocalTargetX, LocalTargetY)
<-
	!action::skip;
	!generate_goal(TargetX, TargetY);
	.
	
+!execute_plan(Plan, TargetX, TargetY, LocalTargetX, LocalTargetY)
<-
	+localtargetx(LocalTargetX);
	+localtargety(LocalTargetY);
	for (.member(Action, Plan)){
		if (.substring("clear",Action)) {
			for(.range(I, 1, 3)){
				.print("@@@@ Action: ", Action);
				!action::Action;
			}
		}
		else {
			.print("@@@@ Action: ", Action);
			!action::Action;
			if (default::lastAction(move) & not default::lastActionResult(success) & default::lastActionParams([Direction|List])) {
				if ( Direction == n & planner::localtargety(LocalTargetYAux) ) {
					-+localtargety(LocalTargetYAux + 1);
				}
				elif (Direction == s & planner::localtargety(LocalTargetYAux) ) {
					-+localtargety(LocalTargetYAux - 1);
				}
				elif (Direction == w  & planner::localtargetx(LocalTargetXAux) ) {
					-+localtargetx(LocalTargetXAux + 1);
				}
				elif (Direction == e & planner::localtargetx(LocalTargetXAux) ) {
					-+localtargetx(LocalTargetXAux - 1);
				}
			}
		}
	}
	?localtargetx(FinalLocalTargetX);
	?localtargety(FinalLocalTargetY);
	-localtargetx(FinalLocalTargetX);
	-localtargety(FinalLocalTargetY);
	!generate_goal(TargetX - FinalLocalTargetX, TargetY - FinalLocalTargetY);
	.