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
	: common::my_role(explorer) & not stop::first_to_stop(_) & .my_name(Me) // first to stop
	& .all_names(AllAgents) & .nth(Pos,AllAgents,Me) & map::myMap(Leader) //& not action::move_sent
<-
	getGoalClustersWithScouts(Leader, Clusters);
	//!stop::choose_the_biggest_cluster(Clusters, cluster(ClusterId, GoalList));
	//.length(GoalList, N);
	//if(N > 5){
	if(.member(cluster(_, GoalList), Clusters) & .member(Side, [n,e,w,s]) &
		.member(origin(Side,Scouts,Retrievers, MaxPosS, MaxPosW, MaxPosE, GoalX, GoalY), GoalList)// & not .member(origin(boh, _, _), GoalList)
	){
		firstToStop(Me,Flag);
		if (Flag) {
			.print("@@@@@@@@@@@@@@@@@@@ MaxPos: ", MaxPosS, ", ", MaxPosW, ", ", MaxPosE);
			+task::max_pos_s(MaxPosS);
			+task::max_pos_w(MaxPosW);
			+task::max_pos_e(MaxPosE);
			+stop::first_to_stop(Me);
			//.print("Removing explorer");
			//-exploration::explorer;
			-exploration::special(_);
			-common::avoid(_);
			-common::escape;
//			!action::forget_old_action;
			//.member(origin(_, GoalX, GoalY), GoalList);
			setTargetGoal(Pos, Me, GoalX, GoalY, Side);
			initStockerAvailablePos(Leader);
			initRetrieverAvailablePos(Leader);
			.broadcast(tell, stop::first_to_stop(Me));
			!action::forget_old_action;
			!!stop::stop_aux(GoalX, GoalY);
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
	: not stop::really_stop & common::my_role(explorer) & stop::first_to_stop(Ag) & identification::identified(IdList) & .member(Ag, IdList) //& not action::move_sent // someone else stopped already and my map is his map
<-
	.print("ADD really stop belief");
	+stop::really_stop;
	joinRetrievers(Flag);
	if (Flag == "stocker") {
		.print("Removing explorer");
		//-exploration::explorer;
		-exploration::special(_);
		-common::avoid(_);
		-common::escape;
		!action::forget_old_action;
		!!stop::retrieve_block_as_stocker;
	}
	elif (Flag == "helper") {
		.print("Removing explorer");
		//-exploration::explorer;
		-exploration::special(_);
		-common::avoid(_);
		-common::escape;
		!action::forget_old_action;
		!!stop::retrieve_block_as_helper;
	}
	else {
		.print("Removing explorer");
		-exploration::special(_);
		-common::avoid(_);
		-common::escape;
		!action::forget_old_action;
		!!stop::retrieve_block_as_retriever;
	}
//	!!retrieve::retrieve_block;
	.
	
//@stop12
//+stop
//	: action::move_sent
//<-
//	.wait(not action::move_sent);
//	-stop;
//	+stop;
//	.
	
+stop : true <- -stop::stop.

//+!stop::retrieve_block_as_stocker :
//	true
//<-
//	!common::update_role_to(stocker);
////		!!default::always_skip;
//	!retrieve::retrieve_block;
//	.
+!stop::retrieve_block_as_helper :
	true
<-
	!common::update_role_to(helper);
	//+retrieve::retriever;
	//+task::helper;
	+retrieve::moving_to_origin;
	getTargetGoal(_, GoalX, GoalY, _);
	getMyPos(MyX, MyY);
	TargetX = GoalX+1 - MyX;
	TargetY = GoalY - MyY;
	!!planner::generate_goal(TargetX, TargetY, notblock);
//		!!planner::execute_plan(Plan);
//		!!retrieve::move_to_goal;
//		!!retrieve::retrieve_block;
	.
	
+!stop::retrieve_block_as_retriever :
	true
<-
	!common::update_role_to(retriever);
	!retrieve::retrieve_block;
	.
	
+!stop::stop_aux(GoalX, GoalY) :
	true
<-
	!common::update_role_to(origin);
	//+retrieve::retriever;
	
	+retrieve::moving_to_origin;
//			.wait(not action::move_sent);
	getMyPos(MyX, MyY);
	TargetX = GoalX - MyX;
	TargetY = GoalY - MyY;
	!!planner::generate_goal(TargetX, TargetY, notblock);
//			!!planner::execute_plan(Plan);
	//+plan(Plan);
	//?plan([Head|PlanX]);
	//.print("@@@@@@ Head: ",Head);
//			!!retrieve::move_to_goal;
	.

+!stop::explore_as_explorer :
	true
<-
	!common::update_role_to(explorer);
	!!exploration::explore([n,s,e,w]);
	.

@first_to_stop1[atomic]
+stop::first_to_stop(Ag)[source(_)] :
	common::my_role(retriever) & .my_name(Me) & stop::first_to_stop(Me) &
	.all_names(AllAgents) & .nth(Pos,AllAgents,Me) & .nth(PosOther,AllAgents,Ag) & PosOther < Pos
<-
	.print("Removing retriever");
//	removeRetriever;
	//-retrieve::retriever;
	-stop::stop;
	-stop::first_to_stop(Me);
	!action::forget_old_action;
	.print("Adding explorer");
	//+exploration::explorer;
	!!stop::explore_as_explorer;
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
	: common::my_role(explorer) &
	stop::first_to_stop(Ag) & // send a message to the one that stopped asking who the leader is, and you check if you have the same
	map::myMap(Leader) & not stop::really_stop
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
		if (Flag == "stocker") {
			//.print("Removing explorer");
			//-exploration::explorer;
			-exploration::special(_);
			-common::avoid(_);
			-common::escape;
			!action::forget_old_action;
			!!stop::retrieve_block_as_stocker;
			//!common::update_role_to(stocker);
			//!retrieve::retrieve_block;
		}
		elif (Flag == "helper") {
			//.print("Removing explorer");
			//-exploration::explorer;
			-exploration::special(_);
			-common::avoid(_);
			-common::escape;
			!action::forget_old_action;
//			.wait(not action::move_sent);
			!!stop::retrieve_block_as_helper;
			/*getMyPos(MyX, MyY);
			!common::update_role_to(helper);
			//+retrieve::retriever;
			//+task::helper;
			+retrieve::moving_to_origin;
			getTargetGoal(_, GoalX, GoalY, _);
			TargetX = GoalX+1 - MyX;
			TargetY = GoalY - MyY;
			!!planner::generate_goal(TargetX, TargetY);*/
//			!!retrieve::move_to_goal;
		}
		else {
			.print("Removing explorer");
			-exploration::special(_);
			-common::avoid(_);
			-common::escape;
			!action::forget_old_action;
			!!stop::retrieve_block_as_retriever;
			//!common::update_role_to(retriever);
			//!retrieve::retrieve_block;
		}
	//		!!retrieve::retrieve_block;
	}
	.
+!stop::check_join_group : true <- .print("I cannot join the stop group yet").

//+!try_call_stop(true).
//+!try_call_stop(false)
//<-
//	!action::skip;
//	callStop(Flag);
//	!try_call_stop(Flag);
//	.

// trigger for new task addition 
@trigger1[atomic]
+default::task(ID, Deadline, Reward, Blocks) 
	: not(stop::stop)
 <- 
// 	callStop(Flag);
// 	!try_call_stop(Flag);
 	!map::get_dispensers(Dispensers);
	!stop::update_blocks_count(Blocks);
	!map::get_clusters(Clusters);
	//.length(Clusters, NClusters);
	!stop::conditional_stop(Blocks, Clusters, Dispensers, Stop);
	!stop::update_stop(Stop);
//	stopDone;
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
	identification::identified(KnownAgs) & .length(KnownAgs, NKnownAgs) & (NKnownAgs + 1) >= 3 &//NBlocks & // enough agents to build the structure
	.findall(Type, (.member(req(_, _, Type), Blocks) & not(.member(dispenser(Type, _, _), Dispensers))), []) // all the necessary types are known
<- 
	.print("I can stop exploring now..");
	.
+!stop::conditional_stop(Blocks, Clusters, Dispensers, false). // : true <-  .print("I cannot stop exploring yet..").

@trigger2[atomic]
+!stop::new_dispenser_or_merge[source(_)] 
	: not(stop::stop) & .findall(task(ID, Deadline, Reward, Blocks), default::task(ID, Deadline, Reward, Blocks), PreShuffleTasks) & not .empty(PreShuffleTasks)
<-
//	callStop(Flag);
// 	!try_call_stop(Flag);
	.shuffle(PreShuffleTasks,Tasks);
	!map::get_dispensers(Dispensers);
	!stop::check_active_tasks(Tasks, Dispensers, 5);
//	stopDone;
	.
+!stop::new_dispenser_or_merge[source(_)].

+!stop::check_active_tasks([], Dispensers, Counter) : not(stop::stop).
+!stop::check_active_tasks([], Dispensers, Counter) : stop::stop.
+!stop::check_active_tasks(Tasks, Dispensers, 0) : not(stop::stop).
+!stop::check_active_tasks(Tasks, Dispensers, 0) : stop::stop.
+!stop::check_active_tasks([task(ID, Deadline, Reward, Blocks)|Tasks], Dispensers, Counter) 
	: not(stop::stop) 
<-
	!map::get_clusters(Clusters);
	!stop::conditional_stop(Blocks, Clusters, Dispensers, Stop);
	!stop::update_stop(Stop);
	if (not Stop) {
		!stop::check_active_tasks(Tasks, Dispensers, Counter-1);
	}
	.
+!stop::check_active_tasks([task(ID, Deadline, Reward, Blocks)|Tasks], Dispensers, Counter) : stop::stop.

