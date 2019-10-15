+!generate_goal(0, 0, Aux) 
	: common::my_role(retriever) & retrieve::collect_block(_,_)
<- 
	!!retrieve::get_block;
	.
	
+!generate_goal(0, 0, Aux) 
	: common::my_role(retriever) & back_to_origin & .my_name(Me) & retrieve::block(BlockX,BlockY) & not retrieve::getting_to_position
<- 
	if (default::energy(Energy) & Energy >= 30) {
		Clear = 1;
	}
	else {
		Clear = 0;
	}
	if (Aux == notblock) {
		callPlanner(Flag);
		!try_call_planner(Flag);
	}
	getPlanBlockToGoal(Me, 0, 0, BlockX, BlockY, Plan, Clear);
	plannerDone;
	.print("@@@@@@ Plan get plan block to goal: ",Plan);
	!planner::execute_plan(Plan, 0, 0, 0, 0);
	-back_to_origin;
	.
	
+!generate_goal(0, 0, Aux) 
	: common::my_role(retriever) & .my_name(Me) & retrieve::block(X,Y) & default::thing(X,Y,block,Type)
<- 
	addAvailableAgent(Me,Type);
	-retrieve::getting_to_position;
	+back_to_origin;
	!!default::always_skip;
	.
	
+!generate_goal(0, 0, Aux) 
	: common::my_role(origin)
<- 
	-retrieve::moving_to_origin;
	+task::origin;
	!!default::always_skip;
	.
+!generate_goal(0, 0, Aux)  : common::my_role(retriever).
+!generate_goal(0, 0, Aux)  : common::my_role(explorer).
//+!generate_goal(0, 0) <- !!default::always_skip.
+!generate_goal(TargetX, TargetY, Aux)
	: .my_name(Me)
<-
	.print("Start of the planner");
	if (Aux == notblock) {
		callPlanner(Flag);
		!try_call_planner(Flag);
	}

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
	if (task::doing_task) {
		ActualFinalLocalTargetX = FinalLocalTargetX;
		ActualFinalLocalTargetY = FinalLocalTargetY;
		FinalTargetX = TargetX;
		FinalTargetY = TargetY;
	}
	elif (math.abs(TargetX) + math.abs(TargetY) > 3) {
		.print("Target is distance 4 or more away.");
		!generate_actual_goal(FinalLocalTargetX,FinalLocalTargetY,ActualFinalLocalTargetX,ActualFinalLocalTargetY);
		FinalTargetX = TargetX;
		FinalTargetY = TargetY;
	}
	else {
		if (not (default::thing(FinalLocalTargetX, FinalLocalTargetY, Type, _) & (Type == block | Type == entity))) {
			ActualFinalLocalTargetX = FinalLocalTargetX;
			ActualFinalLocalTargetY = FinalLocalTargetY;
			FinalTargetX = TargetX;
			FinalTargetY = TargetY;
		}
		else {
			!action::skip;
			if (not (default::thing(FinalLocalTargetX, FinalLocalTargetY, Type2, _) & (Type2 == block | Type2 == entity))) {
				ActualFinalLocalTargetX = FinalLocalTargetX;
				ActualFinalLocalTargetY = FinalLocalTargetY;
				FinalTargetX = TargetX;
				FinalTargetY = TargetY;
			}
			else {
				if (common::my_role(retriever) & retrieve::collect_block(AddX,AddY)) {
					-retrieve::collect_block(AddX,AddY);
					if (default::thing(FinalLocalTargetX+AddX,FinalLocalTargetY+AddY,dispenser,_)) {
						if (AddX == -1) {
							if (not (default::thing(FinalLocalTargetX-2, FinalLocalTargetY, Type, _) & (Type == block | Type == entity))) {
								+retrieve::collect_block(-1,0);
								FinalTargetX = FinalLocalTargetX-2;
								FinalTargetY = FinalLocalTargetY;
								ActualFinalLocalTargetX = FinalLocalTargetX-2;
								ActualFinalLocalTargetY = FinalLocalTargetY;
							}
							elif (not (default::thing(FinalLocalTargetX-1, FinalLocalTargetY+1, Type, _) & (Type == block | Type == entity))) {
								+retrieve::collect_block(0,1);
								FinalTargetX = FinalLocalTargetX-1;
								FinalTargetY = FinalLocalTargetY+1;
								ActualFinalLocalTargetX = FinalLocalTargetX-1;
								ActualFinalLocalTargetY = FinalLocalTargetY+1;
							}
							elif (not (default::thing(FinalLocalTargetX-1, FinalLocalTargetY-1, Type, _) & (Type == block | Type == entity))) {
								+retrieve::collect_block(0,-1);
								FinalTargetX = FinalLocalTargetX-1;
								FinalTargetY = FinalLocalTargetY-1;
								ActualFinalLocalTargetX = FinalLocalTargetX-1;
								ActualFinalLocalTargetY = FinalLocalTargetY-1;
							}
							else {
								.fail(impossible_dispenser(FinalLocalTargetX+AddX,FinalLocalTargetY+AddY));
							}
						}
						elif (AddX == 1) {
							if (not (default::thing(FinalLocalTargetX+2, FinalLocalTargetY, Type, _) & (Type == block | Type == entity))) {
								+retrieve::collect_block(1,0);
								FinalTargetX = FinalLocalTargetX+2;
								FinalTargetY = FinalLocalTargetY;
								ActualFinalLocalTargetX = FinalLocalTargetX+2;
								ActualFinalLocalTargetY = FinalLocalTargetY;
							}
							elif (not (default::thing(FinalLocalTargetX+1, FinalLocalTargetY+1, Type, _) & (Type == block | Type == entity))) {
								+retrieve::collect_block(0,1);
								FinalTargetX = FinalLocalTargetX+1;
								FinalTargetY = FinalLocalTargetY+1;
								ActualFinalLocalTargetX = FinalLocalTargetX+1;
								ActualFinalLocalTargetY = FinalLocalTargetY+1;
							}
							elif (not (default::thing(FinalLocalTargetX+1, FinalLocalTargetY-1, Type, _) & (Type == block | Type == entity))) {
								+retrieve::collect_block(0,-1);
								FinalTargetX = FinalLocalTargetX+1;
								FinalTargetY = FinalLocalTargetY-1;
								ActualFinalLocalTargetX = FinalLocalTargetX+1;
								ActualFinalLocalTargetY = FinalLocalTargetY-1;
							}
							else {
								.fail(impossible_dispenser(FinalLocalTargetX+AddX,FinalLocalTargetY+AddY));
							}
						}
						elif (AddY == 1) {
							if (not (default::thing(FinalLocalTargetX, FinalLocalTargetY+2, Type, _) & (Type == block | Type == entity))) {
								+retrieve::collect_block(0,1);
								FinalTargetX = FinalLocalTargetX;
								FinalTargetY = FinalLocalTargetY+2;
								ActualFinalLocalTargetX = FinalLocalTargetX;
								ActualFinalLocalTargetY = FinalLocalTargetY+2;
							}
							elif (not (default::thing(FinalLocalTargetX+1, FinalLocalTargetY+1, Type, _) & (Type == block | Type == entity))) {
								+retrieve::collect_block(1,0);
								FinalTargetX = FinalLocalTargetX+1;
								FinalTargetY = FinalLocalTargetY+1;
								ActualFinalLocalTargetX = FinalLocalTargetX+1;
								ActualFinalLocalTargetY = FinalLocalTargetY+1;
							}
							elif (not (default::thing(FinalLocalTargetX-1, FinalLocalTargetY+1, Type, _) & (Type == block | Type == entity))) {
								+retrieve::collect_block(-1,0);
								FinalTargetX = FinalLocalTargetX-1;
								FinalTargetY = FinalLocalTargetY+1;
								ActualFinalLocalTargetX = FinalLocalTargetX-1;
								ActualFinalLocalTargetY = FinalLocalTargetY+1;
							}
							else {
								.fail(impossible_dispenser(FinalLocalTargetX+AddX,FinalLocalTargetY+AddY));
							}
						}
						elif (AddY == -1) {
							if (not (default::thing(FinalLocalTargetX, FinalLocalTargetY-2, Type, _) & (Type == block | Type == entity))) {
								+retrieve::collect_block(0,-1);
								FinalTargetX = FinalLocalTargetX;
								FinalTargetY = FinalLocalTargetY-2;
								ActualFinalLocalTargetX = FinalLocalTargetX;
								ActualFinalLocalTargetY = FinalLocalTargetY-2;
							}
							elif (not (default::thing(FinalLocalTargetX+1, FinalLocalTargetY-1, Type, _) & (Type == block | Type == entity))) {
								+retrieve::collect_block(1,0);
								FinalTargetX = FinalLocalTargetX+1;
								FinalTargetY = FinalLocalTargetY-1;
								ActualFinalLocalTargetX = FinalLocalTargetX+1;
								ActualFinalLocalTargetY = FinalLocalTargetY-1;
							}
							elif (not (default::thing(FinalLocalTargetX-1, FinalLocalTargetY-1, Type, _) & (Type == block | Type == entity))) {
								+retrieve::collect_block(-1,0);
								FinalTargetX = FinalLocalTargetX-1;
								FinalTargetY = FinalLocalTargetY-1;
								ActualFinalLocalTargetX = FinalLocalTargetX-1;
								ActualFinalLocalTargetY = FinalLocalTargetY-1;
							}
							else {
								.fail(impossible_dispenser(FinalLocalTargetX+AddX,FinalLocalTargetY+AddY));
							}
						}
					}
					else {
						.fail(impossible_dispenser(FinalLocalTargetX+AddX,FinalLocalTargetY+AddY));
					}
				}
				else {
					!generate_actual_goal(FinalLocalTargetX,FinalLocalTargetY,ActualFinalLocalTargetX,ActualFinalLocalTargetY);
					FinalTargetX = ActualFinalLocalTargetX;
					FinalTargetY = ActualFinalLocalTargetY;
				}
			}
		}
	}
	.print("Where we are actually going ", ActualFinalLocalTargetX, ", ", ActualFinalLocalTargetY);
	if (default::energy(Energy) & Energy >= 30) {
		Clear = 1;
	}
	else {
		Clear = 0;
	}
//	if (planner::back_to_origin & retrieve::block(BlockX,BlockY)) {
////		if (math.abs(TargetX) + math.abs(TargetY) <= 5 & ActualFinalLocalTargetX == FinalLocalTargetX & ActualFinalLocalTargetY == FinalLocalTargetY & dumb_bugfix) {
////			getPlanBlockToGoal(Me, ActualFinalLocalTargetX, ActualFinalLocalTargetY, BlockX, BlockY, Plan, Clear);
////		}
////		else {
//		getPlanAgentToGoal(Me, ActualFinalLocalTargetX, ActualFinalLocalTargetY, BlockX, BlockY, Plan, Clear);
////		}
//	}
	if (retrieve::block(BlockX,BlockY)) {
		getPlanAgentToGoal(Me, ActualFinalLocalTargetX, ActualFinalLocalTargetY, BlockX, BlockY, Plan, Clear);
	}
	else {
		getPlanAgentToGoal(Me, ActualFinalLocalTargetX, ActualFinalLocalTargetY, Plan, Clear);
	}
	plannerDone;
	.print("@@@@@@ Plan: ",Plan);
	!planner::execute_plan(Plan, FinalTargetX, FinalTargetY, ActualFinalLocalTargetX, ActualFinalLocalTargetY);
	.

-!generate_goal(TargetX, TargetY, Aux)[code(.fail(goal_blocked))]
<-
	plannerDone;
	!execute_plan([], TargetX, TargetY, TargetX, TargetY);
	.
-!generate_goal(TargetX, TargetY, Aux)[code(.fail(impossible_dispenser(FinalLocalTargetX,FinalLocalTargetY)))]
	: .my_name(Me)
<-
	plannerDone;
	removeBlock(Me);
	getMyPos(MyX, MyY);
	DispX = MyX + FinalLocalTargetX;
	DispY = MyY + FinalLocalTargetY;
	+retrieve::minus_one(DispX,DispY);
	!!retrieve::retrieve_block;
	.
	
+!try_call_planner(true).
+!try_call_planner(false)
<-
	!action::skip;
	callPlanner(Flag);
	!try_call_planner(Flag);
	.
	
+!generate_actual_goal(FinalLocalTargetX,FinalLocalTargetY,ActualFinalLocalTargetX,ActualFinalLocalTargetY)
	: not (default::thing(FinalLocalTargetX, FinalLocalTargetY, Type, _) & (Type == block | Type == entity))
<-
	ActualFinalLocalTargetX = FinalLocalTargetX;
	ActualFinalLocalTargetY = FinalLocalTargetY;
	.
// 5 0 
+!generate_actual_goal(FinalLocalTargetX,FinalLocalTargetY,ActualFinalLocalTargetX,ActualFinalLocalTargetY)
	: FinalLocalTargetY == 0 & FinalLocalTargetX == 5 & not (default::thing(FinalLocalTargetX-1, FinalLocalTargetY, Type, _) & (Type == block | Type == entity))
<-
	ActualFinalLocalTargetX = FinalLocalTargetX-1;
	ActualFinalLocalTargetY = FinalLocalTargetY;
	.
+!generate_actual_goal(FinalLocalTargetX,FinalLocalTargetY,ActualFinalLocalTargetX,ActualFinalLocalTargetY)
	: FinalLocalTargetY == 0 & FinalLocalTargetX == 5 & not (default::thing(FinalLocalTargetX-1, FinalLocalTargetY-1, Type, _) & (Type == block | Type == entity))
<-
	ActualFinalLocalTargetX = FinalLocalTargetX-1;
	ActualFinalLocalTargetY = FinalLocalTargetY-1;
	.
+!generate_actual_goal(FinalLocalTargetX,FinalLocalTargetY,ActualFinalLocalTargetX,ActualFinalLocalTargetY)
	: FinalLocalTargetY == 0 & FinalLocalTargetX == 5 & not (default::thing(FinalLocalTargetX-1, FinalLocalTargetY+1, Type, _) & (Type == block | Type == entity))
<-
	ActualFinalLocalTargetX = FinalLocalTargetX-1;
	ActualFinalLocalTargetY = FinalLocalTargetY+1;
	.
+!generate_actual_goal(FinalLocalTargetX,FinalLocalTargetY,ActualFinalLocalTargetX,ActualFinalLocalTargetY)
<-
	.fail(goal_blocked).
// -5 0 
+!generate_actual_goal(FinalLocalTargetX,FinalLocalTargetY,ActualFinalLocalTargetX,ActualFinalLocalTargetY)
	: FinalLocalTargetY == 0 & FinalLocalTargetX == -5 & not (default::thing(FinalLocalTargetX+1, FinalLocalTargetY, Type, _) & (Type == block | Type == entity))
<-
	ActualFinalLocalTargetX = FinalLocalTargetX+1;
	ActualFinalLocalTargetY = FinalLocalTargetY;
	.
+!generate_actual_goal(FinalLocalTargetX,FinalLocalTargetY,ActualFinalLocalTargetX,ActualFinalLocalTargetY)
	: FinalLocalTargetY == 0 & FinalLocalTargetX == -5 & not (default::thing(FinalLocalTargetX+1, FinalLocalTargetY-1, Type, _) & (Type == block | Type == entity))
<-
	ActualFinalLocalTargetX = FinalLocalTargetX+1;
	ActualFinalLocalTargetY = FinalLocalTargetY-1;
	.
+!generate_actual_goal(FinalLocalTargetX,FinalLocalTargetY,ActualFinalLocalTargetX,ActualFinalLocalTargetY)
	: FinalLocalTargetY == 0 & FinalLocalTargetX == -5 & not (default::thing(FinalLocalTargetX+1, FinalLocalTargetY+1, Type, _) & (Type == block | Type == entity))
<-
	ActualFinalLocalTargetX = FinalLocalTargetX+1;
	ActualFinalLocalTargetY = FinalLocalTargetY+1;
	.
+!generate_actual_goal(FinalLocalTargetX,FinalLocalTargetY,ActualFinalLocalTargetX,ActualFinalLocalTargetY)
<-
	.fail(goal_blocked).
// 0 -5
+!generate_actual_goal(FinalLocalTargetX,FinalLocalTargetY,ActualFinalLocalTargetX,ActualFinalLocalTargetY)
	: FinalLocalTargetY == -5 & FinalLocalTargetX == 0 & not (default::thing(FinalLocalTargetX, FinalLocalTargetY+1, Type, _) & (Type == block | Type == entity))
<-
	ActualFinalLocalTargetX = FinalLocalTargetX;
	ActualFinalLocalTargetY = FinalLocalTargetY+1;
	.
+!generate_actual_goal(FinalLocalTargetX,FinalLocalTargetY,ActualFinalLocalTargetX,ActualFinalLocalTargetY)
	: FinalLocalTargetY == -5 & FinalLocalTargetX == 0 & not (default::thing(FinalLocalTargetX-1, FinalLocalTargetY+1, Type, _) & (Type == block | Type == entity))
<-
	ActualFinalLocalTargetX = FinalLocalTargetX-1;
	ActualFinalLocalTargetY = FinalLocalTargetY+1;
	.
+!generate_actual_goal(FinalLocalTargetX,FinalLocalTargetY,ActualFinalLocalTargetX,ActualFinalLocalTargetY)
	: FinalLocalTargetY == -5 & FinalLocalTargetX == 0 & not (default::thing(FinalLocalTargetX+1, FinalLocalTargetY+1, Type, _) & (Type == block | Type == entity))
<-
	ActualFinalLocalTargetX = FinalLocalTargetX+1;
	ActualFinalLocalTargetY = FinalLocalTargetY+1;
	.
+!generate_actual_goal(FinalLocalTargetX,FinalLocalTargetY,ActualFinalLocalTargetX,ActualFinalLocalTargetY)
<-
	.fail(goal_blocked).
// 0 5
+!generate_actual_goal(FinalLocalTargetX,FinalLocalTargetY,ActualFinalLocalTargetX,ActualFinalLocalTargetY)
	: FinalLocalTargetY == 5 & FinalLocalTargetX == 0 & not (default::thing(FinalLocalTargetX, FinalLocalTargetY-1, Type, _) & (Type == block | Type == entity))
<-
	ActualFinalLocalTargetX = FinalLocalTargetX;
	ActualFinalLocalTargetY = FinalLocalTargetY-1;
	.
+!generate_actual_goal(FinalLocalTargetX,FinalLocalTargetY,ActualFinalLocalTargetX,ActualFinalLocalTargetY)
	: FinalLocalTargetY == 5 & FinalLocalTargetX == 0 & not (default::thing(FinalLocalTargetX-1, FinalLocalTargetY-1, Type, _) & (Type == block | Type == entity))
<-
	ActualFinalLocalTargetX = FinalLocalTargetX-1;
	ActualFinalLocalTargetY = FinalLocalTargetY-1;
	.
+!generate_actual_goal(FinalLocalTargetX,FinalLocalTargetY,ActualFinalLocalTargetX,ActualFinalLocalTargetY)
	: FinalLocalTargetY == 5 & FinalLocalTargetX == 0 & not (default::thing(FinalLocalTargetX+1, FinalLocalTargetY-1, Type, _) & (Type == block | Type == entity))
<-
	ActualFinalLocalTargetX = FinalLocalTargetX+1;
	ActualFinalLocalTargetY = FinalLocalTargetY-1;
	.
+!generate_actual_goal(FinalLocalTargetX,FinalLocalTargetY,ActualFinalLocalTargetX,ActualFinalLocalTargetY)
<-
	.fail(goal_blocked).
// All other cases will call the closest of the cases above
// The important assumption here is that the goal is not in vision!
+!generate_actual_goal(FinalLocalTargetX,FinalLocalTargetY,ActualFinalLocalTargetX,ActualFinalLocalTargetY)
	: math.abs(FinalLocalTargetY) < math.abs(FinalLocalTargetX) & FinalLocalTargetX > 0
<-
	!generate_actual_goal(5,0,ActualFinalLocalTargetX,ActualFinalLocalTargetY)
	.
+!generate_actual_goal(FinalLocalTargetX,FinalLocalTargetY,ActualFinalLocalTargetX,ActualFinalLocalTargetY)
	: math.abs(FinalLocalTargetY) < math.abs(FinalLocalTargetX) & FinalLocalTargetX < 0
<-
	!generate_actual_goal(-5,0,ActualFinalLocalTargetX,ActualFinalLocalTargetY)
	.
+!generate_actual_goal(FinalLocalTargetX,FinalLocalTargetY,ActualFinalLocalTargetX,ActualFinalLocalTargetY)
	: math.abs(FinalLocalTargetY) > math.abs(FinalLocalTargetX) & FinalLocalTargetY > 0
<-
	!generate_actual_goal(0,5,ActualFinalLocalTargetX,ActualFinalLocalTargetY)
	.
+!generate_actual_goal(FinalLocalTargetX,FinalLocalTargetY,ActualFinalLocalTargetX,ActualFinalLocalTargetY)
	: math.abs(FinalLocalTargetY) > math.abs(FinalLocalTargetX) & FinalLocalTargetY < 0
<-
	!generate_actual_goal(0,-5,ActualFinalLocalTargetX,ActualFinalLocalTargetY)
	.



+!execute_plan(Plan, 0, 0, 0, 0)
	: back_to_origin
<-
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
			while (not default::lastActionResult(success)) {
				!action::Action;
			}
		}
	}
	.
	
+!execute_plan([], TargetX, TargetY, LocalTargetX, LocalTargetY) :
	LocalTargetX < 0 & not (default::thing(-1, 0, Type, _) & (Type == block | Type == entity)) & not (default::obstacle(-1,0)) 
<-
	!action::move(w);
	.print("Execute empty plan by moving west");
	if (default::lastActionResult(success)) {
		!generate_goal(TargetX + 1, TargetY, notblock);
	} else {
		!generate_goal(TargetX, TargetY, notblock);
	}
	.
	
+!execute_plan([], TargetX, TargetY, LocalTargetX, LocalTargetY) :
	LocalTargetX > 0 & not (default::thing(1, 0, Type, _)  & (Type == block | Type == entity)) & not (default::obstacle(1,0))
<-	
	!action::move(e);
	.print("Execute empty plan by moving east");
	if (default::lastActionResult(success)) {
		!generate_goal(TargetX - 1, TargetY, notblock);
	} else {
		!generate_goal(TargetX, TargetY, notblock);
	}
	.
	
+!execute_plan([], TargetX, TargetY, LocalTargetX, LocalTargetY) :
	LocalTargetY < 0 & not (default::thing(0, -1, Type, _)  & (Type == block | Type == entity)) & not (default::obstacle(0, -1))
<-	
	!action::move(n);
	.print("Execute empty plan by moving north");
	if (default::lastActionResult(success)) {
		!generate_goal(TargetX, TargetY + 1, notblock);
	} else {
		!generate_goal(TargetX, TargetY, notblock);
	}
	.

+!execute_plan([], TargetX, TargetY, LocalTargetX, LocalTargetY) :
	LocalTargetY > 0 & not (default::thing(0, 1, Type, _)  & (Type == block | Type == entity)) & not (default::obstacle(0, 1))
<-		
	!action::move(s);
	.print("Execute empty plan by moving south");
	if (default::lastActionResult(success)) {
		!generate_goal(TargetX, TargetY - 1, notblock);
	} else {
		!generate_goal(TargetX, TargetY, notblock);
	}
	.
// If all the above failed, then try to move in the opposite direction of the goal
// All the following plans will miserably fail if the only possible direction is the one with the attached block...
// Rafael, you might know how to deal with this.

// I'd like to go east, but I'm giving up and going west
+!execute_plan([], TargetX, TargetY, LocalTargetX, LocalTargetY) :
	LocalTargetX > 0 & (not (default::thing(-1, 0, Type, _)  & (Type == block | Type == entity)) | retrieve::block(-1,0)) & not (default::obstacle(-1, 0))
<-		
	!action::move(w);
	.print("Try to find a plan after moving west -- away from goal!");
	if (default::lastActionResult(success)) {
		!generate_goal(TargetX-1, TargetY, notblock);
	} else {
		!generate_goal(TargetX, TargetY, notblock);
	}
	.
// I'd like to go west, but I'm giving up and going east
+!execute_plan([], TargetX, TargetY, LocalTargetX, LocalTargetY) :
	LocalTargetX < 0 & (not (default::thing(1, 0, Type, _)  & (Type == block | Type == entity)) | retrieve::block(1,0)) & not (default::obstacle(1, 0))
<-		
	!action::move(e);
	.print("Try to find a plan after moving east -- away from goal!");
	if (default::lastActionResult(success)) {
		!generate_goal(TargetX+1, TargetY, notblock);
	} else {
		!generate_goal(TargetX, TargetY, notblock);
	}
	.
// I'd like to go south, but I'm giving up and going north
+!execute_plan([], TargetX, TargetY, LocalTargetX, LocalTargetY) :
	LocalTargetY > 0 & (not (default::thing(0, -1, Type, _)  & (Type == block | Type == entity)) | retrieve::block(0,-1)) & not (default::obstacle(0, -1))
<-		
	!action::move(n);
	.print("Try to find a plan after moving north -- away from goal!");
	if (default::lastActionResult(success)) {
		!generate_goal(TargetX, TargetY - 1, notblock);
	} else {
		!generate_goal(TargetX, TargetY, notblock);
	}
	.
// I'd like to go north, but I'm giving up and going south
+!execute_plan([], TargetX, TargetY, LocalTargetX, LocalTargetY) :
	LocalTargetY < 0 & (not (default::thing(0, 1, Type, _)  & (Type == block | Type == entity)) | retrieve::block(0,1)) & not (default::obstacle(0, 1))
<-		
	!action::move(s);
	.print("Try to find a plan after moving south -- away from goal!");
	if (default::lastActionResult(success)) {
		!generate_goal(TargetX, TargetY + 1, notblock);
	} else {
		!generate_goal(TargetX, TargetY, notblock);
	}
	.
// We are screwed
+!execute_plan([], TargetX, TargetY, LocalTargetX, LocalTargetY) 
<-
	.print("No trivial solution to the empty plan, OBSTACLES EVERYWHERE!");
	!action::skip;
	!generate_goal(TargetX, TargetY, notblock);
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
			if (common::my_role(retriever) & retrieve::getting_to_position & not retrieve::block(X,Y)) {
				?localtargetx(RemoveLocalTargetX);
				?localtargety(RemoveLocalTargetY);
				-localtargetx(RemoveLocalTargetX);
				-localtargety(LocalTargetY);
				.fail;
			}
			if (default::lastAction(move) & not (default::lastActionResult(success)) & default::lastActionParams([Direction|List])) {
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
	.print("Next relative target X ",TargetX - FinalLocalTargetX," Y ",TargetY - FinalLocalTargetY);
	!generate_goal(TargetX - FinalLocalTargetX, TargetY - FinalLocalTargetY, notblock);
	.

-!execute_plan(Plan, TargetX, TargetY, LocalTargetX, LocalTargetY)
	: common::my_role(retriever) & retrieve::getting_to_position & .my_name(Me)
<-
	-retrieve::getting_to_position;
	//getAvailableMeType(Me, Type);
	removeBlock(Me);
	!!retrieve::retrieve_block;
	.
	