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
		(not(default::obstacle(-1, 0)) & not(default::thing(-1, 0, marker, clear)) & not(default::obstacle(-1, -1)) & not(default::obstacle(-1, -2)) & not(default::thing(-1,-1, marker, clear)) & not(default::thing(-1,-2, marker, clear))) |
		(not(default::obstacle(-1, 0)) & not(default::thing(-1, 0, marker, clear)) & not(default::obstacle(-2, 0)) & not(default::thing(-2, 0, marker, clear)) & not(default::obstacle(-2, -1)) & not(default::obstacle(-2, -2)) & not(default::thing(-2,-1, marker, clear)) & not(default::thing(-2,-2, marker, clear))) |
		(not(default::obstacle(-1, 0)) & not(default::thing(-1, 0, marker, clear)) & not(default::obstacle(-2, 0)) & not(default::thing(-2, 0, marker, clear)) & not(default::obstacle(-3, 0)) & not(default::thing(-3, 0, marker, clear)) & not(default::obstacle(-3, -1)) & not(default::obstacle(-3, -2)) & not(default::thing(-3,-1, marker, clear)) & not(default::thing(-3,-2, marker, clear)))
	).
i_can_avoid(n, e) :-
	(
		(not(default::obstacle(1, 0)) & not(default::thing(1, 0, marker, clear)) & not(default::obstacle(1, -1)) & not(default::obstacle(1, -2)) & not(default::thing(1,-1, marker, clear)) & not(default::thing(1,-2, marker, clear))) |
		(not(default::obstacle(1, 0)) & not(default::thing(1, 0, marker, clear)) & not(default::obstacle(2, 0)) & not(default::thing(2, 0, marker, clear)) & not(default::obstacle(2, -1)) & not(default::obstacle(2, -2)) & not(default::thing(2,-1, marker, clear)) & not(default::thing(2,-2, marker, clear))) |
		(not(default::obstacle(1, 0)) & not(default::thing(1, 0, marker, clear)) & not(default::obstacle(2, 0)) & not(default::thing(2, 0, marker, clear)) & not(default::obstacle(3, 0)) & not(default::thing(3, 0, marker, clear)) & not(default::obstacle(3, -1)) & not(default::obstacle(3, -2)) & not(default::thing(3,-1, marker, clear)) & not(default::thing(3,-2, marker, clear)))
	).
i_can_avoid(s, w) :-
	(
		(not(default::obstacle(-1, 0)) & not(default::thing(-1, 0, marker, clear)) & not(default::obstacle(-1, 1)) & not(default::obstacle(-1, 2)) & not(default::thing(-1,1, marker, clear)) & not(default::thing(-1,2, marker, clear))) |
		(not(default::obstacle(-1, 0)) & not(default::thing(-1, 0, marker, clear)) & not(default::obstacle(-2, 0)) & not(default::thing(-2, 0, marker, clear)) & not(default::obstacle(-2, 1)) & not(default::obstacle(-2, 2)) & not(default::thing(-2,1, marker, clear)) & not(default::thing(-2,2, marker, clear))) |
		(not(default::obstacle(-1, 0)) & not(default::thing(-1, 0, marker, clear)) & not(default::obstacle(-2, 0)) & not(default::thing(-2, 0, marker, clear)) & not(default::obstacle(-3, 0)) & not(default::thing(-3, 0, marker, clear))& not(default::obstacle(-3, 1)) & not(default::obstacle(-3, 2)) & not(default::thing(-3,1, marker, clear)) & not(default::thing(-3,2, marker, clear)))
	).
i_can_avoid(s, e) :-
	(
		(not(default::obstacle(1, 0)) & not(default::thing(1, 0, marker, clear)) & not(default::obstacle(1, 1)) & not(default::obstacle(1, 2)) & not(default::thing(1,1, marker, clear)) & not(default::thing(1,2, marker, clear))) |
		(not(default::obstacle(1, 0)) & not(default::thing(1, 0, marker, clear)) & not(default::obstacle(2, 0)) & not(default::thing(2, 0, marker, clear)) & not(default::obstacle(2, 1)) & not(default::obstacle(2, 2)) & not(default::thing(2,1, marker, clear)) & not(default::thing(2,2, marker, clear))) |
		(not(default::obstacle(1, 0)) & not(default::thing(1, 0, marker, clear)) & not(default::obstacle(2, 0)) & not(default::thing(2, 0, marker, clear)) & not(default::obstacle(3, 0)) & not(default::thing(3, 0, marker, clear)) & not(default::obstacle(3, 1)) & not(default::obstacle(3, 2)) & not(default::thing(3,1, marker, clear)) & not(default::thing(3,2, marker, clear)))
	).
i_can_avoid(w, n) :-
	(
		(not(default::obstacle(0, -1)) & not(default::thing(0, -1, marker, clear)) & not(default::obstacle(-1, -1)) & not(default::obstacle(-2, -1)) & not(default::thing(-1, -1, marker, clear)) & not(default::thing(-2, -1, marker, clear))) |
		(not(default::obstacle(0, -1)) & not(default::thing(0, -1, marker, clear)) & not(default::obstacle(0, -2)) & not(default::thing(0, -2, marker, clear)) & not(default::obstacle(-1, -2)) & not(default::obstacle(-2, -2)) & not(default::thing(-1, -2, marker, clear)) & not(default::thing(-2, -2, marker, clear))) |
		(not(default::obstacle(0, -1)) & not(default::thing(0, -1, marker, clear)) & not(default::obstacle(0, -2)) & not(default::thing(0, -2, marker, clear)) & not(default::obstacle(0, -3)) & not(default::thing(0, -3, marker, clear)) & not(default::obstacle(-1, -3)) & not(default::obstacle(-2, -3)) & not(default::thing(-1, -3, marker, clear)) & not(default::thing(-2, -3, marker, clear)))
	).
i_can_avoid(w, s) :-
	(
		(not(default::obstacle(0, 1)) & not(default::thing(0, 1, marker, clear)) & not(default::obstacle(-1, 1)) & not(default::obstacle(-2, 1)) & not(default::thing(-1, 1, marker, clear)) & not(default::thing(-2, 1, marker, clear))) |
		(not(default::obstacle(0, 1)) & not(default::thing(0, 1, marker, clear)) & not(default::obstacle(0, 2)) & not(default::thing(0, 2, marker, clear)) & not(default::obstacle(-1, 2)) & not(default::obstacle(-2, 2)) & not(default::thing(-1, 2, marker, clear)) & not(default::thing(-2, 2, marker, clear))) |
		(not(default::obstacle(0, 1)) & not(default::thing(0, 1, marker, clear)) & not(default::obstacle(0, 2)) & not(default::thing(0, 2, marker, clear)) & not(default::obstacle(0, 3)) & not(default::thing(0, 3, marker, clear))  & not(default::obstacle(-1, 3)) & not(default::obstacle(-2, 3)) & not(default::thing(-1, 3, marker, clear)) & not(default::thing(-2, 3, marker, clear)))
	).
i_can_avoid(e, n) :-
	(
		(not(default::obstacle(0, -1)) & not(default::thing(0, -1, marker, clear)) & not(default::obstacle(1, -1)) & not(default::obstacle(2, -1)) & not(default::thing(1, -1, marker, clear)) & not(default::thing(2, -1, marker, clear))) |
		(not(default::obstacle(0, -1)) & not(default::thing(0, -1, marker, clear)) & not(default::obstacle(0, -2)) & not(default::thing(0, -2, marker, clear)) & not(default::obstacle(1, -2)) & not(default::obstacle(2, -2)) & not(default::thing(1, -2, marker, clear)) & not(default::thing(2, -2, marker, clear))) |
		(not(default::obstacle(0, -1)) & not(default::thing(0, -1, marker, clear)) & not(default::obstacle(0, -2)) & not(default::thing(0, -2, marker, clear)) & not(default::obstacle(0, -3)) & not(default::thing(0, -3, marker, clear)) & not(default::obstacle(1, -3)) & not(default::obstacle(2, -3)) & not(default::thing(1, -3, marker, clear)) & not(default::thing(2, -3, marker, clear)))
	).
i_can_avoid(e, s) :-
	(
		(not(default::obstacle(0, 1)) & not(default::thing(0, 1, marker, clear)) & not(default::obstacle(1, 1)) & not(default::obstacle(2, 1)) & not(default::thing(1, 1, marker, clear)) & not(default::thing(2, 1, marker, clear))) |
		(not(default::obstacle(0, 1)) & not(default::thing(0, 1, marker, clear)) & not(default::obstacle(0, 2)) & not(default::thing(0, 2, marker, clear)) & not(default::obstacle(1, 2)) & not(default::obstacle(2, 2)) & not(default::thing(1, 2, marker, clear)) & not(default::thing(2, 2, marker, clear))) |
		(not(default::obstacle(0, 1)) & not(default::thing(0, 1, marker, clear)) & not(default::obstacle(0, 2)) & not(default::thing(0, 2, marker, clear)) & not(default::obstacle(0, 3)) & not(default::thing(0, 3, marker, clear)) & not(default::obstacle(1, 3)) & not(default::obstacle(2, 3)) & not(default::thing(1, 3, marker, clear)) & not(default::thing(2, 3, marker, clear)))
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

+!retrieve::retrieve_block :
	true
<-
	!retrieve::decide_block_type(Type); .print("I decided to get block type: ", Type);
	!retrieve::get_nearest_dispenser(Type, dispenser(Type, X, Y));
	!retrieve::fetch_block_to_goal(X, Y).

-!retrieve::retrieve_block : true <- !!retrieve::retrieve_block.

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
	!map::get_dispensers(Dispensers);
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
	+retrieve::fetching_block;
	-retrieve::attach_completed;
	while(not retrieve::attach_completed){
		!action::request(Direction);
		while(not default::lastActionResult(success)){
			!action::request(Direction);
		}
		!action::attach(Direction);
		if(default::lastActionResult(success) & default::attached(DispX, DispY)){
			+retrieve::attach_completed;
		}
	}
	-retrieve::fetching_block.

+!retrieve::fetch_block_to_goal(TargetX, TargetY) : 
	true
<- 
	getMyPos(MyX,MyY);
	!retrieve::fetch_block_to_goal_aux(MyX, MyY, TargetX, TargetY).
+!retrieve::fetch_block_to_goal_aux(MyX, MyY, TargetX, TargetY) :	
	neighbour_to_dispenser(MyX, MyY, TargetX, TargetY, Direction)
<-
	//!action::request(Direction);
	//!action::attach(Direction);
	!retrieve::create_and_attach_block(Direction);
	!map::get_goal(GoalList);
	.random(R); .length(GoalList, N);
	.nth(R*(N-1), GoalList, goal(GoalX, GoalY));
	!retrieve::move_to_goal(GoalX, GoalY).
+!retrieve::fetch_block_to_goal_aux(MyX, MyY, TargetX, TargetY) :	
	pick_direction(MyX, MyY, TargetX, TargetY, Direction) 
<-		
	if (exploration::check_obstacle_special_1(Direction)) {
		if(i_can_avoid(Direction, DirectionToGo)){
			.print("GO AROUND OBSTACLE: ", i_can_avoid(Direction, DirectionToGo));
			!retrieve::go_around_obstacle(Direction, DirectionToGo, MyX, MyY, TargetX, TargetY, 0, 20, DirectionObstacle1, 1)
			.print("OBSTACLE AVOIDED");
		} elif(default::energy(Energy) & Energy >= 50 & not exploration::check_agent_special(Direction)){
			!retrieve::smart_clear(Direction);
		} else{
			!retrieve::go_around_obstacle(Direction, TargetX, TargetY, 20);
		}
	} else {
		!retrieve::smart_move(Direction);
	}
	!retrieve::fetch_block_to_goal(TargetX, TargetY).
	
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

+!retrieve::go_around_obstacle(DirectionObstacle, TargetX, TargetY, Threshold) :
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
		!retrieve::go_around_obstacle(DirectionObstacle, Dir, MyX, MyY, TargetX, TargetY, 0, Threshold, DirectionObstacle1, 1);
	} else {
		.random(R);
		if(R < 0.5){
			Dir = n;
		} else{
			Dir = s;
		}
		!retrieve::go_around_obstacle(DirectionObstacle, Dir, MyX, MyY, TargetX, TargetY, 0, Threshold, DirectionObstacle1, 1);
	}
	.
	
+!retrieve::go_around_obstacle(DirectionObstacle, DirectionToGo, MyX, MyY, TargetX, TargetY, Attempts, Threshold, OppositeDirection, _) :
	pick_direction(MyX, MyY, TargetX, TargetY, Direction) & Direction \== DirectionObstacle & 
	opposite(DirectionToGo, DirectionToGo1) & Direction \== DirectionToGo1
<-
	true.
+!retrieve::go_around_obstacle(DirectionObstacle, DirectionToGo, MyX, MyY, TargetX, TargetY, Attempts, Threshold, OppositeDirection, Count) :
	not(exploration::check_obstacle(DirectionObstacle)) & not(exploration::check_agent(DirectionObstacle)) &
	opposite_direction(DirectionToGo, OppositeDirection)
<-
	if(Count > 0){
		!retrieve::smart_move(DirectionObstacle);
		getMyPos(MyX1,MyY1);
		!retrieve::go_around_obstacle(OppositeDirection, DirectionObstacle, MyX, MyY, TargetX, TargetY, 0, Threshold, _, Count-1);
	}
	.
+!retrieve::go_around_obstacle(DirectionObstacle, DirectionToGo, MyX, MyY, TargetX, TargetY, Attempts, Threshold, ActualDirection, Count) :
	Attempts < Threshold & not(exploration::check_obstacle_special_1(DirectionToGo))
<-
	!retrieve::smart_move(DirectionToGo);
	getMyPos(MyX1,MyY1);
	!retrieve::go_around_obstacle(DirectionObstacle, DirectionToGo, MyX1, MyY1, TargetX, TargetY, Attempts+1, Threshold, ActualDirection, Count).
+!retrieve::go_around_obstacle(DirectionObstacle, DirectionToGo, MyX, MyY, TargetX, TargetY, Attempts, Threshold, ActualDirection, Count) :
	opposite_direction(DirectionToGo, OppositeDirection)
<-
	if(default::energy(Energy) & Energy >= 50){
		!retrieve::smart_clear(DirectionObstacle)
	} else {
		.fail
	}.

+!retrieve::move_to_goal(TargetX, TargetY) : 
	true
<- 
	getMyPos(MyX,MyY);
	!retrieve::move_to_goal_aux(MyX, MyY, TargetX, TargetY).
+!retrieve::move_to_goal_aux(TargetX, TargetY, TargetX, TargetY) :	
	true
<-
	!action::rotate(cw);
	!retrieve::move_to_goal_aux(TargetX, TargetY, TargetX, TargetY).
+!retrieve::move_to_goal_aux(MyX, MyY, TargetX, TargetY) :	
	pick_direction(MyX, MyY, TargetX, TargetY, Direction) & i_have_attached_block
<-
	if (exploration::check_obstacle_special_1(Direction)) {
		if(i_can_avoid(Direction, DirectionToGo)){
			.print("GO AROUND OBSTACLE");
			!retrieve::go_around_obstacle(Direction, DirectionToGo, MyX, MyY, TargetX, TargetY, 0, 20, DirectionObstacle1, 1)
			.print("OBSTACLE AVOIDED");
		} elif(default::energy(Energy) & Energy >= 50){
			!retrieve::smart_clear(Direction);
		} else{
			!retrieve::go_around_obstacle(Direction, TargetX, TargetY, 20);
		}
		!retrieve::move_to_goal(TargetX, TargetY)
	} else {
		!retrieve::smart_move(Direction);
		!retrieve::move_to_goal(TargetX, TargetY)
	}
	.


-!retrieve::move_to_goal(TargetX, TargetY) : true <- !!retrieve::move_to_goal(TargetX, TargetY).
	
+!retrieve::smart_clear(Direction) :
	default::energy(Energy) & Energy >= 50
<-
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
	!action::clear(ClearX, ClearY);
	!action::clear(ClearX, ClearY);
	!action::clear(ClearX, ClearY).

	
	
	
	