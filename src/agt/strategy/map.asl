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
	getMyPos(MyX,MyY)
	!map::get_dispensers(Dispensers);
	!map::update_dispenser_in_map(Type, MyX, MyY, X, Y, Dispensers);
	.

+!map::update_dispenser_in_map(Type, MyX, MyY, X, Y, Dispensers) : .member(dispenser(Type, MyX+X, MyY+Y), Dispensers) <- true.
+!map::update_dispenser_in_map(Type, MyX, MyY, X, Y, Dispensers) 
	: map::myMap(Leader)
<-
	.concat(dispenser,Type,MyX+X,MyY+Y,UniqueString);
	+action::reasoning_about_belief(UniqueString);
	.send(Leader, achieve, map::add_map(Type, MyX, MyY, X, Y, UniqueString));
	.

@perceivegoal[atomic]
+default::goal(X,Y)
	: not map::evaluating_vertexes
<-
	getMyPos(MyX,MyY);
	!map::get_clusters(Clusters);
	!map::update_goal_in_map(MyX, MyY, X, Y, Clusters);
	.

+!map::update_goal_in_map(MyX, MyY, X, Y, Clusters) : .member(cluster(_, GoalList), Clusters) & (.member(goal(MyX+X, MyY+Y), GoalList) | .member(origin(_, MyX+X, MyY+Y), GoalList)) <- true.
+!map::update_goal_in_map(MyX, MyY, X, Y, Clusters) 
	: map::myMap(Leader)
<-
	.concat(goal,MyX+X,MyY+Y,UniqueString);
	+action::reasoning_about_belief(UniqueString);
	.send(Leader, achieve, map::add_map(goal, MyX, MyY, X, Y, UniqueString));
	.

-!map::evaluate(_, _) : 
	common::my_role(retriever) 
<- 
	.print("Evaluation failed"); 
	-map::evaluating_positions(_); 
	-map::evaluating_vertexes; 
	!!retrieve::move_to_goal.
-!map::evaluate(_, _) : 
	true 
<- 
	.print("Evaluation failed"); 
	-map::evaluating_positions(_); 
	-map::evaluating_vertexes; 
	!common::update_role_to(explorer);
	!!exploration::explore([n,s,w,e]).
+!map::evaluate(GoalLocalX, GoalLocalY) :
	true
<-
	//-exploration::explorer;
	!action::forget_old_action;
	!common::update_role_to(goal_evaluator);
	if(common::my_role(Role)){.print("My current role: ", Role)}
	+map::evaluating_positions([start(GoalLocalX, GoalLocalY)]);

	!map::find_cluster_origins(GoalLocalX, GoalLocalY);
	if(not map::evaluating_positions(_)){
		.print("Failing because of cluster origin");
		.fail;
	}
	
	+map::evaluating_vertexes;
	!map::evaluate_origin(n, Value1); 
	if(not map::evaluating_positions(_)){
		.print("Failing because of evaluation of north origin");
		.fail;
	}
	!map::update_origin_evaluation(n, Value1);
	.print("OriginN evaluated as:", Value1);
	
	/* +map::scouts_found([]);
	!map::update_origin_evaluation(e, bad);
	!map::update_origin_evaluation(s, bad);
	!map::update_origin_evaluation(w, bad);
	-map::scouts_found(_);*/
	
	// we care only about the north one for now
	/* 
	!map::evaluate_origin(e, Value2);
	if(not map::evaluating_positions(_)){
		.fail;
	}
	!map::update_origin_evaluation(e, Value2);
	.print("OriginE evaluated as:", Value2);
	
	!map::evaluate_origin(s, Value3);
	if(not map::evaluating_positions(_)){
		.fail;
	}
	!map::update_origin_evaluation(s, Value3);
	.print("OriginS evaluated as:", Value3);
	
	!map::evaluate_origin(w, Value4);
	if(not map::evaluating_positions(_)){
		.fail;
	}
	!map::update_origin_evaluation(w, Value4);
	.print("OriginW evaluated as:", Value4);
	*/
	
	-map::evaluating_positions(_);
	-map::evaluating_vertexes;
	
	!action::forget_old_action;
	!map::get_clusters(Clusters);
	.print("Clusters: ", Clusters);
	
	if (not common::my_role(retriever)) {
		//+exploration::explorer;
		!common::update_role_to(explorer);
		!!exploration::explore([n,s,w,e]);
	}
	.

+!map::update_origin_evaluation(Side, Value) :
	map::myMap(Leader) & map::evaluating_positions(Positions) & .member(origin(Side, X, Y), Positions) &
	map::scouts_found(ScoutsList)
<-
	getMyPos(MyX, MyY);
	evaluateOrigin(Leader, MyX + X, MyY + Y, Value);
	if(.member(Side, [n,s,w,e])){
		for(.member(scout(_, ScoutX, ScoutY), ScoutsList)){
			addScoutToOrigin(Leader, MyX + X, MyY + Y, ScoutX + X + MyX, ScoutY + Y + MyY);	
		}
	}
	.

+!map::evaluate_origin(Side, Value) :
	map::evaluating_positions(Positions) & .member(origin(Side, X, Y), Positions)
<-
	!retrieve::generate_square_positions_around_origin(origin(X, Y), Side, 4, 8, 6, 6, Scouts);
	.print("SCOUTSSSSS:", Scouts);
//	L1 = [vertex(Side, w, V1X, V1Y)|Positions];
//	L2 = [vertex(Side, e, V2X, V2Y)|L1];
	-map::scouts_found(_);
	+map::scouts_found([]);
	.concat(Scouts, Positions, L);
	-+map::evaluating_positions(L);
	.print("Positions: ", L);
	NScouts = 2;
	while(map::evaluating_positions(PosAux) & .member(scout(_, _, _), PosAux) & map::scouts_found(ScoutsList) & .length(ScoutsList, N) & N < NScouts){
		.print("Evaluate scout: ", ScoutsList);
		!map::move_to_evaluating_pos(Side);
		.print("One scout has been evaluated");
		if(map::evaluating_positions(Pos1) & .member(origin(_, OriginX, OriginY), Pos1) & .member(scout(_, XDel, YDel), Pos1)){
			.length(Pos1, N1);
			.delete(scout(_, 0, 0), Pos1, Pos2);
			.length(Pos2, N2);
			if(N1 == N2){
				.delete(scout(_, XDel, YDel), Pos1, Pos3);
				-map::evaluating_positions(_);
				+map::evaluating_positions(Pos3);
			} else{
				-map::evaluating_positions(_);
				+map::evaluating_positions(Pos2);
			}
		}
	}
	if(map::scouts_found(ScoutsList) & .length(ScoutsList, NScouts)){
		Value = Side;
	} else{
		Value = bad;
	}
	//.concat(Scouts, Positions, L);
	//L = [scout(Side, PosX, PosY)|Positions];
	//-+map::evaluating_positions(L);
//	if(map::evaluating_positions(Pos)){
//		.print(Pos);
//	}
	//!map::move_to_evaluating_pos(Side);
	//if(map::evaluating_positions(_)){
	//	Value = Side;
	//}
//	if(map::evaluating_positions(_)){
//		!map::move_to_evaluating_pos(Side, e);
//		if(map::evaluating_positions(_)){
//			Value = Side;
//		}
//	}
	.
-!map::evaluate_origin(_, Value) : true <- .print("Bad because of failure"); Value = bad.

+!map::update_evaluating_positions(Side) :
	map::evaluating_positions(Positions)
<-
	if(Side == n){
		DiffX = 0;
		DiffY = 1;
	} elif(Side == s){
		DiffX = 0;
		DiffY = -1;
	} elif(Side == w){
		DiffX = 1;
		DiffY = 0;
	} else{
		DiffX = -1;
		DiffY = 0;
	}
	for(.member(origin(OriginSide, X, Y), Positions)){
		!map::update_evaluating_positions_aux(origin(OriginSide, X, Y), DiffX, DiffY);
	}
	for(.member(scout(OriginSide, X, Y), Positions)){
		!map::update_evaluating_positions_aux(scout(OriginSide, X, Y), DiffX, DiffY);
	}
	for(.member(start(X, Y), Positions)){
		!map::update_evaluating_positions_aux(start(X, Y), DiffX, DiffY);
	}
	if(map::evaluating_positions(NewUpdatedPositions)){
		.print("Old: ", Positions);
		.print("New: ", NewUpdatedPositions);
	}
	.
+!map::update_evaluating_positions_aux(origin(Side, X, Y), DiffX, DiffY) :
	map::evaluating_positions(Positions) & .member(origin(Side, X, Y), Positions) 
<-
	.delete(origin(Side, X, Y), Positions, Positions1);
	-+map::evaluating_positions([origin(Side, X + DiffX, Y + DiffY)|Positions1]);
	.
+!map::update_evaluating_positions_aux(scout(OriginSide, X, Y), DiffX, DiffY) :
	map::evaluating_positions(Positions) & .member(scout(OriginSide, X, Y), Positions) 
<-
	.delete(scout(OriginSide, X, Y), Positions, Positions1);
	.concat(Positions1, [scout(OriginSide, X + DiffX, Y + DiffY)], Positions2);
	-+map::evaluating_positions(Positions2);
	//-+map::evaluating_positions([scout(OriginSide, X + DiffX, Y + DiffY)|Positions1]);
	.
+!map::update_evaluating_positions_aux(start(X, Y), DiffX, DiffY) :
	map::evaluating_positions(Positions) & .member(start(X, Y), Positions) 
<-
	.delete(start(X, Y), Positions, Positions1);
	-+map::evaluating_positions([start(X + DiffX, Y + DiffY)|Positions1]);
	.

+!map::move_to_evaluating_pos(OriginSide) :
	map::myMap(Leader) & map::evaluating_positions(Positions) & .member(start(X, Y), Positions)
<-
	getMyPos(MyX, MyY);
	getGoalClusters(Leader, Clusters);
	if(OriginSide == start1 | (.member(cluster(_, GoalList), Clusters) & (.member(goal(MyX+X, MyY+Y), GoalList)) & // .member(origin(_, MyX+X, MyY+Y), GoalList) 
		not .member(origin(_, _, _), GoalList))
	){
		!map::move_to_evaluating_pos_1(OriginSide);
	} else{
		-map::evaluating_positions(_);
		.print("Stop evaluating the cluster1(", MyX, ", ", MyY, ") ", " (", X, ", ", Y, ") ", Clusters);
	}
	.
+!map::move_to_evaluating_pos(OriginSide) :
	map::myMap(Leader) & map::evaluating_positions(Positions) & .member(origin(_, X, Y), Positions)
<-
	getMyPos(MyX, MyY);
	getGoalClusters(Leader, Clusters);
	if(.member(cluster(_, GoalList), Clusters) & (.member(origin(_, MyX+X, MyY+Y), GoalList) | .member(goal(MyX+X, MyY+Y), GoalList)) &
		.member(origin(boh, _, _), GoalList)
	){
		.print("call pos_1");
		!map::move_to_evaluating_pos_1(OriginSide);
	} else{
		-map::evaluating_positions(_);
		.print("Positions: ", Positions);
		.print("Stop evaluating the cluster2: (", MyX, ", ", MyY, ") ", " (", X, ", ", Y, ") ", Clusters);
	}
	.
+!map::move_to_evaluating_pos_1(OriginSide) :
	map::evaluating_positions(Positions) & .member(start(0, 0), Positions)
<- 
	.delete(start(_, _), Positions, NewPositions);
	-+map::evaluating_positions(NewPositions);
	.
+!map::move_to_evaluating_pos_1(OriginSide) :
	map::evaluating_positions(Positions) & .member(scout(OriginSide, 0, 0), Positions) &
	map::scouts_found(ScoutsList) & .member(origin(OriginSide, OriginX, OriginY), Positions)
<-
	if(
		not (default::goal(0, 0) | default::thing(0, 0, dispenser, _)
			 //| default::obstacle(0, -1) | default::obstacle(0, 1) | default::obstacle(-1, 0) | default::obstacle(1, 0)
		)
	) {
		!action::clear(0, -2);
		if(not default::lastActionResult(failed_target)){
			!action::clear(0, 2);
			if(not default::lastActionResult(failed_target)){
				!action::clear(-2, 0);
				if(not default::lastActionResult(failed_target)){
					!action::clear(2, 0);
					if(not default::lastActionResult(failed_target)){
						.print("Scout found");
						-map::scouts_found(_);
						+map::scouts_found([scout(OriginSide, -OriginX, -OriginY)|ScoutsList]);
					} 
				}
			}
		}
	} /*else{
		.print("Scout rejected");
	}*/
	/*elif((OriginSide == e) & (default::obstacle(0, -4) | default::obstacle(0, -3)) | (default::obstacle(0, 4) | default::obstacle(0, 5)) | (default::obstacle(2, 0) | default::obstacle(2, 1)) | (default::obstacle(4, 0) | default::obstacle(4, 1))) {
		.fail;
	}
	elif((OriginSide == w) & (default::obstacle(0, -4) | default::obstacle(0, -3)) | (default::obstacle(0, 4) | default::obstacle(0, 5)) | (default::obstacle(-2, 0) | default::obstacle(-2, 1)) | (default::obstacle(-4, 0) | default::obstacle(-4, 1))) {
		.fail;
	}*/
	.
+!map::move_to_evaluating_pos_1(OriginSide) :
	map::evaluating_positions(Positions) & .member(start(X, Y), Positions) &
	retrieve::pick_direction(0, 0, X, Y, Direction)
<-
	!map::move_to_evaluating_pos_aux(Direction, Res);
	if(Res == 1){
		!map::move_to_evaluating_pos(OriginSide);
	}
	.
+!map::move_to_evaluating_pos_1(OriginSide) :
	map::evaluating_positions(Positions) & .member(scout(OriginSide, X, Y), Positions) &
	retrieve::pick_direction(0, 0, X, Y, Direction)
<-
	
	//if((math.abs(X)+math.abs(Y)) > 5 | not default::obstacle(X, Y)){
	!map::move_to_evaluating_pos_aux(Direction, Res);
	if(Res == 1){
		!map::move_to_evaluating_pos(OriginSide);
	}
	//}
	.
-!map::move_to_evaluating_pos_aux(Direction, Res) : true <- Res = 0.
+!map::move_to_evaluating_pos_aux(Direction, Res) :
	true
<-
	if (exploration::check_obstacle_special_1(Direction, 1)) {
		if(default::energy(Energy) & Energy >= 30 & not exploration::check_agent_special(Direction)){
			!retrieve::smart_clear(Direction);
			if(retrieve::res(0)){
				Res = 0;
			} else {
				Res = 1;
			}
		} else {
			!retrieve::go_around_obstacle(Direction, DirectionToGo, MyX, MyY, 0, 5, DirectionObstacle1, 1)
			getMyPos(MyX1,MyY1);
			if(MyX == MyX1 & MyY == MyY1){
				for(.range(_, 1, 5) & .random(R) & .nth(math.floor(R*3.99), [n,s,w,e], Dir)){
					!retrieve::smart_move(Dir);
				}
			}
			.print("After go_around_obstacle");
			Res = 1;
		}
	} else {
		if(common::my_role(Role)){.print("Before My current role: ", Role)}
		!retrieve::smart_move(Direction);
		if(common::my_role(Role)){.print("After My current role: ", Role)}
		if(default::lastActionResult(failed_forbidden)){
			Res = 0;
		} else {
			Res = 1;
		}
	}
	.

+!map::find_cluster_origins(GoalLocalX, GoalLocalY) :
	true
<-
	if(common::my_role(Role)){.print("My current role: ", Role)}
	!map::move_to_evaluating_pos(start);
	!map::find_cluster_origin(n); 
	!map::check_task_area;
	//!map::find_cluster_origin(e); 
	//!map::find_cluster_origin(s); 
	//!map::find_cluster_origin(w);
	.
+!map::check_task_area :
	map::evaluating_positions(Pos)
<- 
	-+map::evaluating_positions([start(0, 5)|Pos]);
	!map::move_to_evaluating_pos(start1);
	!action::clear(0, 5);
	if(default::lastActionResult(failed_target) & map::myMap(Leader)) {
		getMyPos(MyX, MyY);
		evaluateOrigin(Leader, MyX, MyY, bad);
		.fail;
	} else {
		if(map::evaluating_positions(Pos1)){
			.delete(start(_, _), Pos1, Pos2);
			-+map::evaluating_positions([start(0, -5)|Pos2]);
			!map::move_to_evaluating_pos(start1);
		}
	}
	.	

+!map::find_cluster_origin(n) :
	default::goal(GX, GY) & GY < 0 & GX > 0 & not stop::first_to_stop(_)
<-
	!retrieve::smart_move(e);
	!retrieve::smart_move(n);
	!map::find_cluster_origin(n);		
	.
+!map::find_cluster_origin(n) :
	default::goal(GX, GY) & GY < 0 & GX < 0 & not stop::first_to_stop(_)
<-
	!retrieve::smart_move(w);
	!retrieve::smart_move(n);
	!map::find_cluster_origin(n);	
	.
+!map::find_cluster_origin(n) :
	default::goal(GX, GY) & GY < 0 & not stop::first_to_stop(_)
<-
	!retrieve::smart_move(n);
	!map::find_cluster_origin(n);	
	.
/* 
+!map::find_cluster_origin(s) :
	default::goal(GX, GY) & GY > 0 & GX > 0
<-
	!retrieve::smart_move(e);
	!retrieve::smart_move(s);
	!map::find_cluster_origin(s);
	.
+!map::find_cluster_origin(s) :
	default::goal(GX, GY) & GY > 0 & GX < 0
<-
	!retrieve::smart_move(w);
	!retrieve::smart_move(s);
	!map::find_cluster_origin(s);
	.
+!map::find_cluster_origin(s) :
	default::goal(GX, GY) & GY > 0
<-
	!retrieve::smart_move(s);
	!map::find_cluster_origin(s);
	.
+!map::find_cluster_origin(w) :
	default::goal(GX, GY) & GY < 0 & GX < 0
<-
	!retrieve::smart_move(n);
	!retrieve::smart_move(w);
	!map::find_cluster_origin(w);
	.
+!map::find_cluster_origin(w) :
	default::goal(GX, GY) & GY > 0 & GX < 0
<-
	!retrieve::smart_move(s);
	!retrieve::smart_move(w);
	!map::find_cluster_origin(w);
	.
+!map::find_cluster_origin(w) :
	default::goal(GX, GY) & GX < 0
<-
	!retrieve::smart_move(w);
	!map::find_cluster_origin(w);
	.
+!map::find_cluster_origin(e) :
	default::goal(GX, GY) & GY < 0 & GX > 0
<-
	!retrieve::smart_move(n);
	!retrieve::smart_move(e);
	!map::find_cluster_origin(e);
	.
+!map::find_cluster_origin(e) :
	default::goal(GX, GY) & GY > 0 & GX > 0
<-
	!retrieve::smart_move(s);
	!retrieve::smart_move(e);
	!map::find_cluster_origin(e);
	.
+!map::find_cluster_origin(e) :
	default::goal(GX, GY) & GX > 0
<-
	!retrieve::smart_move(e);
	!map::find_cluster_origin(e);
	.
*/
+!map::find_cluster_origin(Side) : 
	map::myMap(Leader) & map::evaluating_positions(Positions)
<-
	getMyPos(MyX, MyY);
	evaluateOrigin(Leader, MyX, MyY, boh);
	.print("OldPos: ", Positions);
	-+map::evaluating_positions([origin(Side, 0, 0)|Positions]);
	if(map::evaluating_positions(Pos)){
		.print("NewPos: ", Pos);
	}
	.

@addmap[atomic]
+!add_map(Type, MyX, MyY, X, Y, UniqueString)[source(Ag)]
	: .my_name(Me) & map::myMap(Me)
<-
	if(Type == goal){
		updateGoalMap(Me, MyX+X, MyY+Y, InsertedInCluster, IsANewCluster);
		if(IsANewCluster){
			.send(Ag, achieve, map::evaluate(X, Y));
		}
		//!retrieve::update_target;
	} else{
		!map::get_dispensers(Dispensers);
		if (not .member(dispenser(Type,_,_),Dispensers)) {
			updateMap(Me, Type, MyX+X, MyY+Y);
			?identification::identified(IdList);
			for (.member(Ag,IdList)) {
				.send(Ag, achieve, stop::new_dispenser_or_merge);
			}
			!stop::new_dispenser_or_merge;
		}	
		elif(not .member(dispenser(Type,MyX+X,MyY+Y), Dispensers)){
			updateMap(Me, Type, MyX+X, MyY+Y);
		}
	}
	.term2string(Ag,S);
	if (S == "self") {
		!identification::remove_reasoning(UniqueString);
	}
	else {
		.send(Ag, achieve, identification::remove_reasoning(UniqueString));
	}
	.
+!add_map(Type, MyX, MyY, X, Y, UniqueString)[source(Ag)]
<-
	.term2string(Ag,S);
	if (S == "self") {
		!identification::remove_reasoning(UniqueString);
	}
	else {
		.send(Ag, achieve, identification::remove_reasoning(UniqueString));
	}
	.

//@addmapnotme[atomic]
//+!add_map(Type, MyX, MyY, X, Y)[source(Ag)]
//	: true
//<-
//	.send(Ag, achieve, map::try_again(Type, X, Y));
//	.	
//	
//@trygoal[atomic]
//+!try_again(goal, X, Y)
//	: true
//<-
//	getMyPos(MyX,MyY);
//	!map::get_clusters(Clusters);
//	!map::update_goal_in_map(MyX, MyY, X, Y, Clusters);
//	.
//@trydispenser[atomic]
//+!try_again(Type, X, Y)
//	: true
//<-
//	getMyPos(MyX,MyY);
//	!map::get_dispensers(Dispensers);
//	!map::update_dispenser_in_map(Type, MyX, MyY, X, Y, Dispensers);
//	.

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
	