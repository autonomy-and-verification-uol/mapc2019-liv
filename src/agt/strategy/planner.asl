+!generate_goal(GoalX, GoalY, Plan)
	: .my_name(Me)
<-
	getMyPos(MyX, MyY);
	//getTargetGoal(_, GoalX, GoalY, _);
	if(GoalX-MyX <= -5){
		TargetX = -5;
	} elif(GoalX-MyX >= 5){
		TargetX = 5;
	} else {
		TargetX = GoalX-MyX;
	}
	if(GoalY-MyY <= -5){
		TargetY = -5;
	} elif(GoalY-MyY >= 5){
		TargetY = 5;
	} else {
		TargetY = GoalY-MyY;
	}
	Sum = math.abs(TargetX) + math.abs(TargetY);
	if(Sum > 5){
		DeltaX = math.floor((Sum - 5) / 2);
		if(((Sum-5) mod 2) == 0) {
			DeltaY = DeltaX;
		} else {
			DeltaY = DeltaX + 1;	
		}
		if(TargetX > 0){
			FinalTargetX = TargetX - DeltaX;
		} else {
			FinalTargetX = TargetX + DeltaX;
		}
		if(TargetY > 0){
			FinalTargetY = TargetY - DeltaY;
		} else {
			FinalTargetY = TargetY + DeltaY;
		}
	} else {
		FinalTargetX = TargetX;
		FinalTargetY = TargetY;
	}
	.print(FinalTargetX);
	.print(FinalTargetY);
	if (default::energy(Energy) & Energy >= 30) {
		getPlanAgentToGoal(Me, FinalTargetX, FinalTargetY, Plan, true);
	}
	else {
		getPlanAgentToGoal(Me, FinalTargetX, FinalTargetY, Plan, false);
	}
	.print("@@@@@@ Plan: ",Plan);
	.
	
+!execute_plan(Plan)
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
		}
	}
	.