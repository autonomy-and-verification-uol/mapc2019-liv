/* Initial beliefs and rules */

pick_direction(MyX, MyY, TargetX, TargetY, Direction) :-
	//weight_obstacles(n, WeightN) &
	//weight_obstacles(s, WeightS) &
	//weight_obstacles(w, WeightW) &
	//weight_obstacles(e, WeightE) &
	DistanceN = math.abs(MyX - TargetX) + math.abs((MyY-1) - TargetY) & // + WeightN &
	DistanceS = math.abs(MyX - TargetX) + math.abs((MyY+1) - TargetY) & // + WeightS &
	DistanceW = math.abs((MyX-1) - TargetX) + math.abs(MyY - TargetY) & // + WeightW &
	DistanceE = math.abs((MyX+1) - TargetX) + math.abs(MyY - TargetY) & // + WeightE &
	pick_direction_aux(DistanceN, DistanceS, DistanceW, DistanceE, Direction).
pick_direction_aux(DistanceN, DistanceS, DistanceW, DistanceE, n) :-
	//(retrieve::lastlastActionParam([Dir]) & (not(.ground(Dir)) | Dir \== n | not(default::lastActionParams([s])))) & 
	//(not(default::lastAction(move)) | not(default::lastActionParams([n])) | default::lastActionResult(success)) & 
	DistanceN <= DistanceS & DistanceN <= DistanceW & DistanceN <= DistanceE.
pick_direction_aux(DistanceN, DistanceS, DistanceW, DistanceE, s) :-
	//(retrieve::lastlastActionParam([Dir]) & (not(.ground(Dir)) | Dir \== s | not(default::lastActionParams([n])))) & 
	//(not(default::lastAction(move)) | not(default::lastActionParams([s])) | default::lastActionResult(success)) & 
	DistanceS <= DistanceN & DistanceS <= DistanceW & DistanceS <= DistanceE.
pick_direction_aux(DistanceN, DistanceS, DistanceW, DistanceE, w) :-
	//(retrieve::lastlastActionParam([Dir]) & (not(.ground(Dir)) | Dir \== w | not(default::lastActionParams([e])))) & 
	///(not(default::lastAction(move)) | not(default::lastActionParams([w])) | default::lastActionResult(success)) & 
	DistanceW <= DistanceN & DistanceW <= DistanceS & DistanceW <= DistanceE.
pick_direction_aux(DistanceN, DistanceS, DistanceW, DistanceE, e) :-
	//(retrieve::lastlastActionParam([Dir]) & (not(.ground(Dir)) | Dir \== e | not(default::lastActionParams([w])))) & 
	//(not(default::lastAction(move)) | not(default::lastActionParams([e])) | default::lastActionResult(success)) & 
	DistanceE <= DistanceN & DistanceE <= DistanceS & DistanceE <= DistanceW.
pick_direction_aux(DistanceN, DistanceS, DistanceW, DistanceE, Direction) :-	
	.random(R) & .nth(math.floor(R*3.99), [n, s, w, e], Direction).
	
i_can_avoid(n, w) :-
	(
		(not(default::obstacle(-1, 0)) & not(default::obstacle(-1, -1)) & not(default::obstacle(-1, -2))) |
		(not(default::obstacle(-1, 0)) & not(default::obstacle(-2, 0)) & not(default::obstacle(-2, -1)) & not(default::obstacle(-2, -2))) |
		(not(default::obstacle(-1, 0)) & not(default::obstacle(-2, 0)) & not(default::obstacle(-3, 0)) & not(default::obstacle(-3, -1)) & not(default::obstacle(-3, -2)))
	).
i_can_avoid(n, e) :-
	(
		(not(default::obstacle(1, 0)) & not(default::obstacle(1, -1)) & not(default::obstacle(1, -2)) & not(default::thing(1,-2, marker, clear))) |
		(not(default::obstacle(1, 0)) & not(default::obstacle(2, 0)) & not(default::obstacle(2, -1)) & not(default::obstacle(2, -2))) |
		(not(default::obstacle(1, 0)) & not(default::obstacle(2, 0)) & not(default::obstacle(3, 0)) & not(default::obstacle(3, -1)) & not(default::obstacle(3, -2)))
	).
i_can_avoid(s, w) :-
	(
		(not(default::obstacle(-1, 0)) & not(default::obstacle(-1, 1)) & not(default::obstacle(-1, 2)) & not(default::thing(-1,2, marker, clear))) |
		(not(default::obstacle(-1, 0)) & not(default::obstacle(-2, 0)) & not(default::obstacle(-2, 1)) & not(default::obstacle(-2, 2))) |
		(not(default::obstacle(-1, 0)) & not(default::obstacle(-2, 0)) & not(default::obstacle(-3, 0)) & not(default::obstacle(-3, 1)) & not(default::obstacle(-3, 2)))
	).
i_can_avoid(s, e) :-
	(
		(not(default::obstacle(1, 0)) & not(default::obstacle(1, 1)) & not(default::obstacle(1, 2)) & not(default::thing(1,2, marker, clear))) |
		(not(default::obstacle(1, 0)) & not(default::obstacle(2, 0)) & not(default::obstacle(2, 1)) & not(default::obstacle(2, 2))) |
		(not(default::obstacle(1, 0)) & not(default::obstacle(2, 0)) & not(default::obstacle(3, 0)) & not(default::obstacle(3, 1)) & not(default::obstacle(3, 2)))
	).
i_can_avoid(w, n) :-
	(
		(not(default::obstacle(0, -1)) & not(default::obstacle(-1, -1)) & not(default::obstacle(-2, -1))) |
		(not(default::obstacle(0, -1)) & not(default::obstacle(0, -2)) & not(default::obstacle(-1, -2)) & not(default::obstacle(-2, -2))) |
		(not(default::obstacle(0, -1)) & not(default::obstacle(0, -2)) & not(default::obstacle(0, -3)) & not(default::obstacle(-1, -3)) & not(default::obstacle(-2, -3)))
	).
i_can_avoid(w, s) :-
	(
		(not(default::obstacle(0, 1)) & not(default::obstacle(-1, 1)) & not(default::obstacle(-2, 1))) |
		(not(default::obstacle(0, 1)) & not(default::obstacle(0, 2)) & not(default::obstacle(-1, 2)) & not(default::obstacle(-2, 2))) |
		(not(default::obstacle(0, 1)) & not(default::obstacle(0, 2)) & not(default::obstacle(0, 3)) & not(default::obstacle(-1, 3)) & not(default::obstacle(-2, 3)))
	).
i_can_avoid(e, n) :-
	(
		(not(default::obstacle(0, -1)) & not(default::obstacle(1, -1)) & not(default::obstacle(2, -1))) |
		(not(default::obstacle(0, -1)) & not(default::obstacle(0, -2)) & not(default::obstacle(1, -2)) & not(default::obstacle(2, -2))) |
		(not(default::obstacle(0, -1)) & not(default::obstacle(0, -2)) & not(default::obstacle(0, -3)) & not(default::obstacle(1, -3)) & not(default::obstacle(2, -3)))
	).
i_can_avoid(e, s) :-
	(
		(not(default::obstacle(0, 1)) & not(default::obstacle(1, 1)) & not(default::obstacle(2, 1))) |
		(not(default::obstacle(0, 1)) & not(default::obstacle(0, 2)) & not(default::obstacle(1, 2)) & not(default::obstacle(2, 2))) |
		(not(default::obstacle(0, 1)) & not(default::obstacle(0, 2)) & not(default::obstacle(0, 3)) & not(default::obstacle(1, 3)) & not(default::obstacle(2, 3)))
	).

count_attached_blocks(n, 0) :-
	not(default::attached(0, -1)).
count_attached_blocks(n, 1) :-
	default::attached(0, -1) & not(default::attached(0, -2)).
count_attached_blocks(n, 2) :-
	default::attached(0, -1) & default::attached(0, -2) & 
	not(default::attached(0, -3)).
count_attached_blocks(n, 3) :-
	default::attached(0, -1) & default::attached(0, -2) & default::attached(0, -3) &
	not(default::attached(0, -4)).
count_attached_blocks(n, 4) :-
	default::attached(0, -1) & default::attached(0, -2) & default::attached(0, -3) &  default::attached(0, -4) &
	not(default::attached(0, -5)).
count_attached_blocks(n, 5) :-
	default::attached(0, -1) & default::attached(0, -2) & default::attached(0, -3) &  default::attached(0, -4) & default::attached(0, -5).
count_attached_blocks(s, 0) :-
	not(default::attached(0, 1)).
count_attached_blocks(s, 1) :-
	default::attached(0, 1) & not(default::attached(0, 2)).
count_attached_blocks(s, 2) :-
	default::attached(0, 1) & default::attached(0, 2) & 
	not(default::attached(0, 3)).
count_attached_blocks(s, 3) :-
	default::attached(0, 1) & default::attached(0, 2) & default::attached(0, 3) &
	not(default::attached(0, 4)).
count_attached_blocks(s, 4) :-
	default::attached(0, 1) & default::attached(0, 2) & default::attached(0, 3) &  default::attached(0, 4) &
	not(default::attached(0, 5)).
count_attached_blocks(s, 5) :-
	default::attached(0, 1) & default::attached(0, 2) & default::attached(0, 3) &  default::attached(0, 4) & default::attached(0, 5).
count_attached_blocks(w, 0) :-
	not(default::attached(-1, 0)).
count_attached_blocks(w, 1) :-
	default::attached(-1, 0) & not(default::attached(-2, 0)).
count_attached_blocks(w, 2) :-
	default::attached(-1, 0) & default::attached(-2, 0) & 
	not(default::attached(-3, 0)).
count_attached_blocks(w, 3) :-
	default::attached(-1, 0) & default::attached(-2, 0) & default::attached(-3, 0) &
	not(default::attached(-4, 0)).
count_attached_blocks(w, 4) :-
	default::attached(-1, 0) & default::attached(-2, 0) & default::attached(-3, 0) &  default::attached(-4, 0) &
	not(default::attached(-5, 0)).
count_attached_blocks(w, 5) :-
	default::attached(-1, 0) & default::attached(-2, 0) & default::attached(-3, 0) &  default::attached(-4, 0) & default::attached(-5, 0).
count_attached_blocks(e, 0) :-
	not(default::attached(1, 0)).
count_attached_blocks(e, 1) :-
	default::attached(1, 0) & not(default::attached(2, 0)).
count_attached_blocks(e, 2) :-
	default::attached(1, 0) & default::attached(2, 0) & 
	not(default::attached(3, 0)).
count_attached_blocks(e, 3) :-
	default::attached(1, 0) & default::attached(2, 0) & default::attached(3, 0) &
	not(default::attached(4, 0)).
count_attached_blocks(e, 4) :-
	default::attached(1, 0) & default::attached(2, 0) & default::attached(3, 0) &  default::attached(4, 0) &
	not(default::attached(5, 0)).
count_attached_blocks(e, 5) :-
	default::attached(1, 0) & default::attached(2, 0) & default::attached(3, 0) &  default::attached(4, 0) & default::attached(5, 0).

i_have_attached_block :-
	default::attached(0, -1) | default::attached(0, 1) | default::attached(-1, 0) | default::attached(1, 0).

opposite_direction(n, s).
opposite_direction(s, n).
opposite_direction(w, e).
opposite_direction(e, w).
other_cardinals(n, [w,e]).
other_cardinals(s, [w,e]).
other_cardinals(w, [n,s]).
other_cardinals(e, [n,s]).

get_rotation(n, w, ccw).
get_rotation(n, e, cw).
get_rotation(s, w, cw).
get_rotation(s, e, ccw).
get_rotation(w, n, cw).
get_rotation(w, s, ccw).
get_rotation(e, n, ccw).
get_rotation(e, s, cw).

get_rel_pos(n, 0, -1).
get_rel_pos(s, 0, 1).
get_rel_pos(w, -1, 0).
get_rel_pos(e, 1, 0).

neighbour_to_dispenser(MyX, MyY, TargetX, TargetY, n) :-
	MyX == TargetX & MyY == (TargetY+1).
neighbour_to_dispenser(MyX, MyY, TargetX, TargetY, s) :-
	MyX == TargetX & MyY == (TargetY-1).
neighbour_to_dispenser(MyX, MyY, TargetX, TargetY, e) :-
	MyX == (TargetX-1) & MyY == TargetY.
neighbour_to_dispenser(MyX, MyY, TargetX, TargetY, w) :-
	MyX == (TargetX+1) & MyY == TargetY.

+!retrieve::generate_helpers_position(origin(X, Y), 
	[
		pos(X-9, Y-12),
		pos(X-6, Y-12),
		pos(X-3, Y-12),
		pos(X, Y-12),
		pos(X+3, Y-12),
		pos(X+6, Y-12),
		pos(X+9, Y-12),
		pos(X-9, Y-8),
		pos(X-6, Y-8),
		pos(X-3, Y-8),
		pos(X, Y-8),
		pos(X+3, Y-8),
		pos(X+6, Y-8),
		pos(X+9, Y-8),
		pos(X-9, Y-4),
		pos(X-6, Y-4),
		pos(X-3, Y-4),
		pos(X, Y-4),
		pos(X+3, Y-4),
		pos(X+6, Y-4),
		pos(X+9, Y-4)
	]).

+!retrieve::retrieve_block :
	true
<-
	!retrieve::decide_block_type_flat(Type); .print("I decided to get block type: ", Type);
	!retrieve::get_nearest_dispenser(Type, dispenser(Type, X, Y));
	.print("The nearest dispenser is: ", dispenser(Type, X, Y));
	-retrieve::target(_, _);
	+retrieve::target(X, Y);
	.print("Target added: ", X, " ", Y);
	!retrieve::fetch_block_to_goal.

-!retrieve::retrieve_block : retrieve::retriever <- !!retrieve::retrieve_block.
-!retrieve::retrieve_block : true <- true.

+!retrieve::decide_block_type_flat(Type) : 
	true
<-
	!map::get_dispensers(Dispensers);
	.setof(Type, .member(dispenser(Type, _, _), Dispensers), Types1);
	.shuffle(Types1, Types);
	.nth(0, Types, Type);
	.

+!retrieve::decide_block_type(Type) : 
	true
<- 
	.findall(block_count(Type, Count),(retrieve::block_count(Type, Count)), BlocksCount);
	?retrieve::how_many_counts(BlocksCount, Tot);
	!retrieve::create_prob_range(BlocksCount, 0, BlocksRange);
	!retrieve::pick_block(Tot, BlocksRange, Type).
	
+?retrieve::how_many_counts([], 0) : true <- true.
+?retrieve::how_many_counts([block_count(Type, Count)|BlocksCount], Tot) : 
	true
<- 
	?retrieve::how_many_counts(BlocksCount, Tot1);
	Tot = Tot1 + Count.

+!retrieve::create_prob_range([], _, []) : true <- true.
+!retrieve::create_prob_range([block_count(Type, Count)|BlocksCount], Min, [block_range(Type, Min, Max)|BlocksRange]) : 
	true 
<- 
	Max = Min + Count;
	!retrieve::create_prob_range(BlocksCount, Max, BlocksRange).

+!retrieve::pick_block(Tot, BlocksRange, Block) :
	true
<-
	.random(X);
	Xnorm = X * Tot;
	.print("BlocksRange: ", BlocksRange);
	!retrieve::pick_block_aux(Xnorm, BlocksRange, Block).
+!retrieve::pick_block_aux(X, [block_range(Type, Min, Max)|BlocksRange], Type) : 
	X >= Min & X < Max
<- 
	true.
+!retrieve::pick_block_aux(X, [block_range(Type, Min, Max)|BlocksRange], Block) : 
	true
<- 
	!retrieve::pick_block_aux(X, BlocksRange, Block).
	
+!retrieve::get_nearest_dispenser(Type, Dispenser) : 
	true
<-
	!map::get_dispensers(Dispensers); .print("Dispensers: ", Dispensers);
	!retrieve::get_nearest_dispenser_aux1(Dispensers, Type, Dispenser).
+!retrieve::get_nearest_dispenser_aux1(Dispensers, Type, dispenser(Type, X, Y)) :
	true
<-
	getMyPos(MyX,MyY);
	.findall(dispenser(Type, X, Y, Distance), (.member(dispenser(Type, X, Y), Dispensers) & (Distance = math.abs(MyX - X) + math.abs(MyY - Y))), DispensersDist);
	!retrieve::get_nearest_dispenser_aux2(DispensersDist, dispenser(Type, X, Y, _)).
+!retrieve::get_nearest_dispenser_aux2([], dispenser(_, _, _, 100000000000)) : true <- true.
+!retrieve::get_nearest_dispenser_aux2([dispenser(Type, X, Y, Distance)|DispensersDist], ClosestDispenser) :
	true
<- 
	!retrieve::get_nearest_dispenser_aux2(DispensersDist, Dispenser);
	!retrieve::select_the_closest(dispenser(Type, X, Y, Distance), Dispenser, ClosestDispenser).
+!retrieve::select_the_closest(dispenser(Type1, X1, Y1, Distance1), dispenser(Type2, X2, Y2, Distance2), dispenser(Type1, X1, Y1, Distance1)) :
	Distance1 <= Distance2
<- 
	true.
+!retrieve::select_the_closest(dispenser(Type1, X1, Y1, Distance1), dispenser(Type2, X2, Y2, Distance2), dispenser(Type2, X2, Y2, Distance2)) :
	Distance2 <= Distance1
<- 
	true.

+!create_and_attach_block(n) :
	default::thing(0, -1, dispenser, _)
<- 
	!create_and_attach_block(n, 0, -1).
+!create_and_attach_block(s) :
	default::thing(0, 1, dispenser, _)
<- 
	!create_and_attach_block(s, 0, 1).
+!create_and_attach_block(w) :
	default::thing(-1, 0, dispenser, _)
<- 
	!create_and_attach_block(w, -1, 0).
+!create_and_attach_block(e) :
	default::thing(1, 0, dispenser, _)
<- 
	!create_and_attach_block(e, 1, 0).

+!create_and_attach_block(Direction, DispX, DispY) :
	true
<-
	.print("!create_and_attach_block(Direction, DispX, DispY)");
	+retrieve::fetching_block;
	-retrieve::attach_completed;
	while(not retrieve::attach_completed){
		!action::request(Direction);
		if(default::lastActionResult(failed_target)){
			.fail;
		}
		while(not default::lastActionResult(success)){
			!action::request(Direction);
		}
		!action::attach(Direction);
		if(default::lastActionResult(success) & default::attached(DispX, DispY)){
			+retrieve::attach_completed;
		}
	}
	-retrieve::fetching_block.
/*
@update_target[atomic]
+!retrieve::update_target :
	.my_name(Me) & map::myMap(Leader)
<- 
	getTargetGoal(Ag, _, _);
	if(.ground(Ag)){
		!map::get_clusters(Clusters);
		!stop::choose_the_biggest_cluster(Clusters, cluster(ClusterId, GoalList));
		.member(origin(GoalX, GoalY), GoalList);
		setTargetGoal(0, Me, GoalX, GoalY);
		.broadcast(achieve, retrieve::update_target_aux(Leader));
	}
	.
@update_target1[atomic]
+!retrieve::update_target_aux(Leader)[source(Ag)] :
	map::myMap(Leader) & .my_name(Me) & Me \== Ag
<-
	getTargetGoal(_, GoalX, GoalY);
	-+retrieve::target(GoalX, GoalY);
	.
@update_target2[atomic]
+!retrieve::update_target_aux(_)[source(Ag)].
*/

+!retrieve::fetch_block_to_goal : 
	retrieve::retriever
<- 
	getMyPos(MyX,MyY);
	!retrieve::fetch_block_to_goal_aux(MyX, MyY).
+!retrieve::fetch_block_to_goal_aux(MyX, MyY) :	
	retrieve::retriever &
	retrieve::target(TargetX, TargetY) &
	neighbour_to_dispenser(MyX, MyY, TargetX, TargetY, Direction) &
	.my_name(Me)
<-
	!retrieve::create_and_attach_block(Direction);
	getTargetGoal(Ag, GoalX, GoalY);
	.print("Chosen Goal position: ", GoalX, GoalY);
	if(stop::first_to_stop(Me)){
		.print("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAaa");
		MyGoalX = GoalX; MyGoalY = GoalY;
	} else{
		!retrieve::generate_helpers_position(origin(GoalX, GoalY), HelpersPos);
		.random(R); .length(HelpersPos, NHelpersPos); R1 = R * (NHelpersPos-1);
		.nth(R1, HelpersPos, pos(MyGoalX, MyGoalY));
	}
	-+retrieve::target(MyGoalX, MyGoalY);
	!retrieve::move_to_goal.
+!retrieve::fetch_block_to_goal_aux(MyX, MyY) :	
	retrieve::retriever &
	retrieve::target(TargetX, TargetY) &
	pick_direction(MyX, MyY, TargetX, TargetY, Direction) 
<-		
	.print("TargetX: ", TargetX, " TargetY: ", TargetY);
	if (exploration::check_obstacle_special_1(Direction)) {
		if(i_can_avoid(Direction, DirectionToGo)){
			.print("GO AROUND OBSTACLE: ", i_can_avoid(Direction, DirectionToGo));
			!retrieve::go_around_obstacle(Direction, DirectionToGo, MyX, MyY, 0, 20, DirectionObstacle1, 1)
			getMyPos(MyX1,MyY1);
			if(MyX == MyX1 & MyY == MyY1){
				for(.range(_, 1, 5) & .random(R) & .nth(math.floor(R*3.99), [n,s,w,e], Dir)){
					!retrieve::smart_move(Dir);
				}
			}
			.print("OBSTACLE AVOIDED");
		} elif(default::energy(Energy) & Energy >= 30 & not exploration::check_agent_special(Direction)){
			!retrieve::smart_clear(Direction);
			if(retrieve::res(0)){
				!retrieve::go_around_obstacle(Direction, 20);
			}
		} else{
			!retrieve::go_around_obstacle(Direction, 20);
		}
	} else {
		!retrieve::smart_move(Direction);
	}
	!retrieve::fetch_block_to_goal.
	
-retrieve::fetch_block_to_goal : retrieve::retriever <- !!retrieve::fetch_block_to_goal.

+!retrieve::smart_move(Direction) :
	true
<-
	.print("Direction: ", Direction);
	if(Direction == n){
		if(default::attached(1, 0)){
			!action::rotate(ccw);
		}
		elif(default::attached(-1, 0)){
			!action::rotate(cw);
		}
		elif(default::attached(0, 1)){
			if(not(default::thing(1, 0, _, _)) & not(default::obstacle(1, 0))){
				!action::rotate(ccw);
				!action::rotate(ccw);
			}	
			elif(not(default::thing(-1, 0, _, _)) & not(default::obstacle(-1, 0))){
				!action::rotate(cw);
				!action::rotate(cw);
			}
		}
	}
	elif(Direction == s){
		if(default::attached(1, 0)){
			!action::rotate(cw);
		}
		elif(default::attached(-1, 0)){
			!action::rotate(ccw);
		}
		elif(default::attached(0, -1)){
			if(not(default::thing(1, 0, _, _)) & not(default::obstacle(1, 0))){
				!action::rotate(cw);
				!action::rotate(cw);
			}	
			elif(not(default::thing(-1, 0, _, _)) & not(default::obstacle(-1, 0))){
				!action::rotate(ccw);
				!action::rotate(ccw);
			}
		}
	}
	elif(Direction == w){
		if(default::attached(0, 1)){
			!action::rotate(cw);
		}
		elif(default::attached(0, -1)){
			!action::rotate(ccw);
		}
		elif(default::attached(1, 0)){
			if(not(default::thing(0, 1, _, _)) & not(default::obstacle(0, 1))){
				!action::rotate(cw);
				!action::rotate(cw);
			}	
			elif(not(default::thing(0, -1, _, _)) & not(default::obstacle(0, -1))){
				!action::rotate(ccw);
				!action::rotate(ccw);
			}
		}
	}
	else{
		if(default::attached(0, 1)){
			!action::rotate(ccw);
		}
		elif(default::attached(0, -1)){
			!action::rotate(cw);
		}
		elif(default::attached(-1, 0)){
			if(not(default::thing(0, 1, _, _)) & not(default::obstacle(0, 1))){
				!action::rotate(ccw);
				!action::rotate(ccw);
			}	
			elif(not(default::thing(0, -1, _, _)) & not(default::obstacle(0, -1))){
				!action::rotate(cw);
				!action::rotate(cw);
			}
		}	
	}
	!action::move(Direction).

+!retrieve::go_around_obstacle(DirectionObstacle, Threshold) :
	true
<-
	getMyPos(MyX,MyY);
	if (DirectionObstacle == n | DirectionObstacle == s) {
		.random(R);
		if(R < 0.5){
			Dir = w;
		} else{
			Dir = e;
		}
		!retrieve::go_around_obstacle(DirectionObstacle, Dir, MyX, MyY, 0, Threshold, DirectionObstacle1, 1);
	} else {
		.random(R);
		if(R < 0.5){
			Dir = n;
		} else{
			Dir = s;
		}
		!retrieve::go_around_obstacle(DirectionObstacle, Dir, MyX, MyY, 0, Threshold, DirectionObstacle1, 1);
	}
	.
	
+!retrieve::go_around_obstacle(DirectionObstacle, DirectionToGo, MyX, MyY, Attempts, Threshold, OppositeDirection, _) :
	retrieve::target(TargetX, TargetY) &
	pick_direction(MyX, MyY, TargetX, TargetY, Direction) & Direction \== DirectionObstacle & 
	opposite(DirectionToGo, DirectionToGo1) & Direction \== DirectionToGo1
<-
	.print("here1");
	true.
+!retrieve::go_around_obstacle(DirectionObstacle, DirectionToGo, MyX, MyY, Attempts, Threshold, OppositeDirection, Count) :
	not(exploration::check_obstacle(DirectionObstacle)) & not(exploration::check_agent(DirectionObstacle)) &
	opposite_direction(DirectionToGo, OppositeDirection)
<-
	.print("here2");
	if(Count > 0){
		!retrieve::smart_move(DirectionObstacle);
		getMyPos(MyX1,MyY1);
		!retrieve::go_around_obstacle(OppositeDirection, DirectionObstacle, MyX, MyY, 0, Threshold, _, Count-1);
	}
	.
+!retrieve::go_around_obstacle(DirectionObstacle, DirectionToGo, MyX, MyY, Attempts, Threshold, ActualDirection, Count) :
	 Attempts < Threshold & not(exploration::check_obstacle_special_1(DirectionToGo))
<-
	.print("here3");
	!retrieve::smart_move(DirectionToGo);
	getMyPos(MyX1,MyY1);
	!retrieve::go_around_obstacle(DirectionObstacle, DirectionToGo, MyX1, MyY1, Attempts+1, Threshold, ActualDirection, Count).
+!retrieve::go_around_obstacle(DirectionObstacle, DirectionToGo, MyX, MyY, Attempts, Threshold, ActualDirection, Count) :
	true
<-
	if(default::energy(Energy) & Energy >= 30){
		!retrieve::smart_clear(DirectionObstacle);
		if(retrieve::res(0)){
			!action::move(z);
			!retrieve::go_around_obstacle(DirectionObstacle, DirectionToGo, MyX, MyY, Attempts, Threshold, ActualDirection, Count);
		}
	} else {
		//.fail
		!action::move(z);
		!retrieve::go_around_obstacle(DirectionObstacle, DirectionToGo, MyX, MyY, Attempts, Threshold, ActualDirection, Count);
	}.

+!retrieve::move_to_goal : 
	retrieve::retriever
<- 
	getMyPos(MyX,MyY);
	!retrieve::move_to_goal_aux(MyX, MyY).
+!retrieve::move_to_goal_aux(TargetX, TargetY) :	
	retrieve::retriever & retrieve::target(TargetX, TargetY)
<-
	if(default::attached(0, -1)){
		!action::rotate(cw);
		!retrieve::move_to_goal_aux(TargetX, TargetY);
	} elif(default::attached(-1, 0)){
		!action::rotate(ccw);
		!retrieve::move_to_goal_aux(TargetX, TargetY);
	} elif(default::attached(1, 0)){
		!action::rotate(cw);
		!retrieve::move_to_goal_aux(TargetX, TargetY);
	} else{
		.my_name(Me);
		if  (stop::first_to_stop(Me)) {
			+task::origin;
		}
		else {
			?default::thing(0,1,block,Type);
			addAvailableAgent(Me,Type);
		}
		!default::always_skip;
	}
	.
	
+!retrieve::move_to_goal_aux(MyX, MyY) :
	retrieve::retriever & .my_name(Me) & not(stop::first_to_stop(Me)) & retrieve::target(TargetX, TargetY) &
	(math.abs(MyX - TargetX) + math.abs(MyY - TargetY)) <= 3 &
	pick_direction(MyX, MyY, TargetX, TargetY, Direction) & exploration::check_agent_special(Direction)
<-
	getTargetGoal(_, GoalX, GoalY);
	!retrieve::generate_helpers_position(origin(GoalX, GoalY), HelpersPos);
	.nth(Pos, HelpersPos, pos(TargetX, TargetY));
	.length(HelpersPos, NHelpersPos);
	if(Pos == (NHelpersPos-1)){
		Pos1 = 0;
	} else{
		Pos1 = Pos + 1;
	}
	.nth(Pos1, HelpersPos, pos(NewTargetX, NewTargetY));
	-+retrieve::target(NewTargetX, NewTargetY)
	!retrieve::move_to_goal_aux(MyX, MyY);
	.
+!retrieve::move_to_goal_aux(MyX, MyY) :	
	retrieve::retriever & retrieve::target(TargetX, TargetY) & 
	pick_direction(MyX, MyY, TargetX, TargetY, Direction) & 
	i_have_attached_block
<-
	.print("TargetX: ", TargetX, " TargetY: ", TargetY);
	if (exploration::check_obstacle_special_1(Direction)) {
		if(i_can_avoid(Direction, DirectionToGo)){
			.print("GO AROUND OBSTACLE");
			!retrieve::go_around_obstacle(Direction, DirectionToGo, MyX, MyY, 0, 20, DirectionObstacle1, 1);
			getMyPos(MyX1,MyY1);
			if(MyX == MyX1 & MyY == MyY1){
				for(.range(_, 1, 5) & .random(R) & .nth(math.floor(R*3.99), [n,s,w,e], Dir)){
					!retrieve::smart_move(Dir);
				}
			}
			.print("OBSTACLE AVOIDED");
		} elif(default::energy(Energy) & Energy >= 30 & not exploration::check_agent_special(Direction)){
			!retrieve::smart_clear(Direction);
			if(retrieve::res(0)){
				!retrieve::go_around_obstacle(Direction, 20);
			}
		} else{
			!retrieve::go_around_obstacle(Direction, 20);
		}
		!retrieve::move_to_goal;
	} else {
		.print("I do not see any obstacle");
		!retrieve::smart_move(Direction);
		!retrieve::move_to_goal;
	}
	.
+!retrieve::move_to_goal_aux(MyX, MyY) :
	not i_have_attached_block &
	default::thing(0, -1, block, _)
<-
	!action::attach(n);
	!retrieve::move_to_goal;
	.
+!retrieve::move_to_goal_aux(MyX, MyY) :
	not i_have_attached_block &
	default::thing(0, 1, block, _)
<-
	!action::attach(s);
	!retrieve::move_to_goal;
	.
+!retrieve::move_to_goal_aux(MyX, MyY) :
	not i_have_attached_block &
	default::thing(-1, 0, block, _)
<-
	!action::attach(w);
	!retrieve::move_to_goal;
	.
+!retrieve::move_to_goal_aux(MyX, MyY) :
	not i_have_attached_block &
	default::thing(1, 0, block, _)
<-
	!action::attach(e);
	!retrieve::move_to_goal;
	.
+!retrieve::move_to_goal_aux(MyX, MyY) :
	not i_have_attached_block
<-
	!retrieve::retrieve_block;
	.

-!retrieve::move_to_goal : retrieve::retriever <- !!retrieve::move_to_goal.
	
+!retrieve::smart_clear(Direction) :
	default::energy(Energy) & Energy >= 30
<-
	-res(_);
	.print("CLEAR1");
	if(Direction == n){
		if(default::attached(0, -1)){
			ClearX = 0; ClearY = -3
		} else{
			ClearX = 0; ClearY = -2
		}
	}
	elif(Direction == s){
		if(default::attached(0, 1)){
			ClearX = 0; ClearY = 3
		} else{
			ClearX = 0; ClearY = 2
		}
	}
	elif(Direction == w){
		if(default::attached(-1, 0)){
			ClearX = -3; ClearY = 0
		} else{
			ClearX = -2 ClearY = 0
		}
	}
	else{
		if(default::attached(1, 0)){
			ClearX = 3; ClearY = 0
		} else{
			ClearX = 2 ClearY = 0
		}
	}
	for(.range(I, 1, 3) & not retrieve::res(Res)){
		if(not default::thing(ClearX, ClearY, block, _) & 
			not default::thing(ClearX-1, ClearY, block, _) &
			not default::thing(ClearX+1, ClearY, block, _) &
			not default::thing(ClearX, ClearY-1, block, _) &
			not default::thing(ClearX, ClearY+1, block, _)
		){
			!action::clear(ClearX, ClearY);
		} else{
			+res(0);
		}
	}
	if(not retrieve::res(Res)){
		if(not default::lastActionResult(success)){
			+res(0);
		} else{
			+res(1);
		}
	}
	.

	
	
	
	