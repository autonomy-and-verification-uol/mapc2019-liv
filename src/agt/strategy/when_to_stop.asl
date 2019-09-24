
+!stop::choose_the_biggest_cluster([], cluster(_, [])).
+!stop::choose_the_biggest_cluster([cluster(Id1, GoalList1)|Clusters], Cluster) :
	true
<-
	!stop::choose_the_biggest_cluster(Clusters, cluster(Id2, GoalList2));
	.length(GoalList1, Size1);
	.length(GoalList2, Size2);
	if(Size1 >= Size2){
		Cluster = cluster(Id1, GoalList1);
	} else{
		Cluster = cluster(Id2, GoalList2);
	}
	.

@stop1[atomic]
+stop
	: exploration::explorer & not stop::first_to_stop(_) & .my_name(Me) // first to stop
	& .all_names(AllAgents) & .nth(Pos,AllAgents,Me) & map::myMap(Leader)
<-
	!map::get_clusters(Clusters);
	//!stop::choose_the_biggest_cluster(Clusters, cluster(ClusterId, GoalList));
	//.length(GoalList, N);
	//if(N > 5){
	if(.member(cluster(_, GoalList), Clusters) & .member(Side, [n,e,w,s]) &
		.member(origin(Side, GoalX, GoalY), GoalList) & 
		not .member(origin(boh, _, _), GoalList)
	){
		firstToStop(Me,Flag);
		if (Flag) {
			.broadcast(tell, stop::first_to_stop(Me));
			+stop::first_to_stop(Me);
			.print("Removing explorer");
			-exploration::explorer;
			-exploration::special(_);
			-common::avoid(_);
			-common::escape;
			!action::forget_old_action;
			.print("Adding retriever");
			+retrieve::retriever;
			.print("Call first time setTargetGoal");
			//.member(origin(_, GoalX, GoalY), GoalList);
			setTargetGoal(Pos, Me, GoalX, GoalY, Side);
			initAvailablePos(Leader);
			+retrieve::moving_to_origin;
			!!retrieve::move_to_goal;
		}
		else{
			-stop::stop;
		}
	}
	else {
		-stop;
	}
	.
@stop2[atomic]
+stop
	: exploration::explorer & stop::first_to_stop(Ag) & identification::identified(IdList) & .member(Ag, IdList) // someone else stopped already and my map is his map
<-
	joinRetrievers(Flag);
//	.print("Removing explorer");
//	-exploration::explorer;
//	-exploration::special(_);
//	-common::avoid(_);
//	-common::escape;
//	!action::forget_old_action;
//	+retrieve::retriever;
	if (Flag == "stocker") {
		.print("Removing explorer");
		-exploration::explorer;
		-exploration::special(_);
		-common::avoid(_);
		-common::escape;
		!action::forget_old_action;
		+retrieve::retriever;
		+retrieve::stocker;
		!!retrieve::retrieve_block;
	}
	elif (Flag == "helper") {
		.print("Removing explorer");
		-exploration::explorer;
		-exploration::special(_);
		-common::avoid(_);
		-common::escape;
		!action::forget_old_action;
		+retrieve::retriever;
		+task::helper;
		+retrieve::moving_to_origin;
		!!retrieve::move_to_goal;
//		!!retrieve::retrieve_block;
	}
	else {
		-stop;
	}
//	!!retrieve::retrieve_block;
	.
+stop : true <- -stop::stop.

@first_to_stop1[atomic]
+stop::first_to_stop(Ag)[source(_)] :
	retrieve::retriever & .my_name(Me) & stop::first_to_stop(Me) &
	.all_names(AllAgents) & .nth(Pos,AllAgents,Me) & .nth(PosOther,AllAgents,Ag) & PosOther < Pos
<-
	.print("Removing retriever");
//	removeRetriever;
	-retrieve::retriever;
	-stop::stop;
	-stop::first_to_stop(Me);
	!action::forget_old_action;
	.print("Adding explorer");
	+exploration::explorer;
	!!exploration::explore([n,s,e,w]);
	.
@first_to_stop2[atomic]
+stop::first_to_stop(Ag1)[source(_)] :
	stop::first_to_stop(Ag2)[source(_)] & Ag1 \== Ag2 &
	.all_names(AllAgents) & .nth(Pos,AllAgents,Ag1) & .nth(PosOther,AllAgents,Ag2)
<-
	if(Pos < PosOther){
		-stop::first_to_stop(Ag2)[source(_)];
		-stop::first_to_stop(Ag1)[source(_)];
		+stop::first_to_stop(Ag1)[source(_)];
	} else{
		-stop::first_to_stop(Ag1)[source(_)];
		-stop::first_to_stop(Ag2)[source(_)];
		+stop::first_to_stop(Ag2)[source(_)];
	}
	.
//@check_join_group[atomic]
+!stop::check_join_group
	: exploration::explorer & 
	stop::first_to_stop(Ag) & // send a message to the one that stopped asking who the leader is, and you check if you have the same
	map::myMap(Leader)
<-
	.send(Ag, askOne, map::myMap(Leader1), map::myMap(Leader1));
	.print("Leader: ", Leader, " Leader1: ", Leader1);
	if(Leader == Leader1){
		joinRetrievers(Flag);
//		-exploration::explorer;
//		-exploration::special(_);
//		-common::avoid(_);
//		-common::escape;
//		+retrieve::retriever;
//		!action::forget_old_action;
		if (Flag) {
			-exploration::explorer;
			-exploration::special(_);
			-common::avoid(_);
			-common::escape;
			+retrieve::retriever;
			!action::forget_old_action;
			+retrieve::stocker;
			!!retrieve::retrieve_block;
		}
//		!!retrieve::retrieve_block;
	}
	.
+!stop::check_join_group : true <- .print("I cannot join the stop group yet").

// trigger for new task addition 
@trigger1[atomic]
+default::task(ID, Deadline, Reward, Blocks) 
	: not(stop::stop)
 <- 
 	!map::get_dispensers(Dispensers);
	!stop::update_blocks_count(Blocks);
	!map::get_clusters(Clusters);
	//.length(Clusters, NClusters);
	!stop::conditional_stop(Blocks, Clusters, Dispensers, Stop);
	!stop::update_stop(Stop);
	.
	
+!stop::update_stop(true) : true <- +stop::stop.
+!stop::update_stop(false).

+!stop::update_blocks_count([]) : true <- true.
+!stop::update_blocks_count([req(_, _, Type)|Blocks]) : 
	retrieve::block_count(Type, Count) 
<-
	-retrieve::block_count(Type, _);
	Count1 = Count + 1;
	+retrieve::block_count(Type, Count1);
	!stop::update_blocks_count(Blocks).
+!stop::update_blocks_count([req(_, _, Type)|Blocks]) : true <-
	+retrieve::block_count(Type, 1);
	!stop::update_blocks_count(Blocks).
	
+!stop::conditional_stop(Blocks, Clusters, Dispensers, true) : 
	.member(cluster(_, GoalList), Clusters) &
	.member(origin(Side, GoalX, GoalY), GoalList) & .member(Side, [n,s,w,e]) &
	.length(Blocks, NBlocks) & 
	identification::identified(KnownAgs) & .length(KnownAgs, NKnownAgs) & (NKnownAgs + 1) >= NBlocks & // enough agents to build the structure
	.findall(Type, (.member(req(_, _, Type), Blocks) & not(.member(dispenser(Type, _, _), Dispensers))), []) // all the necessary types are known
<- 
	.print("I can stop exploring now..");
	.
+!stop::conditional_stop(Blocks, Clusters, Dispensers, false) : true <-  .print("I cannot stop exploring yet..").

@trigger2[atomic]
+!stop::new_dispenser_or_merge[source(_)] 
	: not(stop::stop) & .findall(task(ID, Deadline, Reward, Blocks), default::task(ID, Deadline, Reward, Blocks), Tasks) & not .empty(Tasks)
<-
	!map::get_dispensers(Dispensers);
	!stop::check_active_tasks(Tasks, Dispensers);
	.
+!stop::new_dispenser_or_merge[source(_)].

+!stop::check_active_tasks([], Dispensers) : not(stop::stop) <- .print("I cannot stop exploring yet..").
+!stop::check_active_tasks([], Dispensers) : stop::stop <- .print("I can stop exploring now..").
+!stop::check_active_tasks([task(ID, Deadline, Reward, Blocks)|Tasks], Dispensers) 
	: not(stop::stop) 
<-
	!map::get_clusters(Clusters);
	//.length(Clusters, NClusters);
	!stop::conditional_stop(Blocks, Clusters, Dispensers, Stop);
	!stop::update_stop(Stop);
	!stop::check_active_tasks(Tasks, Dispensers);
	.
+!stop::check_active_tasks([task(ID, Deadline, Reward, Blocks)|Tasks], Dispensers) : stop::stop <- .print("I can stop exploring now..").

