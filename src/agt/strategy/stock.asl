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
i_can_avoid(s, e) :-
	(
		(not(default::obstacle(1, 0)) & not(default::obstacle(1, 1)) & not(default::obstacle(1, 2)) & not(default::thing(1,2, marker, clear))) |
		(not(default::obstacle(1, 0)) & not(default::obstacle(2, 0)) & not(default::obstacle(2, 1)) & not(default::obstacle(2, 2))) |
		(not(default::obstacle(1, 0)) & not(default::obstacle(2, 0)) & not(default::obstacle(3, 0)) & not(default::obstacle(3, 1)) & not(default::obstacle(3, 2)))
	).
i_can_avoid(s, w) :-
	(
		(not(default::obstacle(-1, 0)) & not(default::obstacle(-1, 1)) & not(default::obstacle(-1, 2)) & not(default::thing(-1,2, marker, clear))) |
		(not(default::obstacle(-1, 0)) & not(default::obstacle(-2, 0)) & not(default::obstacle(-2, 1)) & not(default::obstacle(-2, 2))) |
		(not(default::obstacle(-1, 0)) & not(default::obstacle(-2, 0)) & not(default::obstacle(-3, 0)) & not(default::obstacle(-3, 1)) & not(default::obstacle(-3, 2)))
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
i_can_avoid(e, s) :-
	(
		(not(default::obstacle(0, 1)) & not(default::obstacle(1, 1)) & not(default::obstacle(2, 1))) |
		(not(default::obstacle(0, 1)) & not(default::obstacle(0, 2)) & not(default::obstacle(1, 2)) & not(default::obstacle(2, 2))) |
		(not(default::obstacle(0, 1)) & not(default::obstacle(0, 2)) & not(default::obstacle(0, 3)) & not(default::obstacle(1, 3)) & not(default::obstacle(2, 3)))
	).
i_can_avoid(e, n) :-
	(
		(not(default::obstacle(0, -1)) & not(default::obstacle(1, -1)) & not(default::obstacle(2, -1))) |
		(not(default::obstacle(0, -1)) & not(default::obstacle(0, -2)) & not(default::obstacle(1, -2)) & not(default::obstacle(2, -2))) |
		(not(default::obstacle(0, -1)) & not(default::obstacle(0, -2)) & not(default::obstacle(0, -3)) & not(default::obstacle(1, -3)) & not(default::obstacle(2, -3)))
	).


count_attached_blocks(n, 0) :-
	not(retrieve::block(0, -1)).
count_attached_blocks(n, 1) :-
	retrieve::block(0, -1) & not(retrieve::block(0, -2)).
count_attached_blocks(n, 2) :-
	retrieve::block(0, -1) & retrieve::block(0, -2) & 
	not(retrieve::block(0, -3)).
count_attached_blocks(n, 3) :-
	retrieve::block(0, -1) & retrieve::block(0, -2) & retrieve::block(0, -3) &
	not(retrieve::block(0, -4)).
count_attached_blocks(n, 4) :-
	retrieve::block(0, -1) & retrieve::block(0, -2) & retrieve::block(0, -3) &  retrieve::block(0, -4) &
	not(retrieve::block(0, -5)).
count_attached_blocks(n, 5) :-
	retrieve::block(0, -1) & retrieve::block(0, -2) & retrieve::block(0, -3) &  retrieve::block(0, -4) & retrieve::block(0, -5).
count_attached_blocks(s, 0) :-
	not(retrieve::block(0, 1)).
count_attached_blocks(s, 1) :-
	retrieve::block(0, 1) & not(retrieve::block(0, 2)).
count_attached_blocks(s, 2) :-
	retrieve::block(0, 1) & retrieve::block(0, 2) & 
	not(retrieve::block(0, 3)).
count_attached_blocks(s, 3) :-
	retrieve::block(0, 1) & retrieve::block(0, 2) & retrieve::block(0, 3) &
	not(retrieve::block(0, 4)).
count_attached_blocks(s, 4) :-
	retrieve::block(0, 1) & retrieve::block(0, 2) & retrieve::block(0, 3) &  retrieve::block(0, 4) &
	not(retrieve::block(0, 5)).
count_attached_blocks(s, 5) :-
	retrieve::block(0, 1) & retrieve::block(0, 2) & retrieve::block(0, 3) &  retrieve::block(0, 4) & retrieve::block(0, 5).
count_attached_blocks(w, 0) :-
	not(retrieve::block(-1, 0)).
count_attached_blocks(w, 1) :-
	retrieve::block(-1, 0) & not(retrieve::block(-2, 0)).
count_attached_blocks(w, 2) :-
	retrieve::block(-1, 0) & retrieve::block(-2, 0) & 
	not(retrieve::block(-3, 0)).
count_attached_blocks(w, 3) :-
	retrieve::block(-1, 0) & retrieve::block(-2, 0) & retrieve::block(-3, 0) &
	not(retrieve::block(-4, 0)).
count_attached_blocks(w, 4) :-
	retrieve::block(-1, 0) & retrieve::block(-2, 0) & retrieve::block(-3, 0) &  retrieve::block(-4, 0) &
	not(retrieve::block(-5, 0)).
count_attached_blocks(w, 5) :-
	retrieve::block(-1, 0) & retrieve::block(-2, 0) & retrieve::block(-3, 0) &  retrieve::block(-4, 0) & retrieve::block(-5, 0).
count_attached_blocks(e, 0) :-
	not(retrieve::block(1, 0)).
count_attached_blocks(e, 1) :-
	retrieve::block(1, 0) & not(retrieve::block(2, 0)).
count_attached_blocks(e, 2) :-
	retrieve::block(1, 0) & retrieve::block(2, 0) & 
	not(retrieve::block(3, 0)).
count_attached_blocks(e, 3) :-
	retrieve::block(1, 0) & retrieve::block(2, 0) & retrieve::block(3, 0) &
	not(retrieve::block(4, 0)).
count_attached_blocks(e, 4) :-
	retrieve::block(1, 0) & retrieve::block(2, 0) & retrieve::block(3, 0) &  retrieve::block(4, 0) &
	not(retrieve::block(5, 0)).
count_attached_blocks(e, 5) :-
	retrieve::block(1, 0) & retrieve::block(2, 0) & retrieve::block(3, 0) &  retrieve::block(4, 0) & retrieve::block(5, 0).

i_have_attached_block :-
	retrieve::block(0, -1) | retrieve::block(0, 1) | retrieve::block(-1, 0) | retrieve::block(1, 0).

opposite_direction(n, s) :- true.
opposite_direction(s, n) :- true.
opposite_direction(w, e) :- true.
opposite_direction(e, w) :- true.
other_cardinals(n, [w,e]) :- true.
other_cardinals(s, [w,e]) :- true.
other_cardinals(w, [n,s]) :- true.
other_cardinals(e, [n,s]) :- true.

get_rotation(n, w, ccw) :- true.
get_rotation(n, e, cw) :- true.
get_rotation(s, w, cw) :- true.
get_rotation(s, e, ccw) :- true.
get_rotation(w, n, cw) :- true.
get_rotation(w, s, ccw) :- true.
get_rotation(e, n, ccw) :- true.
get_rotation(e, s, cw) :- true.

get_rel_pos(n, 0, -1) :- true.
get_rel_pos(s, 0, 1) :- true.
get_rel_pos(w, -1, 0) :- true.
get_rel_pos(e, 1, 0) :- true.

neighbour_to_dispenser(MyX, MyY, TargetX, TargetY, n) :-
	MyX == TargetX & MyY == (TargetY+1).
neighbour_to_dispenser(MyX, MyY, TargetX, TargetY, s) :-
	MyX == TargetX & MyY == (TargetY-1).
neighbour_to_dispenser(MyX, MyY, TargetX, TargetY, e) :-
	MyX == (TargetX-1) & MyY == TargetY.
neighbour_to_dispenser(MyX, MyY, TargetX, TargetY, w) :-
	MyX == (TargetX+1) & MyY == TargetY.
	
most_needed_type(Dispensers, AgList, Type) :-
	.member(dispenser(Type, _, _), Dispensers) & not .member(agent(_, Type), AgList).
	
/*[
		scout(Side, X, Y-RangeN),
		scout(Side, X+RangeE, Y-RangeN),
		scout(Side, X+RangeE, Y),
		scout(Side, X+RangeE, Y+RangeS),
		scout(Side, X, Y+RangeS),
		scout(Side, X-RangeW, Y+RangeS),
		scout(Side, X-RangeW, Y),
		scout(Side, X-RangeW, Y-RangeN)
	] */	
+!retrieve::generate_square_positions_around_origin(origin(X, Y), Side, RangeN, RangeS, RangeW, RangeE,
	L) : 
	true
<-
	-retrieve::scouts_aux(_);
	+retrieve::scouts_aux([]);
	for(.range(H, 0, RangeE, 3)){
		if(retrieve::scouts_aux(Scouts)){
			.concat(Scouts, [scout(Side, X+H, Y-RangeN)], Scouts1);
			-+retrieve::scouts_aux(Scouts1);
		}
	}
	for(.range(V, -RangeN+3, RangeS, 3)){
		if(retrieve::scouts_aux(Scouts)){
			.concat(Scouts, [scout(Side, X+RangeE, Y+V)], Scouts1);
			-+retrieve::scouts_aux(Scouts1);
		}
	}		
	for(.range(H, RangeE-3, -RangeW, -3)){
		if(retrieve::scouts_aux(Scouts)){
			.concat(Scouts, [scout(Side, X+H, Y+RangeS)], Scouts1);
			-+retrieve::scouts_aux(Scouts1);
		}
	}
	for(.range(V, RangeS-3, -RangeN, -3)){
		if(retrieve::scouts_aux(Scouts)){
			.concat(Scouts, [scout(Side, X-RangeW, Y+V)], Scouts1);
			-+retrieve::scouts_aux(Scouts1);
		}
	}
	for(.range(H, -RangeW+3, 0, 3)){
		if(H<0 & retrieve::scouts_aux(Scouts)){
			.concat(Scouts, [scout(Side, X+H, Y-RangeN)], Scouts1);
			-+retrieve::scouts_aux(Scouts1);
		}
	}
	if(retrieve::scouts_aux(Scouts)){
		L = Scouts;
	}	
	.
+!retrieve::generate_helpers_position(origin(X, Y), n, 
	[
		pos(X, Y-5),
		pos(X-2, Y-5),
		pos(X-4, Y-5),
		pos(X+2, Y-5),
		pos(X+4, Y-5)
	], pos(X, Y-5)).
+!retrieve::generate_helpers_position(origin(X, Y), s, 
	[
		pos(X, Y+5),
		pos(X-2, Y+5),
		pos(X-4, Y+5),
		pos(X+2, Y+5),
		pos(X+4, Y+5)
	], pos(X, Y+5)).
+!retrieve::generate_helpers_position(origin(X, Y), w, 
	[
		pos(X-5, Y),
		pos(X-5, Y-4),
		pos(X-7, Y),
		pos(X-9, Y),
		pos(X-5, Y+4)
	], pos(X-5, Y)).
+!retrieve::generate_helpers_position(origin(X, Y), e, 
	[
		pos(X+5, Y),
		pos(X+5, Y-4),
		pos(X+7, Y),
		pos(X+9, Y),
		pos(X+5, Y+4)
	], pos(X+5, Y)).

+!retrieve::retrieve_block 
	: default::step(Step1)
<-
//	.wait(not action::move_sent);
	callPlanner(Flag);
	!planner::try_call_planner(Flag);
	getMyPos(MyX, MyY);
	?default::step(Step2);
	.print(" Step1 ",Step1," Step2 ",Step2);
	!retrieve::decide_block_type_flat(Type); .print("I decided to get block type: ", Type);
	!retrieve::get_nearest_dispenser(Type, dispenser(Type, X, Y));
	.print("The nearest dispenser is: ", dispenser(Type, X, Y));
	.print("Target added: ", X, " ", Y);
	.print("My pos: ", MyX, " ", MyY);
	TargetX = X - MyX;
	TargetY = Y - MyY;
	+collect_block;
	if(TargetX < 0){
		.print("Relative target: ", TargetX + 1, " ", TargetY);
		!!planner::generate_goal(TargetX + 1, TargetY, block);
	} else {
		.print("Relative target: ", TargetX - 1, " ", TargetY);
		!!planner::generate_goal(TargetX - 1, TargetY, block);
	}
	.

//-!retrieve::retrieve_block : true <- !!retrieve::retrieve_block.
//-!retrieve::retrieve_block : true <- true.

+!retrieve::decide_block_type_flat(Type) : 
	true
<-
	//getAvailableAgent(AgList);
	getBlocks(Blocks);
	!map::get_dispensers(Dispensers);
	.setof(B, (.member(dispenser(B, _, _), Dispensers) & not .member(B, Blocks)), MostNeededTypes);
	if(MostNeededTypes == []){
		.setof(Type, .member(dispenser(Type, _, _), Dispensers), Types1);
		.shuffle(Types1, Types);
	} else{
		.shuffle(MostNeededTypes, Types);
	}
	.nth(0, Types, Type);
	addBlock(Type);
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
	
@get_nearest_dispenser[atomic]
+!retrieve::get_nearest_dispenser(Type, Dispenser) : 
	true
<-
	!map::get_dispensers(Dispensers); .print("Dispensers: ", Dispensers);
	!retrieve::get_nearest_dispenser_aux1(Dispensers, Type, Dispenser).
+!retrieve::get_nearest_dispenser_aux1(Dispensers, Type, dispenser(Type, X, Y)) :
	true
<-
	//getMyPos(MyX,MyY);
	getTargetGoal(_, MyX, MyY, _);
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

+!create_and_attach_block :
	default::thing(0, -1, dispenser, _)
<- 
	!create_and_attach_block(n, 0, -1).
+!create_and_attach_block :
	default::thing(0, 1, dispenser, _)
<- 
	!create_and_attach_block(s, 0, 1).
+!create_and_attach_block :
	default::thing(-1, 0, dispenser, _)
<- 
	!create_and_attach_block(w, -1, 0).
+!create_and_attach_block :
	default::thing(1, 0, dispenser, _)
<- 
	!create_and_attach_block(e, 1, 0).
+!create_and_attach_block <- .print("No dispenser close by"); getMyPos(X,Y); .print("My position before dying is (", X, ", ", Y, ")");. //!retrieve::retrieve_block.

+!create_and_attach_block(Direction, DispX, DispY) :
	true
<-
	.print("!create_and_attach_block(Direction, DispX, DispY)");
	+retrieve::fetching_block;
	-retrieve::attach_completed;
	while(not retrieve::attach_completed){
		!action::request(Direction);
		.print("here1");
		if(default::lastActionResult(failed_target)){
			.fail;
		}
		.print("here2");
		while(not default::lastActionResult(success)){
			.print("here3");
			!action::request(Direction);
		}
		.print("here4");
		!action::attach(Direction);
		.print("here5");
		if(default::lastActionResult(success) & retrieve::block(DispX, DispY)){
			.print("here6");
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

+!get_block
<-
	-collect_block;
	!retrieve::create_and_attach_block;
//	.wait(not action::move_sent);
	getMyPos(MyX, MyY);
//	if (common::my_role(stocker)) {
//		getStockerAvailablePos(TargetXGlobal, TargetYGlobal);
//		getTargetGoal(_, GoalX, GoalY, _);
//		if (TargetYGlobal < GoalY) {
//			StockerBlockPos = s;
//		}
//		elif (TargetYGlobal > GoalY) {
//			StockerBlockPos = n;
//		}
//		elif (TargetXGlobal > GoalX) {
//			StockerBlockPos = w;
//		}
//		else {
//			StockerBlockPos = e;
//		}
//		+gate(StockerBlockPos);
//	}
//	else {
		getRetrieverAvailablePos(TargetXGlobal, TargetYGlobal);
//	}
	TargetX = TargetXGlobal - MyX;
	TargetY = TargetYGlobal - MyY;
	.print("Chosen Global Goal position: ", TargetXGlobal, TargetYGlobal);
	.print("Agent position: ", MyX, MyY);
	.print("Chosen Relative Goal position: ", TargetX, TargetY);
	!planner::generate_goal(TargetX, TargetY, notblock);
//	!retrieve::move_to_goal;
	.

+!retrieve::fetch_block_to_goal : 
	true
<- 
//	.wait(not action::move_sent);
	getMyPos(MyX,MyY);
	!retrieve::fetch_block_to_goal_aux(MyX, MyY).
+!retrieve::fetch_block_to_goal_aux(MyX, MyY) :	
	retrieve::target(TargetX, TargetY) &
	neighbour_to_dispenser(MyX, MyY, TargetX, TargetY, Direction) &
	.my_name(Me)
<-
	!retrieve::create_and_attach_block(Direction);
	if(stop::first_to_stop(Me)){
		getTargetGoal(Ag, GoalX, GoalY, SideStr);
		MyGoalX = GoalX; MyGoalY = GoalY;
	} else{
		if (not common::my_role(retriever)) {
			getStockerAvailablePos(MyGoalX, MyGoalY);
			if (MyGoalY < GoalY) {
				StockerBlockPos = s;
			}
			elif (MyGoalY > GoalY) {
				StockerBlockPos = n;
			}
			elif (MyGoalX > GoalX) {
				StockerBlockPos = w;
			}
			else {
				StockerBlockPos = e;
			}
			+gate(StockerBlockPos);
		}
		else {
			getRetrieverAvailablePos(MyGoalX, MyGoalY);
			/*getTargetGoal(Ag, GoalX, GoalY, SideStr);
			.random(NX);
			.random(RX);
			if (NX > 0.5) {
				RandomX = math.floor(RX * 5)+7;
			}
			else {
				RandomX = math.floor(RX * -5)-7;
			}
			.random(NY);
			.random(RY);
			if (NY > 0.5) {
				RandomY = math.floor(RY * 5)+9;
			}
			else {
				RandomY = math.floor(RX * -5)-5;
			}
			MyGoalX = GoalX + RandomX;
			MyGoalY = GoalY + RandomY;*/
		}
//		!retrieve::generate_helpers_position(origin(GoalX, GoalY), Side, HelpersPos, _);
//		.random(R); .length(HelpersPos, NHelpersPos); R1 = R * (NHelpersPos-1);
//		.nth(R1, HelpersPos, pos(MyGoalX, MyGoalY));
	}
	.print("Chosen Goal position: ", MyGoalX, MyGoalY);
	-+retrieve::target(MyGoalX, MyGoalY);
	!retrieve::move_to_goal.
+!retrieve::fetch_block_to_goal_aux(MyX, MyY) :	
	retrieve::target(TargetX, TargetY) &
	pick_direction(MyX, MyY, TargetX, TargetY, Direction) 
<-		
	.print("TargetX: ", TargetX, " TargetY: ", TargetY);
	if (exploration::check_obstacle_special_1(Direction, 1)) {
		if(i_can_avoid(Direction, DirectionToGo)){
			.print("GO AROUND OBSTACLE: ", i_can_avoid(Direction, DirectionToGo));
			!retrieve::go_around_obstacle(Direction, DirectionToGo, MyX, MyY, 0, 5, DirectionObstacle1, 1)
//			.wait(not action::move_sent);
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
				!retrieve::go_around_obstacle(Direction, 5);
			}
		} else{
			!retrieve::go_around_obstacle(Direction, 5);
		}
	} else {
		!retrieve::smart_move(Direction);
	}
	!retrieve::fetch_block_to_goal.
	
-!retrieve::fetch_block_to_goal : true <- !!retrieve::fetch_block_to_goal.

-!retrieve::smart_move(Direction) : 
	true 
<- 
	!action::move(Direction);
	if(default::lastActionResult(success) & map::evaluating_positions(_)){
		!map::update_evaluating_positions(Direction);
	}
	.
+!retrieve::smart_move(Direction) :
	true
<-
	.print("Direction: ", Direction);
	if(retrieve::block(1, 0)){
		!retrieve::smart_rotate(e, Direction);
	}
	elif(retrieve::block(-1, 0)){
		!retrieve::smart_rotate(w, Direction);
	}
	elif(retrieve::block(0, -1)){
		!retrieve::smart_rotate(n, Direction);
	} elif(retrieve::block(0, 1)){
		!retrieve::smart_rotate(s, Direction);
	}
//	if(common::my_role(Role)){.print("My current role1: ", Role)}	
	!action::move(Direction);
//	if(common::my_role(Role1)){.print("My current role2: ", Role1)}
	if(default::lastActionResult(success) & map::evaluating_positions(_)){
		!map::update_evaluating_positions(Direction);
	}
	.
	/*
	if(Direction == n){
		if(retrieve::block(1, 0)){
			!action::rotate(ccw);
		}
		elif(retrieve::block(-1, 0)){
			!action::rotate(cw);
		}
		elif(retrieve::block(0, 1)){
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
		if(retrieve::block(1, 0)){
			!retrieve::smart_rotate(e, Direction);
		}
		elif(retrieve::block(-1, 0)){
			!retrieve::smart_rotate(w, Direction);
		}
		elif(retrieve::block(0, -1)){
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
		if(retrieve::block(0, 1)){
			!action::rotate(cw);
		}
		elif(retrieve::block(0, -1)){
			!action::rotate(ccw);
		}
		elif(retrieve::block(1, 0)){
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
		if(retrieve::block(0, 1)){
			!action::rotate(ccw);
		}
		elif(retrieve::block(0, -1)){
			!action::rotate(cw);
		}
		elif(retrieve::block(-1, 0)){
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
	*/

+!retrieve::go_around_obstacle(DirectionObstacle, Threshold) :
	true
<-
//	.wait(not action::move_sent);
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
	not(exploration::check_obstacle_special_1(DirectionObstacle, 2)) & not(exploration::check_agent(DirectionObstacle)) &
	opposite_direction(DirectionToGo, OppositeDirection)
<-
	.print("here2");
	if(Count > 0){
		!retrieve::smart_move(DirectionObstacle);
//		.wait(not action::move_sent);
		getMyPos(MyX1,MyY1);
		!retrieve::go_around_obstacle(OppositeDirection, DirectionObstacle, MyX, MyY, 0, Threshold, _, Count-1);
	}
	.
+!retrieve::go_around_obstacle(DirectionObstacle, DirectionToGo, MyX, MyY, Attempts, Threshold, ActualDirection, Count) :
	 Attempts < Threshold & not(exploration::check_obstacle_special_1(DirectionToGo, 1))
<-
	.print("here3");
	!retrieve::smart_move(DirectionToGo);
//	.wait(not action::move_sent);
	getMyPos(MyX1,MyY1);
	!retrieve::go_around_obstacle(DirectionObstacle, DirectionToGo, MyX1, MyY1, Attempts+1, Threshold, ActualDirection, Count).
+!retrieve::go_around_obstacle(DirectionObstacle, DirectionToGo, MyX, MyY, Attempts, Threshold, ActualDirection, Count) :
	true//not map::evaluating_positions(_)
<-
	if(default::energy(Energy) & Energy >= 30){
		!retrieve::smart_clear(DirectionObstacle);
		if(retrieve::res(0)){
			if(not map::evaluating_positions(_)){
				.print("FAILED TO CLEAR: ", Attempts, ", ", Threshold);
				!action::skip;
				!retrieve::go_around_obstacle(DirectionObstacle, DirectionToGo, MyX, MyY, Attempts, Threshold, ActualDirection, Count);
			} else {
				.fail;
			}
		}
	} else {
		//.fail
		.print("I WANT TO CLEAR BUT I HAVE NO ENERGY");
		if(not map::evaluating_positions(_)){
			!action::skip;
			!retrieve::go_around_obstacle(DirectionObstacle, DirectionToGo, MyX, MyY, Attempts, Threshold, ActualDirection, Count);
		} else{
			.fail;
		}
	}.
	
+!retrieve::move_to_goal : 
	.my_name(Me) & common::my_role(helper)
<- 
//	.wait(not action::move_sent);
	getMyPos(MyX,MyY);
	getTargetGoal(_, GoalX, GoalY, _);
//	.term2string(Side, SideStr);
	.print("Chosen Goal position: ", GoalX+1, GoalY);
	MyGoalX = GoalX+1; MyGoalY = GoalY;
	-+retrieve::target(MyGoalX, MyGoalY);
	!retrieve::move_to_goal_aux(MyX, MyY).

+!retrieve::move_to_goal : 
	.my_name(Me)
<- 
//	.wait(not action::move_sent);
	getMyPos(MyX,MyY);
	if(stop::first_to_stop(Me)){
		getTargetGoal(_, GoalX, GoalY, _);
//		.term2string(Side, SideStr);
		.print("Chosen Goal position: ", GoalX, GoalY);
		MyGoalX = GoalX; MyGoalY = GoalY;
		-+retrieve::target(MyGoalX, MyGoalY);
	}
	!retrieve::move_to_goal_aux(MyX, MyY).
+!retrieve::move_to_goal_aux(TargetX, TargetY) :	
	retrieve::target(TargetX, TargetY) & stop::first_to_stop(Ag)
<-
//	if(retrieve::block(0, -1)){
//		!retrieve::smart_rotate(n, s);
//		!retrieve::move_to_goal_aux(TargetX, TargetY);
//	} elif(retrieve::block(-1, 0)){
//		!retrieve::smart_rotate(w, s);
//		!retrieve::move_to_goal_aux(TargetX, TargetY);
//	} elif(retrieve::block(1, 0)){
//		!retrieve::smart_rotate(e, s);
//		!retrieve::move_to_goal_aux(TargetX, TargetY);
//	} else{
	.my_name(Me);
	if  (stop::first_to_stop(Me)) {
		-moving_to_origin;
		+task::origin;
	}
	elif (common::my_role(helper)) {
		-moving_to_origin;
		.send(Ag, tell, task::helper(Me));
	}
	elif (common::my_role(stocker)) {
//		.wait(not action::move_sent);
		getMyPos(MyX,MyY);
		?gate(Gate);
		addStocker(Me, MyX, MyY, Gate);
		+task::stocker_in_position;
		if (retrieve::block(X,Y)) {
			?default::thing(X,Y,block,Type);
			addStockerBlock(Me, Type);
		}
		
//			addAvailableAgent(Me,Type);
		.send(Ag, tell, task::stocker(Me));
	}
	!default::always_skip;
//	}
	.
	
//+!retrieve::move_to_goal_aux(MyX, MyY) :
//	retrieve::retriever & .my_name(Me) & not(stop::first_to_stop(Me)) & retrieve::target(TargetX, TargetY) &
//	(math.abs(MyX - TargetX) + math.abs(MyY - TargetY)) <= 3 &
//	pick_direction(MyX, MyY, TargetX, TargetY, Direction) & exploration::check_agent_special(Direction)
//<-
//	getTargetGoal(_, GoalX, GoalY, SideStr);
//	.term2string(Side, SideStr);
//	!retrieve::generate_helpers_position(origin(GoalX, GoalY), Side, HelpersPos, _);
//	.nth(Pos, HelpersPos, pos(TargetX, TargetY));
//	.length(HelpersPos, NHelpersPos);
//	if(Pos == (NHelpersPos-1)){
//		Pos1 = 0;
//	} else{
//		Pos1 = Pos + 1;
//	}
//	.nth(Pos1, HelpersPos, pos(NewTargetX, NewTargetY));
//	getAvailablePos(NewTargetX, NewTargetY);
//	-+retrieve::target(NewTargetX, NewTargetY)
//	!retrieve::move_to_goal_aux(MyX, MyY);
//	.
+!retrieve::move_to_goal_aux(MyX, MyY) :	
	retrieve::target(TargetX, TargetY) & 
	pick_direction(MyX, MyY, TargetX, TargetY, Direction) 
<-
	.print("TargetX: ", TargetX, " TargetY: ", TargetY);
	if (exploration::check_obstacle_special_1(Direction, 1)) {
		if(i_can_avoid(Direction, DirectionToGo)){
			.print("GO AROUND OBSTACLE");
			!retrieve::go_around_obstacle(Direction, DirectionToGo, MyX, MyY, 0, 10, DirectionObstacle1, 1);
//			.wait(not action::move_sent);
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
				!retrieve::go_around_obstacle(Direction, 10);
			}
		} else{
			!retrieve::go_around_obstacle(Direction, 10);
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
//+!retrieve::move_to_goal_aux(MyX, MyY) :
//	not i_have_attached_block & not moving_to_origin
//<-
//	!retrieve::retrieve_block;
//	.

-!retrieve::move_to_goal : true <- !!retrieve::move_to_goal.

+!retrieve::smart_rotate(Dir, Dir).
+!retrieve::smart_rotate(FromDirBlock, ToDirBlock) :
	true
<-
	.print(smart_rotate(FromDirBlock, ToDirBlock));
	if(FromDirBlock == n & ToDirBlock == e){
		if(default::obstacle(1, 0)){
			if(default::energy(Energy) & Energy >= 30){
				!retrieve::smart_clear(e);
				if(retrieve::res(1)){
					!retrieve::smart_rotate(n, e);
				} else {
					.fail;
				}
			} else{
				.fail;
			}
		} elif(exploration::check_agent_special(e) | default::thing(1, 0, block, _)){
			.fail;
		} else {
			!action::rotate(cw);
			if(not default::lastActionResult(success)){
				!retrieve::smart_rotate(n, e);
			}
		}
	} elif(FromDirBlock == n & ToDirBlock == w){
		if(default::obstacle(-1, 0)){
			if(default::energy(Energy) & Energy >= 30){
				!retrieve::smart_clear(w);
				if(retrieve::res(1)){
					!retrieve::smart_rotate(n, w);
				} else {
					.fail;
				}
			} else{
				.fail;
			}
		} elif(exploration::check_agent_special(w) | default::thing(-1, 0, block, _)){
			.fail;
		} else {
			!action::rotate(ccw);
			if(not default::lastActionResult(success)){
				!retrieve::smart_rotate(n, w);
			}
		}
	} elif(FromDirBlock == n & ToDirBlock == s){
		if(not default::obstacle(1, 0) & not exploration::check_agent_special(e) & not default::thing(1, 0, block, _)){
			!action::rotate(cw);
			if(default::lastActionResult(success)){
				!retrieve::smart_rotate(e, s);
			} else{
				!retrieve::smart_rotate(n, s);
			}
		} elif(not default::obstacle(-1, 0) & not exploration::check_agent_special(w) & not default::thing(-1, 0, block, _)){
			!action::rotate(ccw);
			if(default::lastActionResult(success)){
				!retrieve::smart_rotate(w, s);
			} else{
				!retrieve::smart_rotate(n, s);
			}
		} elif(default::energy(Energy) & Energy >= 30){
			!retrieve::smart_clear(w);
			if(retrieve::res(0)){
				!retrieve::smart_clear(e);
				if(retrieve::res(0)){
					.fail
				} else {
					!retrieve::smart_rotate(n, s);	
				}
			} else {
				!retrieve::smart_rotate(n, s);
			}
		} else{
			.fail;
		}
	} elif(FromDirBlock == e & ToDirBlock == s){
		if(default::obstacle(0, 1)){
			if(default::energy(Energy) & Energy >= 30){
				!retrieve::smart_clear(s);
				if(retrieve::res(1)){
					!retrieve::smart_rotate(e, s);
				} else {
					.fail;
				}
			} else{
				.fail;
			}
		} elif(exploration::check_agent_special(s) | default::thing(0, 1, block, _)){
			.fail;
		} else {
			!action::rotate(cw);
			if(not default::lastActionResult(success)){
				!retrieve::smart_rotate(e, s);
			}
		}
	} elif(FromDirBlock == e & ToDirBlock == n){
		if(default::obstacle(0, -1)){
			if(default::energy(Energy) & Energy >= 30){
				!retrieve::smart_clear(n);
				if(retrieve::res(1)){
					!retrieve::smart_rotate(e, n);
				} else {
					.fail;
				}
			} else{
				.fail;
			}
		} elif(exploration::check_agent_special(n) | default::thing(0, -1, block, _)){
			.fail;
		} else {
			!action::rotate(ccw);
			if(not default::lastActionResult(success)){
				!retrieve::smart_rotate(e, n);
			}
		}
	} elif(FromDirBlock == e & ToDirBlock == w){
		if(not default::obstacle(0, 1) & not exploration::check_agent_special(s) & not default::thing(0, 1, block, _)){
			!action::rotate(cw);
			if(default::lastActionResult(success)){
				!retrieve::smart_rotate(s, w);
			} else{
				!retrieve::smart_rotate(e, w);
			}
		} elif(not default::obstacle(0, -1) & not exploration::check_agent_special(n) & not default::thing(0, -1, block, _)){
			!action::rotate(ccw);
			if(default::lastActionResult(success)){
				!retrieve::smart_rotate(n, w);
			} else{
				!retrieve::smart_rotate(e, w);
			}
		} elif(default::energy(Energy) & Energy >= 30){
			!retrieve::smart_clear(s);
			if(retrieve::res(0)){
				!retrieve::smart_clear(n);
				if(retrieve::res(0)){
					.fail
				} else {
					!retrieve::smart_rotate(e, w);
				}
			} else {
				!retrieve::smart_rotate(e, w);
			}
		} else{
			.fail;
		}
	} elif(FromDirBlock == s & ToDirBlock == w){
		if(default::obstacle(-1, 0)){
			if(default::energy(Energy) & Energy >= 30){
				!retrieve::smart_clear(w);
				if(retrieve::res(1)){
					!retrieve::smart_rotate(s, w);
				} else {
					.fail;
				}
			} else{
				.fail;
			}
		} elif(exploration::check_agent_special(w) | default::thing(-1, 0, block, _)){
			.fail;
		} else {
			!action::rotate(cw);
			if(not default::lastActionResult(success)){
				!retrieve::smart_rotate(s, w);
			}
		}
	} elif(FromDirBlock == s & ToDirBlock == e){
		if(default::obstacle(1, 0)){
			if(default::energy(Energy) & Energy >= 30){
				!retrieve::smart_clear(e);
				if(retrieve::res(1)){
					!retrieve::smart_rotate(s, e);
				} else {
					.fail;
				}
			} else{
				.fail;
			}
		} elif(exploration::check_agent_special(e) | default::thing(1, 0, block, _)){
			.fail;
		} else {
			!action::rotate(ccw);
			if(not default::lastActionResult(success)){
				!retrieve::smart_rotate(s, e);
			}
		}
	} elif(FromDirBlock == s & ToDirBlock == n){
		if(not default::obstacle(-1, 0) & not exploration::check_agent_special(w) & not default::thing(-1, 0, block, _)){
			!action::rotate(cw);
			if(default::lastActionResult(success)){
				!retrieve::smart_rotate(w, n);
			} else{
				!retrieve::smart_rotate(s, n);
			}
		} elif(not default::obstacle(1, 0) & not exploration::check_agent_special(e) & not default::thing(1, 0, block, _)){
			!action::rotate(ccw);
			if(default::lastActionResult(success)){
				!retrieve::smart_rotate(e, n);
			} else{
				!retrieve::smart_rotate(s, n);
			}
		} elif(default::energy(Energy) & Energy >= 30){
			!retrieve::smart_clear(w);
			if(retrieve::res(0)){
				!retrieve::smart_clear(e);
				if(retrieve::res(0)){
					.fail;
				} else{
					!retrieve::smart_rotate(s, n);
				}
			} else {
				!retrieve::smart_rotate(s, n);
			}
		} else{
			.fail;
		}
	} elif(FromDirBlock == w & ToDirBlock == n){
		if(default::obstacle(0, -1)){
			if(default::energy(Energy) & Energy >= 30){
				!retrieve::smart_clear(n);
				if(retrieve::res(1)){
					!retrieve::smart_rotate(w, n);
				} else {
					.fail;
				}
			} else{
				.fail;
			}
		} elif(exploration::check_agent_special(n) | default::thing(0, -1, block, _)){
			.fail;
		} else {
			!action::rotate(cw);
			if(not default::lastActionResult(success)){
				!retrieve::smart_rotate(w, n);
			}
		}
	} elif(FromDirBlock == w & ToDirBlock == s){
		if(default::obstacle(0, 1)){
			if(default::energy(Energy) & Energy >= 30){
				!retrieve::smart_clear(s);
				if(retrieve::res(1)){
					!retrieve::smart_rotate(w, s);
				} else {
					.fail;
				}
			} else{
				.fail;
			}
		} elif(exploration::check_agent_special(s) | default::thing(0, 1, block, _)){
			.fail;
		} else {
			!action::rotate(ccw);
			if(not default::lastActionResult(success)){
				!retrieve::smart_rotate(w, s);
			}
		}
	} elif(FromDirBlock == w & ToDirBlock == e){
		if(not default::obstacle(0, -1) & not exploration::check_agent_special(n) & not default::thing(0, -1, block, _)){
			!action::rotate(cw);
			if(default::lastActionResult(success)){
				!retrieve::smart_rotate(n, e);
			} else{
				!retrieve::smart_rotate(w, e);
			}
		} elif(not default::obstacle(0, 1) & not exploration::check_agent_special(s) & not default::thing(0, 1, block, _)){
			!action::rotate(ccw);
			if(default::lastActionResult(success)){
				!retrieve::smart_rotate(s, e);
			} else{
				!retrieve::smart_rotate(w, w);
			}
		} elif(default::energy(Energy) & Energy >= 30){
			!retrieve::smart_clear(n);
			if(retrieve::res(0)){
				!retrieve::smart_clear(s);
				if(retrieve::res(0)){
					.fail;
				} else {
					!retrieve::smart_rotate(w, e);
				}
			} else {
				!retrieve::smart_rotate(w, e);
			}
		} else{
			.fail;
		}
	}
	.	
	

+!retrieve::smart_clear(Direction) :
	default::energy(Energy) & Energy >= 30 & default::team(Team)
<-
	-res(_);
	if(Direction == n){
		if(retrieve::block(0, -1)){
			ClearX = 0; ClearY = -3
		} else{
			ClearX = 0; ClearY = -2
		}
	}
	elif(Direction == s){
		if(retrieve::block(0, 1)){
			ClearX = 0; ClearY = 3
		} else{
			ClearX = 0; ClearY = 2
		}
	}
	elif(Direction == w){
		if(retrieve::block(-1, 0)){
			ClearX = -3; ClearY = 0
		} else{
			ClearX = -2 ClearY = 0
		}
	}
	else{
		if(retrieve::block(1, 0)){
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
			not default::thing(ClearX, ClearY+1, block, _) &
			not default::thing(ClearX, ClearY, entity, Team) & 
			not default::thing(ClearX-1, ClearY, entity, Team) &
			not default::thing(ClearX+1, ClearY, entity, Team) &
			not default::thing(ClearX, ClearY-1, entity, Team) &
			not default::thing(ClearX, ClearY+1, entity, Team)
		){
			.print("CLEEEEEEEEEEEEEEEEEEEAR STOCK.ASL");
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

	
	
	
	