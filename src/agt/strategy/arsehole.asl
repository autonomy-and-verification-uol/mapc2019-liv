+!arsehole::messing_around :
	true
<-
	!common::update_role_to(arsehole);
	!map::get_clusters(Clusters);
	getTargetGoal(_, GoalX, GoalY, _);
	.findall(cluster(Name, GoalList),(.member(cluster(Name, GoalList), Clusters) & not .member(origin(_, GoalX, GoalY), GoalList)), ClustersToMessWith);
	if(ClustersToMessWith == []){
		!!stop::retrieve_block_as_retriever;
	} else{
		.shuffle(ClustersToMessWith, ClustersToMessWithShuffled);
		.nth(0, ClustersToMessWithShuffled, ClusterToMessWith);
		!!arsehole::mess_with_cluster(ClusterToMessWith);
	}
	.

+!arsehole::mess_with_cluster(cluster(Name, GoalList)) :
	.member(origin(_, X, Y), GoalList) | .member(goal(X, Y), GoalList)
<-
	!common::move_to_pos(X, Y);
	!arsehole::inspect_cluster(15);
	!!arsehole::messing_around;
	.

+!arsehole::inspect_cluster(0).
+!arsehole::inspect_cluster(TimeWindow) :
	default::thing(X, Y, block, _) & (math.abs(X)+math.abs(Y)>1) & default::team(Team) & not (default::thing(X1, Y1, entity, Team) & (X1 \== 0 | Y1 \== 0))
<-
	!action::clear(X, Y);
	if(default::thing(X, Y, block, _)){
		!action::clear(X, Y);
		if(default::thing(X, Y, block, _)){
			!action::clear(X, Y);
		}
	}
	!arsehole::inspect_cluster(TimeWindow);
	.
+!arsehole::inspect_cluster(TimeWindow) :
	.findall(goal(X, Y), default::goal(X, Y), Goals) & Goals \== [] & .shuffle(Goals, GoalsShuffled) & .nth(0, GoalsShuffled, goal(GX, GY)) &
	stock::pich_direction(0, 0, GX, GY, Dir)
<-
	!retrieve::smart_move(Dir);
	!arsehole::inspect_cluster(TimeWindow-1);
	.
+!arsehole::inspect_cluster(TimeWindow) :
	 .random(R) & .nth(math.floor(R*3.99), [n,s,w,e], Dir)
<-
	!retrieve::smart_move(Dir);
	!arsehole::inspect_cluster(TimeWindow-1);
	.
