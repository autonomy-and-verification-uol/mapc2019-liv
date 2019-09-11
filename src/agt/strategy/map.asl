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
	.send(Leader, achieve, map::add_map(Type, MyX, MyY, X, Y));
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
	.send(Leader, achieve, map::add_map(goal, MyX, MyY, X, Y));
	.

-!map::evaluate(_, _) : true <- -map::evaluating_positions(_); -map::evaluating_vertexes; +exploration::explorer; !!exploration::explore([n,s,w,e]).
+!map::evaluate(GoalLocalX, GoalLocalY) :
	true
<-
	-exploration::explorer;
	!action::forget_old_action;
	+map::evaluating_positions([start(GoalLocalX, GoalLocalY)]);

	!map::find_cluster_origins(GoalLocalX, GoalLocalY);
	if(not map::evaluating_positions(_)){
		.fail;
	}
	
	+map::evaluating_vertexes;
	!map::evaluate_origin(n, Value1); 
	if(not map::evaluating_positions(_)){
		.fail;
	}
	!map::update_origin_evaluation(n, Value1);
	.print("OriginN evaluated as:", Value1);
	
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
	
	-map::evaluating_positions(_);
	-map::evaluating_vertexes;
	
	!action::forget_old_action;
	!map::get_clusters(Clusters);
	.print("Clusters: ", Clusters);
	
	+exploration::explorer;
	!!exploration::explore([n,s,w,e]);
	.

+!map::update_origin_evaluation(Side, Value) :
	map::myMap(Leader) & map::evaluating_positions(Positions) & .member(origin(Side, X, Y), Positions)
<-
	getMyPos(MyX, MyY);
	evaluateOrigin(Leader, MyX + X, MyY + Y, Value);
	.

+!map::evaluate_origin(Side, Value) :
	map::evaluating_positions(Positions) & .member(origin(Side, X, Y), Positions)
<-
	!retrieve::generate_helpers_position(origin(X, Y), Side, _, pos(V1X, V1Y), pos(V2X, V2Y));
	L1 = [vertex(Side, w, V1X, V1Y)|Positions];
	L2 = [vertex(Side, e, V2X, V2Y)|L1];
	-+map::evaluating_positions(L2);
	if(map::evaluating_positions(Pos)){
		.print(Pos);
	}
	!map::move_to_evaluating_pos(Side, w);
	if(map::evaluating_positions(_)){
		!map::move_to_evaluating_pos(Side, e);
		if(map::evaluating_positions(_)){
			Value = Side;
		}
	}
	.
-!map::evaluate_origin(_, Value) : true <- Value = bad.

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
	for(.member(vertex(OriginSide, VertexSide, X, Y), Positions)){
		!map::update_evaluating_positions_aux(vertex(OriginSide, VertexSide, X, Y), DiffX, DiffY);
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
+!map::update_evaluating_positions_aux(vertex(OriginSide, VertexSide, X, Y), DiffX, DiffY) :
	map::evaluating_positions(Positions) & .member(vertex(OriginSide, VertexSide, X, Y), Positions) 
<-
	.delete(vertex(OriginSide, VertexSide, X, Y), Positions, Positions1);
	-+map::evaluating_positions([vertex(OriginSide, VertexSide, X + DiffX, Y + DiffY)|Positions1]);
	.
+!map::update_evaluating_positions_aux(start(X, Y), DiffX, DiffY) :
	map::evaluating_positions(Positions) & .member(start(X, Y), Positions) 
<-
	.delete(start(X, Y), Positions, Positions1);
	-+map::evaluating_positions([start(X + DiffX, Y + DiffY)|Positions1]);
	.

+!map::move_to_evaluating_pos(OriginSide, VertexSide) :
	map::myMap(Leader) & map::evaluating_positions(Positions) & .member(start(X, Y), Positions)
<-
	getMyPos(MyX, MyY);
	getGoalClusters(Leader, Clusters);
	if(.member(cluster(_, GoalList), Clusters) & (.member(origin(_, MyX+X, MyY+Y), GoalList) | .member(goal(MyX+X, MyY+Y), GoalList)) &
		not .member(origin(_, _, _), GoalList)
	){
		!map::move_to_evaluating_pos_1(OriginSide, VertexSide);
	} else{
		-map::evaluating_positions(_);
		.print("Stop evaluating the cluster1");
	}
	.
+!map::move_to_evaluating_pos(OriginSide, VertexSide) :
	map::myMap(Leader) & map::evaluating_positions(Positions) & .member(origin(_, X, Y), Positions)
<-
	if(map::myMap(Leader1)){.print("Leader1: ", Leader1);}
	getMyPos(MyX, MyY);
	if(map::myMap(Leader2)){.print("Leader2: ", Leader2);}
	getGoalClusters(Leader, Clusters);
	if(map::myMap(Leader3)){.print("Leader3: ", Leader3);}
	if(.member(cluster(_, GoalList), Clusters) & (.member(origin(_, MyX+X, MyY+Y), GoalList) | .member(goal(MyX+X, MyY+Y), GoalList)) &
		.member(origin(boh, _, _), GoalList)
	){
		!map::move_to_evaluating_pos_1(OriginSide, VertexSide);
	} else{
		-map::evaluating_positions(_);
		if(map::myMap(Leader4)){.print("Leader4: ", Leader4);}
		.print("Stop evaluating the cluster2: (", MyX+X, ", ", MyY+Y, ") ", Clusters);
	}
	.
+!map::move_to_evaluating_pos_1(OriginSide, VertexSide) :
	map::evaluating_positions(Positions) & .member(start(0, 0), Positions)
<- 
	.delete(start(_, _), Positions, NewPositions);
	-+map::evaluating_positions(NewPositions);
	.
+!map::move_to_evaluating_pos_1(OriginSide, VertexSide) :
	map::evaluating_positions(Positions) & .member(vertex(OriginSide, VertexSide, 0, 0), Positions).
+!map::move_to_evaluating_pos_1(OriginSide, VertexSide) :
	map::evaluating_positions(Positions) & .member(start(X, Y), Positions) &
	retrieve::pick_direction(0, 0, X, Y, Direction)
<-
	!map::move_to_evaluating_pos_aux(Direction);
	!map::move_to_evaluating_pos(OriginSide, VertexSide);
	.
+!map::move_to_evaluating_pos_1(OriginSide, VertexSide) :
	map::evaluating_positions(Positions) & .member(vertex(OriginSide, VertexSide, X, Y), Positions) &
	retrieve::pick_direction(0, 0, X, Y, Direction)
<-
	
	if((math.abs(X)+math.abs(Y)) <= 5 & default::obstacle(X, Y)){
		.fail;
	}
	!map::move_to_evaluating_pos_aux(Direction);
	!map::move_to_evaluating_pos(OriginSide, VertexSide);
	.
+!map::move_to_evaluating_pos_aux(Direction) :
	true
<-
	if (exploration::check_obstacle_special_1(Direction, 1)) {
		.print(i_can_avoid(Direction, DirectionToGo));
		if(retrieve::i_can_avoid(Direction, DirectionToGo)){
			!retrieve::go_around_obstacle(Direction, DirectionToGo, MyX, MyY, 0, 20, DirectionObstacle1, 1)
			getMyPos(MyX1,MyY1);
			if(MyX == MyX1 & MyY == MyY1){
				for(.range(_, 1, 5) & .random(R) & .nth(math.floor(R*3.99), [n,s,w,e], Dir)){
					!retrieve::smart_move(Dir);
				}
			}
		} else{
			.fail;
		} 
	} else {
		!retrieve::smart_move(Direction);
		if(default::lastActionResult(failed_forbidden)){
			.fail;
		}
	}
	.

+!map::find_cluster_origins(GoalLocalX, GoalLocalY) :
	true
<-
	!map::move_to_evaluating_pos(start, start);
	!map::find_cluster_origin(n); 
	!map::find_cluster_origin(e); 
	!map::find_cluster_origin(s); 
	!map::find_cluster_origin(w);
	.
+!map::find_cluster_origin(n) :
	default::goal(GX, GY) & GY < 0 & GX > 0
<-
	!retrieve::smart_move(e);
	!retrieve::smart_move(n);
	!map::find_cluster_origin(n);
	.
+!map::find_cluster_origin(n) :
	default::goal(GX, GY) & GY < 0 & GX < 0
<-
	!retrieve::smart_move(w);
	!retrieve::smart_move(n);
	!map::find_cluster_origin(n);
	.
+!map::find_cluster_origin(n) :
	default::goal(GX, GY) & GY < 0
<-
	!retrieve::smart_move(n);
	!map::find_cluster_origin(n);
	.
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
+!add_map(Type, MyX, MyY, X, Y)[source(Ag)]
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
	