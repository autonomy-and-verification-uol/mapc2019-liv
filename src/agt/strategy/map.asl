check_stuck([]) :- false.
check_stuck([obstacle(X,Y)|ObsList]) :- (default::obstacle(X-1,Y) & check_path(X,Y,X-1,Y,X,Y)) | (default::obstacle(X-1,Y-1) & check_path(X,Y,X-1,Y-1,X,Y)) | (default::obstacle(X-1,Y+1) & check_path(X,Y,X-1,Y+1,X,Y)) | (default::obstacle(X,Y-1) & check_path(X,Y,X,Y-1,X,Y)) | (default::obstacle(X,Y+1) & check_path(X,Y,X,Y+1,X,Y)) | (default::obstacle(X+1,Y) & check_path(X,Y,X+1,Y,X,Y)) | (default::obstacle(X+1,Y-1) & check_path(X,Y,X+1,Y-1,X,Y)) | (default::obstacle(X+1,Y+1) & check_path(X,Y,X+1,Y+1,X,Y)).

check_path(XOld,YOld,XFirst,YFirst,XFirst,YFirst) :- true.
check_path(XOld,YOld,X,Y,XFirst,YFirst) :- (default::obstacle(X-1,Y) & X-1 \== XOld & Y \== YOld & check_path(X,Y,X-1,Y,XFirst,YFirst)) | (default::obstacle(X-1,Y-1) & X-1 \== XOld & Y-1 \== YOld & check_path(X,Y,X-1,Y-1,XFirst,YFirst)) | (default::obstacle(X-1,Y+1)  & X-1 \== XOld & Y+1 \== YOld & check_path(X,Y,X-1,Y+1,XFirst,YFirst)) | (default::obstacle(X,Y-1) & X \== XOld & Y-1 \== YOld & check_path(X,Y,X,Y-1,XFirst,YFirst)) | (default::obstacle(X,Y+1) & X \== XOld & Y+1 \== YOld & check_path(X,Y,X,Y+1,XFirst,YFirst)) | (default::obstacle(X+1,Y) & X+1 \== XOld & Y \== YOld & check_path(X,Y,X+1,Y,XFirst,YFirst)) | (default::obstacle(X+1,Y-1) & X+1 \== XOld & Y-1 \== YOld & check_path(X,Y,X+1,Y-1,XFirst,YFirst)) | (default::obstacle(X+1,Y+1) & X+1 \== XOld & Y+1 \== YOld & check_path(X,Y,X+1,Y+1,XFirst,YFirst)).

// test plan, should be removed later on
+default::step(X)
	: X \== 0 & X mod 25 = 0
<-
	!get_dispensers(DList);
	!get_clusters(GList);
	!get_map_size(Size);
	.print(DList);
	.print(GList);
	.print(Size);
	getMyPos(MyX,MyY);
	.print("My position ",MyX,", ",MyY);
	.

@perceivedispenser[atomic]
+default::thing(X, Y, dispenser, Type)
	: true
<-
	getMyPos(MyX,MyY);
	!map::get_dispensers(Dispensers);
	!map::update_dispenser_in_map(Type, MyX, MyY, X, Y, Dispensers);
	.

+!map::update_dispenser_in_map(Type, MyX, MyY, X, Y, Dispensers) : .member(dispenser(Type, MyX+X, MyY+Y), Dispensers) <- true.
+!map::update_dispenser_in_map(Type, MyX, MyY, X, Y, Dispensers) 
	: map::myMap(Leader)
<-
	.send(Leader, achieve, map::add_map(Type, MyX, MyY, X, Y));
	.

@perceivegoal[atomic]
+default::goal(X,Y)
	: true
<-
	getMyPos(MyX,MyY);
	!map::get_clusters(Clusters);
	!map::update_goal_in_map(MyX, MyY, X, Y, Clusters);
	.

+!map::visit_goal_cluster(X, Y) :
	X > 0 & not default::obstacle(1, 0)
<- 
	!action::move(e);
	!map::visit_goal_cluster(X-1, Y).
+!map::visit_goal_cluster(X, Y) :
	X < 0 & not default::obstacle(-1, 0)
<- 
	!action::move(w);
	!map::visit_goal_cluster(X+1, Y).
+!map::visit_goal_cluster(X, Y) :
	Y > 0 & not default::obstacle(0, 1)
<- 
	!action::move(s);
	!map::visit_goal_cluster(X, Y-1).
+!map::visit_goal_cluster(X, Y) :
	Y < 0 & not default::obstacle(0, -1)
<- 
	!action::move(n);
	!map::visit_goal_cluster(X, Y+1).
+!map::visit_goal_cluster(X, Y) :
	true
<- 
	-map::evaluating_cluster;
	+exploration::explorer;
	//!action::forget_old_action;
	!!exploration::explore([n,s,e,w]).

	
+!map::update_goal_in_map(MyX, MyY, X, Y, Clusters) : .member(cluster(_, GoalList), Clusters) & (.member(goal(MyX+X, MyY+Y), GoalList) | .member(origin(MyX+X, MyY+Y), GoalList)) <- true.
+!map::update_goal_in_map(MyX, MyY, X, Y, Clusters) 
	: map::myMap(Leader)
<-
	.send(Leader, achieve, map::add_map(goal, MyX, MyY, X, Y));
	if(exploration::explorer){
		-exploration::explorer;
		!action::forget_old_action;
		+map::evaluating_cluster;
		!!map::visit_goal_cluster(X, Y);
	}
	.

@addmap[atomic]
+!add_map(Type, MyX, MyY, X, Y)[source(Ag)]
	: .my_name(Me) & map::myMap(Me)
<-
	if(Type == goal){
		updateGoalMap(Me, MyX+X, MyY+Y, NewCluster);
		//!retrieve::update_target;
	} else{
		!map::get_dispensers(Dispensers);
		if(not .member(dispenser(Type,MyX+X,MyY+Y), Dispensers)){
			updateMap(Me, Type, MyX+X, MyY+Y);
			if (not .member(dispenser(Type,_,_),Dispensers)) {
				?identification::identified(IdList);
				for (.member(Ag,IdList)) {
					.send(Ag, achieve, stop::new_dispenser_or_merge);
				}
				!stop::new_dispenser_or_merge;
			}
		}
	}
	.
@addmapnotme[atomic]
+!add_map(Type, MyX, MyY, X, Y)[source(Ag)]
	: true
<-
	.send(Ag, achieve, exploration::try_again(Type, X, Y));
	.	
	
@evaluate_goal1[atomic]
+!map::evaluate_cluster(Cluster) :
	.my_name(Me)
<-
	getGoals(Me, Cluster, Goals);
	if(exploration::explorer){
		-exploration::explorer;
		!action::forget_old_action;
		+map::evaluating_goal;	
	}
	!!map::evaluate_cluster_aux(Goals);
	.
	
+!map::evaluate_cluster_aux(Goals) :
	.member(Goal, Goals)
<-
	getMyPos(MyX, MyY);
	!map::move_to_goal_to_evaluate(MyX, MyY, Goal);
	getMyPos(MyX1, MyY1);
	!map::search_the_lowest_goal(MyX1, MyY1);
	.

+!map::evaluate_goal_aux(goal(GoalX, GoalY)):
	.my_name(Me) & map::myMap(Leader)
<-
	.print("EVALUATE1");
	getMyPos(MyX, MyY);
	!map::move_to_goal_to_evaluate(MyX, MyY, goal(GoalX, GoalY));
	.print("EVALUATE2");
	!action::clear(0, 2);
	.print("EVALUATE3");
	getMyPos(MyX1, MyY1);
	-map::evaluating_goal;
	if(default::lastActionResult(failed_target)){
		updateMap(Me, goal, MyX1, MyY1, -2);
	}else{
		.findall(obstacle(X, Y), (default::obstacle(X, Y)), Obstacles);
		.length(Obstacles, NObstacles);
		.findall(goal(X, Y), (default::goal(X, Y)), Goals);
		.length(Goals, NGoals);
		if(NGoals < NObstacles){
			updateMap(Me, goal, MyX1, MyY1, 1);
		} else{
			updateMap(Me, goal, MyX1, MyY1, NGoals-NObstacles);
		}
	}
	.send(Leader, achieve, map::finished_to_evaluate_goal(MyX1, MyY1));
	.
	
+!map::search_the_lowest_goal(MyX, MyY) :
	not(default::goal(0, 0))
<-
	if(default::goal(1, 0) | default::goal(2, 0) | default::goal(3, 0) | default::goal(4, 0) | default::goal(5, 0)){
		!action::move(e);
	} elif(default::goal(-1, 0) | default::goal(-2, 0) | default::goal(-3, 0) | default::goal(-4, 0) | default::goal(-5, 0)){
		!action::move(e);
	}
	.
+!map::search_the_lowest_goal(MyX, MyY) :
	not(default::goal(0, 1)) &
	not(default::goal(1, 1)) &
	not(default::goal(2, 1)) &
	not(default::goal(3, 1)) &
	not(default::goal(4, 1)) &
	not(default::goal(-1, 1)) &
	not(default::goal(-2, 1)) &
	not(default::goal(-3, 1)) &
	not(default::goal(-4, 1))
<-
	true;
	.
+!map::search_the_lowest_goal(MyX, MyY) :
	true
<-
	!action::move(s);
	getMyPos(MyX1, MyY1);
	!map::search_the_lowest_goal(MyX1, MyY1);
	.

+!map::move_to_goal_to_evaluate(MyX, MyY, goal(MyX, MyY)). 
+!map::move_to_goal_to_evaluate(MyX, MyY, goal(GoalX, GoalY)) :
	retrieve::pick_direction(MyX, MyY, GoalX, GoalY, Direction)
<-
	
	!action::move(Direction);
	if(Direction == n){
		NewX = MyX;
		NewY = MyY - 1;
	} elif(Direction == s){
		NewX = MyX;
		NewY = MyY + 1;
	} elif(Direction == w){
		NewX = MyX - 1;
		NewY = MyY;
	} else{
		NewX = MyX + 1;
		NewY = MyY;
	}
	!map::move_to_goal_to_evaluate(NewX, NewY, Goal);
	.

@trygoal[atomic]
+!try_again(goal, X, Y)
	: true
<-
	getMyPos(MyX,MyY);
	!map::get_clusters(Clusters);
	!map::update_goal_in_map(MyX, MyY, X, Y, Clusters);
	.
@trydispenser[atomic]
+!try_again(Type, X, Y)
	: true
<-
	getMyPos(MyX,MyY);
	!map::get_dispensers(Dispensers);
	!map::update_dispenser_in_map(Type, MyX, MyY, X, Y, Dispensers);
	.

+!get_dispensers(List)
	: map::myMap(Me)
<-
	getDispensers(Me, List);
	.
	
+!get_goals(Cluster, List)
	: map::myMap(Me)
<-
	getGoals(Me, Cluster, List);
	.
	
+!get_clusters(List)
	: map::myMap(Me)
<-
	getGoalClusters(Me, List);
	.
	
+!get_map_size(Size)
	: map::myMap(Me)
<-
	getMapSize(Me, Size);
	.
	