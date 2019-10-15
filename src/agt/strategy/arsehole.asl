+!arsehole::messing_around :
	stop::first_to_stop(Ag) & idenfication::identified(Ags) & .member(Ag, Ags)
<-
	.print("@@@@@@@@@@@@ Messing around inside the stop group");
	!common::update_role_to(arsehole);
	!map::get_clusters(Clusters);
	getTargetGoal(_, GoalX, GoalY, _);
	.findall(cluster(Name, GoalList),(.member(cluster(Name, GoalList), Clusters) & not .member(origin(_, GoalX, GoalY), GoalList)), ClustersToMessWith);
	.shuffle(ClustersToMessWith, ClustersToMessWithShuffled);
	.nth(0, ClustersToMessWithShuffled, ClusterToMessWith);
	!!arsehole::mess_with_cluster(ClusterToMessWith, 1);
	.

+!arsehole::messing_around :
	true
<-
	.print("@@@@@@@@@@@@ Messing around outside the stop group");
	!common::update_role_to(arsehole);
	!map::get_clusters(Clusters);
	.findall(cluster(Name, GoalList),.member(cluster(Name, GoalList), Clusters), ClustersToMessWith);
	if(ClustersToMessWith == []){
		!!stop::explore_as_explorer;
	} else{
		.shuffle(ClustersToMessWith, ClustersToMessWithShuffled);
		.nth(0, ClustersToMessWithShuffled, ClusterToMessWith);
		!!arsehole::mess_with_cluster(ClusterToMessWith, 0);
	}
	.

+!arsehole::mess_with_cluster(cluster(Name, GoalList), Safe) :
	.member(origin(_, X, Y), GoalList) | .member(goal(X, Y), GoalList)
<-
	!common::move_to_pos(X, Y);
	!arsehole::inspect_cluster(15, Safe);
	!!arsehole::messing_around;
	.
-!arsehole::mess_with_cluster(_, _) : true <- .print("@@@@@@@@@@@@@@@@@@@@@@@@@@@' mess_with_cluster failed'"); !!arsehole::messing_around.

+!arsehole::inspect_cluster(0, _).

+!arsehole::inspect_cluster(TimeWindow, Safe) :
	default::thing(X, Y, block, _) & 
	(math.abs(X)+math.abs(Y)>1) & (math.abs(X)+math.abs(Y)<5) & 
	default::team(Team) & not (default::thing(X1, Y1, entity, Team) & (X1 \== 0 | Y1 \== 0))
<-
	if(Safe == 0){
		if(not (stop::first_to_stop(Ag) & idenfication::identified(Ags) & .member(Ag, Ags))){
			!action::clear(X, Y);
			if(default::thing(X, Y, block, _)){
				!action::clear(X, Y);
				if(default::thing(X, Y, block, _)){
					!action::clear(X, Y);
				}
			}
			!arsehole::inspect_cluster(TimeWindow+5);
		}
	} else{
		getTargetGoal(_, GoalX, GoalY, _);
		getMyPos(MyX, MyY);
		RelativeGoalX = GoalX - MyX;
		RelativeGoalY = GoalY - MyY;
		if(math.abs(RelativeGoalX-X)+math.abs(RelativeGoalY-Y) >= 5){
			!action::clear(X, Y);
			if(default::thing(X, Y, block, _)){
				!action::clear(X, Y);
				if(default::thing(X, Y, block, _)){
					!action::clear(X, Y);
				}
			}
			!arsehole::inspect_cluster(TimeWindow+5);
		}
	}
	
	.
+!arsehole::inspect_cluster(TimeWindow, Safe) :
	.findall(goal(X, Y), default::goal(X, Y), Goals) & Goals \== [] & .shuffle(Goals, GoalsShuffled) & .nth(0, GoalsShuffled, goal(GX, GY)) &
	stock::pich_direction(0, 0, GX, GY, Dir)
<-
	!retrieve::smart_move(Dir);
	!arsehole::inspect_cluster(TimeWindow-1, Safe);
	.
+!arsehole::inspect_cluster(TimeWindow, Safe) :
	 .random(R) & .nth(math.floor(R*3.99), [n,s,w,e], Dir)
<-
	!retrieve::smart_move(Dir);
	!arsehole::inspect_cluster(TimeWindow-1, Safe);
	.
