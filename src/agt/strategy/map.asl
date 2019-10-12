check_stuck([]) :- false.
check_stuck([obstacle(X,Y)|ObsList]) :- (default::obstacle(X-1,Y) & check_path(X,Y,X-1,Y,X,Y)) | (default::obstacle(X-1,Y-1) & check_path(X,Y,X-1,Y-1,X,Y)) | (default::obstacle(X-1,Y+1) & check_path(X,Y,X-1,Y+1,X,Y)) | (default::obstacle(X,Y-1) & check_path(X,Y,X,Y-1,X,Y)) | (default::obstacle(X,Y+1) & check_path(X,Y,X,Y+1,X,Y)) | (default::obstacle(X+1,Y) & check_path(X,Y,X+1,Y,X,Y)) | (default::obstacle(X+1,Y-1) & check_path(X,Y,X+1,Y-1,X,Y)) | (default::obstacle(X+1,Y+1) & check_path(X,Y,X+1,Y+1,X,Y)).

check_path(XOld,YOld,XFirst,YFirst,XFirst,YFirst) :- true.
check_path(XOld,YOld,X,Y,XFirst,YFirst) :- (default::obstacle(X-1,Y) & X-1 \== XOld & Y \== YOld & check_path(X,Y,X-1,Y,XFirst,YFirst)) | (default::obstacle(X-1,Y-1) & X-1 \== XOld & Y-1 \== YOld & check_path(X,Y,X-1,Y-1,XFirst,YFirst)) | (default::obstacle(X-1,Y+1)  & X-1 \== XOld & Y+1 \== YOld & check_path(X,Y,X-1,Y+1,XFirst,YFirst)) | (default::obstacle(X,Y-1) & X \== XOld & Y-1 \== YOld & check_path(X,Y,X,Y-1,XFirst,YFirst)) | (default::obstacle(X,Y+1) & X \== XOld & Y+1 \== YOld & check_path(X,Y,X,Y+1,XFirst,YFirst)) | (default::obstacle(X+1,Y) & X+1 \== XOld & Y \== YOld & check_path(X,Y,X+1,Y,XFirst,YFirst)) | (default::obstacle(X+1,Y-1) & X+1 \== XOld & Y-1 \== YOld & check_path(X,Y,X+1,Y-1,XFirst,YFirst)) | (default::obstacle(X+1,Y+1) & X+1 \== XOld & Y+1 \== YOld & check_path(X,Y,X+1,Y+1,XFirst,YFirst)).

// test plan, should be removed later on
@testplan[atomic]
+default::step(X)
	: X \== 0 & X mod 25 = 0
<-
	!get_dispensers(DList);
	!get_clusters(GList);
	!get_map_size(Size);
	.print(DList);
	.print(GList);
	.print(Size);
//	getMyPos(MyX,MyY);
//	.print("My position ",MyX,", ",MyY);
	.

@perceivedispenser[atomic]
+default::thing(X, Y, dispenser, Type)
	: true
<-
	getMyPos(MyX,MyY);
//	.print("Perceived dispenser of type ",Type," at X ",X," at Y ",Y);
	!map::get_dispensers(Dispensers);
	!map::update_dispenser_in_map(Type, MyX, MyY, X, Y, Dispensers);
	.

+!map::update_dispenser_in_map(Type, MyX, MyY, X, Y, Dispensers) : .member(dispenser(Type, MyX+X, MyY+Y), Dispensers) <- true.
+!map::update_dispenser_in_map(Type, MyX, MyY, X, Y, Dispensers) 
	: map::myMap(Leader) & default::step(S)
<-
	.concat(dispenser,Type,MyX+X,MyY+Y,UniqueString);
	+action::reasoning_about_belief(UniqueString);
	.print("Sending to ",Leader, " to add a dispenser at X ",MyX+X," Y ",MyY+Y," at step ",S);
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

@available_to_evaluate1[atomic]
+!map::available_to_evaluate(1, GoalLocalX, GoalLocalY) :
	not common::my_role(goal_evaluator)
<-
	+map::evaluating_positions([start(GoalLocalX, GoalLocalY)]);
	!!common::update_role_to(goal_evaluator);
	.
@available_to_evaluate2[atomic]
+!map::available_to_evaluate(0, _, _).
	
-!map::evaluate(_, _) : 
	common::previous_role(retriever) 
<- 
	.print("Evaluation failed"); 
	-map::evaluating_positions(_); 
	-map::evaluating_vertexes; 
	!common::go_back_to_previous_role;
	!!retrieve::retrieve_block.
-!map::evaluate(_, _) : 
	common::previous_role(explorer)  
<- 
	.print("Evaluation failed"); 
	-map::evaluating_positions(_); 
	-map::evaluating_vertexes; 
	!common::go_back_to_previous_role;
	//!common::update_role_to(explorer);
	!!exploration::explore([n,s,w,e]).
+!map::evaluate(GoalLocalX, GoalLocalY) :
	true
<-
	//-exploration::explorer;
	!action::forget_old_action;
	!common::update_role_to(goal_evaluator);
	
	if(not map::evaluating_positions) {
		+map::evaluating_positions([start(GoalLocalX, GoalLocalY)]);
	}

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
	!common::go_back_to_previous_role;
	if (common::my_role(explorer)) {
		//+exploration::explorer;
		//!common::update_role_to(explorer);
		!!exploration::explore([n,s,w,e]);
	}
	.

+!map::update_origin_evaluation(Side, Value) :
	map::myMap(Leader) & map::evaluating_positions(Positions) & .member(origin(Side, X, Y), Positions) &
	map::scouts_found(ScoutsList) & map::retrievers_found(RetrieversList)
<-
//	.wait(not action::move_sent);
	getMyPos(MyX, MyY);
	if(.member(Side, [n,s,w,e])){
		/*for(.member(scout(_, ScoutX, ScoutY), ScoutsList)){
			addScoutToOrigin(Leader, MyX + X, MyY + Y, ScoutX + X + MyX, ScoutY + Y + MyY);	
		}*/
		for(.member(retriever(RetrieverX, RetrieverY), RetrieversList)){
			addRetrieverToOrigin(Leader, MyX + X, MyY + Y, RetrieverX + X + MyX, RetrieverY + Y + MyY);	
		}
	}
	evaluateOrigin(Leader, MyX + X, MyY + Y, Value);
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
	-map::retrievers_found(_);
	+map::retrievers_found([]);
	.concat(Scouts, Positions, L);
	-+map::evaluating_positions(L);
	.print("Positions: ", L);
	//+map::number_stocker_positions(2);
	+map::number_retriever_positions(9);
	/*while(map::evaluating_positions(PosAux) & .member(scout(_, _, _), PosAux) & 
		map::scouts_found(ScoutsList) & map::retrievers_found(RetrieverList) & 
		map::number_stocker_positions(RequiredNumberScouts) & map::number_retriever_positions(RequiredNumberRetrievers) &
		.length(ScoutsList, NScouts) & .length(RetrieverList, NRetrievers) & 
		(NScouts < RequiredNumberScouts | NRetrievers < RequiredNumberRetrievers)
	){*/
	while(map::evaluating_positions(PosAux) & .member(scout(_, _, _), PosAux) & 
		map::retrievers_found(RetrieverList) & 
		map::number_retriever_positions(RequiredNumberRetrievers) &
		.length(RetrieverList, NRetrievers) & 
		NRetrievers < RequiredNumberRetrievers
	){
		.print("Evaluate scout: ", RetrieverList);
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
	/*if(map::scouts_found(ScoutsList) & map::retrievers_found(RetrieversList) & 
		map::number_stocker_positions(RequiredNumberScouts) & .length(ScoutsList, RequiredNumberScouts) &
		map::number_retriever_positions(RequiredNumberRetrievers) & .length(RetrieversList, NumberRetrieversPositionsFound) &
		NumberRetrieversPositionsFound >= RequiredNumberRetrievers
	){*/
	if(map::retrievers_found(RetrieversList) & 
	   map::number_retriever_positions(RequiredNumberRetrievers) & .length(RetrieversList, NumberRetrieversPositionsFound) &
		NumberRetrieversPositionsFound >= RequiredNumberRetrievers
	){
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
//	.wait(not action::move_sent);
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
//	.wait(not action::move_sent);
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
	.member(origin(OriginSide, OriginX, OriginY), Positions) // & map::scouts_found(ScoutsList)
<-
	if(
		not (default::goal(0, 0) | default::thing(0, 0, dispenser, _)
			| default::thing(0, -1, dispenser, _) | default::thing(0, 1, dispenser, _) 
			| default::thing(-1, 0, dispenser, _) | default::thing(-2, 0, dispenser, _) | default::thing(1, 0, dispenser, _) | default::thing(2, 0, dispenser, _)
			| default::thing(-1, -1, dispenser, _) | default::thing(-1, 1, dispenser, _)
			| default::thing(1, -1, dispenser, _) | default::thing(1, 1, dispenser, _)
			 //| default::obstacle(0, -1) | default::obstacle(0, 1) | default::obstacle(-1, 0) | default::obstacle(1, 0)
		) & map::retrievers_found(RetrieverPositions)
	) {
		.print("Retriever found: ", [retriever(-OriginX, -OriginY)|RetrieverPositions]);
		-+map::retrievers_found([retriever(-OriginX, -OriginY)|RetrieverPositions]);
	}
	.
		/*if(map::number_stocker_positions(NStockers) & map::scouts_found(StockersFound) &
			.length(StockersFound, NStockersFound) & NStockers > NStockersFound){
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
		}
		if(map::number_retriever_positions(NRetriever) & map::retrievers_found(RetrieverPositions) &
			.length(RetrieverPositions, NRetrieverFound) & NRetriever > NRetrieverFound) {
			if(not (.member(scout(_, SX, SY), Positions) & SY > 0)) {
				North = 0;
			}
			if(not (.member(scout(_, SX, SY), Positions) & SY < 0)) {
				South = 0;
			}
			if(not (.member(scout(_, SX, SY), Positions) & SX > 0)) {
				West = 0;
			}
			if(not (.member(scout(_, SX, SY), Positions) & SX < 0)) {
				East = 0;
			}
			.print("North:", North);
			.print("South:", South);
			.print("West:", West);
			.print("East:", East);
			if(not .ground(West)) {
				!action::clear(-5, 0);
				if(default::lastActionResult(failed_target)) {
					West = 0;	
				} else {
					West = 1;
				}
			}
			if(not .ground(East)) {
				!action::clear(5, 0);
				if(default::lastActionResult(failed_target)) {
					East = 0;	
				} else {
					East = 1;
				}
			}
			if(not .ground(North)) {
				!action::clear(0, -5);
				if(default::lastActionResult(failed_target)) {
					North = 0;	
				} else {
					North = 1;
				}
			} 
			if(not .ground(South)) {
				!action::clear(0, 5);
				if(default::lastActionResult(failed_target)) {
					South = 0;	
				} else {
					South = 1;
				}
			}
			
			if(North== 1 & West== 1 & East == 1 & South == 0) { //north side
				L = [retriever(-OriginX-4, -OriginY-4), retriever(-OriginX, -OriginY-4), retriever(-OriginX+4, -OriginY-4)];
			}
			elif(North== 1 & West== 1 & South == 1 & East == 0) { //west side
				L = [retriever(-OriginX-4, -OriginY-4), retriever(-OriginX-4, -OriginY), retriever(-OriginX-4, -OriginY+4)];	
			}
			elif(South== 1 & West== 1 & East == 1 & North == 0) { //south side
				L = [retriever(-OriginX-4, -OriginY+4), retriever(-OriginX, -OriginY+4), retriever(-OriginX+4, -OriginY+4)];	
			}
			elif(South== 1 & East == 1 & North == 1 & West== 0) { //east side
				L = [retriever(-OriginX+4, -OriginY-4), retriever(-OriginX+4, -OriginY), retriever(-OriginX+4, -OriginY+4)];	
			}
			else{
				L = [];
			}
			//.print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
			//.print(L);
			//.print(RetrieverPositions);
			.setof(
				retriever(X, Y),
				(
					.member(retriever(X, Y), L) &
					.member(retriever(X1, Y1), RetrieverPositions) &
					math.abs(X - X1) + math.abs(Y - Y1) < 5
				),
				BadRetrievers);
			//.print(BadRetrievers);
			.difference(L, BadRetrievers, L1);
			//.print(L1);
			.concat(RetrieverPositions, L1, RetrieverPositions1);
			//.print(RetrieverPositions1);
			//.print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@");
			//.setof(Retriever, .member(Retriever, RetrieverPositions1), RetrieverPositions2);
			-+map::retrievers_found(RetrieverPositions1);
		}
	}
	.*/
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
			//!retrieve::go_around_obstacle(Direction, DirectionToGo, MyX, MyY, 0, 5, DirectionObstacle1, 1);
			//.wait(not action::move_sent);
			//getMyPos(MyX1,MyY1);
			//if(MyX == MyX1 & MyY == MyY1){
			for(.range(_, 1, 3) & .random(R) & .nth(math.floor(R*3.99), [n,s,w,e], Dir)){
				!retrieve::smart_move(Dir);
			}
			//}
			//.print("After go_around_obstacle");
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
	!map::find_cluster_origin;//(n); 
	!map::check_task_area;
	//!map::find_cluster_origin(e); 
	//!map::find_cluster_origin(s); 
	//!map::find_cluster_origin(w);
	.
+!map::check_task_area :
	map::evaluating_positions(Pos)
<- 
	+map::checking_task_area;
	-+map::evaluating_positions([start(0, 1)|Pos]);
	!map::move_to_evaluating_pos(start1);
	!action::clear(0, 5);
	if(default::lastActionResult(failed_target) & map::myMap(Leader)) {
//		.wait(not action::move_sent);
		getMyPos(MyX, MyY);
		evaluateOrigin(Leader, MyX, MyY, bad);
		-map::checking_task_area;
		.fail;
	} else {
		if(map::evaluating_positions(Pos1)){
			.delete(start(_, _), Pos1, Pos2);
			-+map::evaluating_positions([start(0, -1)|Pos2]);
			!map::move_to_evaluating_pos(start1);
			-map::checking_task_area;
		}
	}
	.	

+!map::conditional_stop_evaluating(Leader, GoalX, GoalY)[source(Ag)] :
	map::myMap(Leader) & common::my_role(goal_evaluator) &
	map::evaluating_positions(Pos) & .my_name(Me) & .all_names(AllAgents) & .nth(Nth,AllAgents,Me) & .nth(Nth1,AllAgents,Ag)
<-
//	.wait(not action::move_sent);
	getMyPos(MyX, MyY);
	.print(conditional_stop_evaluating(Leader, GoalX, GoalY)[source(Ag)], ", Pos: ", Pos, " Goal: ", GoalX, " ", GoalY);
	if((.member(origin(_, MyX+GoalX, MyY+GoalY), Pos) | .member(start(MyX+GoalX, MyY+GoalY), Pos)) & 
		Nth1 < Nth
	) {
		!common::go_back_to_previous_role;
		if(common::my_role(retriever)){
			!!retrieve::move_to_goal;
		} elif(common::my_role(explorer)){
			!!exploration::explore([n,s,w,e]);
		}
	}
	.
+!map::conditional_stop_evaluating(Leader, GoalX, GoalY)[source(Ag)] : true <- .print(conditional_stop_evaluating(Leader, GoalX, GoalY)[source(Ag)]).



+!map::find_cluster_origin :
	map::evaluating_positions(Pos) & default::goal(GX1, GY1) & .findall(goal(GX2, GY2), (default::goal(GX2, GY2) & GY2 < GY1), []) & (GX1 \== 0 | GY1 \== 0)
<-
	//.print("@@@@@@@@@@@@@@@@@@@@@@@@@@@GOAL: ", default::goal(GX1, GY1));
	-+map::evaluating_positions([start(GX1, GY1)|Pos]);
	getMyPos(MyX, MyY);
	!map::move_to_evaluating_pos(start1);
	getMyPos(MyX1, MyY1);
	if(MyX == MyX1 & MyY == MyY1){
		.fail;
	}
	!map::find_cluster_origin;
	.
+!map::find_cluster_origin :
	map::evaluating_positions(Pos) & default::goal(GX1, GY1) & .findall(goal(GX2, GY2), (default::goal(GX2, GY2) & GY2 == 0 & GX2 > GX1), []) & GX1 \== 0 & GY1 == 0
<-
	//.print("@@@@@@@@@@@@@@@@@@@@@@@@@@@GOAL: ", default::goal(GX1, GY1));
	-+map::evaluating_positions([start(GX1, GY1)|Pos]);
	getMyPos(MyX, MyY);
	!map::move_to_evaluating_pos(start1);
	getMyPos(MyX1, MyY1);
	if(MyX == MyX1 & MyY == MyY1){
		.fail;
	}
	!map::find_cluster_origin;
	.
+!map::find_cluster_origin :
	true
<-
	!map::find_other_side(0);
	.

/* 
+!map::find_cluster_origin(n) :
	default::goal(GX, GY) & GY < 0 & GX > 0 & not stop::first_to_stop(_)
<-
	.print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@HERE1");
	!retrieve::smart_move(e);
	!retrieve::smart_move(n);
	!map::move_random(3);
	!map::find_cluster_origin(n);		
	.
+!map::find_cluster_origin(n) :
	default::goal(GX, GY) & GY < 0 & GX < 0 & not stop::first_to_stop(_)
<-
	.print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@HERE2");
	!retrieve::smart_move(w);
	!retrieve::smart_move(n);
	!map::move_random(3);
	!map::find_cluster_origin(n);	
	.
+!map::find_cluster_origin(n) :
	default::goal(GX, GY) & GY < 0 & not stop::first_to_stop(_)
<-
	.print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@HERE3");
	!retrieve::smart_move(n);
	!map::move_random(3);
	!map::find_cluster_origin(n);	
	.
+!map::find_cluster_origin(n) :
	default::goal(GX, GY) & GY = 0 & GX > 0 & not stop::first_to_stop(_)
<-
	.print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@HERE4");
	!retrieve::smart_move(e);
	!map::move_random(3);
	!map::find_cluster_origin(n);
	.	
	* 
	*/
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
/*+!map::find_cluster_origin(Side) : 
	map::myMap(Leader) & map::evaluating_positions(Positions)
<-
//	.wait(not action::move_sent);
	//getMyPos(MyX, MyY);
	//getGoalClusters(Leader, Clusters);
	//if(.member(cluster(_, Goals), Clusters) & .print("GOALSSSSSSS: ", Goals) & .member(origin(_, MyX, MyY), Goals)) {
	//	.fail;
	//}
	//evaluateOrigin(Leader, MyX, MyY, boh);
	//.print("OldPos: ", Positions);
	//-+map::evaluating_positions([origin(Side, 0, 0)|Positions]);
	//if(map::evaluating_positions(Pos)){
	//	.print("NewPos: ", Pos);
	//}
	.print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@HERE5");
	!map::find_other_side(0);
	.*/
+!map::find_other_side(Count) :
	default::goal(GX, GY) & GX == 0 & GY > 0 & not stop::first_to_stop(_)
<-
	!retrieve::smart_move(s);
	if(default::lastActionResult(success)){
		!map::find_other_side(Count+1);
	} else {
		!map::find_other_side(Count);
	}
	.
+!map::find_other_side(Count) :
	map::myMap(Leader) & not stop::first_to_stop(_)
<-
	DiffY = math.floor(-Count/2);
	-+map::evaluating_positions([start(0, DiffY)|Pos]);
	!map::move_to_evaluating_pos(start1);
	getMyPos(MyX, MyY);
	getGoalClusters(Leader, Clusters);
	if(.member(cluster(_, Goals), Clusters) & .print("GOALSSSSSSS: ", Goals) & .member(origin(_, MyX, MyY), Goals)) {
		.fail;
	}
	evaluateOrigin(Leader, MyX, MyY, boh);
	.print("OldPos: ", Positions);
	-+map::evaluating_positions([origin(Side, 0, 0)|Positions]);
	if(map::evaluating_positions(Pos)){
		.print("NewPos: ", Pos);
	}
	.	
+!map::move_random(Steps) :
	not default::lastActionResult(success)
<-
	for(.range(_, 1, Steps) & .random(R) & .nth(math.floor(R*3.99), [n,s,w,e], Dir)){
		!retrieve::smart_move(Dir);
	}
	.
+!map::move_random(_).

@addmap1[atomic]
+!add_map(Type, MyX, MyY, X, Y, UniqueString)[source(Ag)]
	: .my_name(Me) & map::myMap(Me)
<-
	.term2string(Ag,S);
	if(Type == goal){
		updateGoalMap(Me, MyX+X, MyY+Y, InsertedInCluster, IsANewCluster);
		if(IsANewCluster){
			if(S \== "self"){
				.send(Ag, askOne, map::available_to_evaluate(Res, X, Y), map::available_to_evaluate(Res, _, _))
				if(Res == 1){
					.send(Ag, achieve, map::evaluate(X, Y));
				}
			} elif(not common::my_role(goal_evaluator)){
				.send(Ag, achieve, map::evaluate(X, Y));
				//!map::evaluate(X, Y);
			}	
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
		.print("@@@@@ Adding dispenser type ",Type," Dispenser X ",MyX+X," Dispenser Y ",MyY+Y," Agent that requested ",Ag);
		.print("@@@@@ Old list of dispensers ",Dispensers);
	}
	if (S == "self") {
		!identification::remove_reasoning(UniqueString);
	}
	else {
		.send(Ag, achieve, identification::remove_reasoning(UniqueString));
	}
	.
@addmap2[atomic]
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
	