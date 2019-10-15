check_obstacle(n) :- default::obstacle(0,-1) | default::obstacle(0,-2) | default::thing(0,-1,block,_) | default::thing(0,-2,block,_). //| default::obstacle(0,-3) | default::obstacle(0,-4) | default::obstacle(0,-5).
check_obstacle(s) :- default::obstacle(0,1) | default::obstacle(0,2) | default::thing(0,1,block,_) | default::thing(0,2,block,_). //| default::obstacle(0,3) | default::obstacle(0,4) | default::obstacle(0,5).
check_obstacle(e) :- default::obstacle(1,0) | default::obstacle(2,0) | default::thing(1,0,block,_) | default::thing(2,0,block,_). //| default::obstacle(3,0) | default::obstacle(4,0) | default::obstacle(5,0).
check_obstacle(w) :- default::obstacle(-1,0) | default::obstacle(-2,0) | default::thing(-1,0,block,_) | default::thing(-2,0,block,_). //| default::obstacle(-3,0) | default::obstacle(-4,0) | default::obstacle(-5,0).

check_obstacle_special(n) :- default::obstacle(0,-1) | (default::thing(0, -1, Type, _) & Type \== dispenser & Type \== marker & not(retrieve::block(0, -1))).
check_obstacle_special(s) :- default::obstacle(0,1)  | (default::thing(0, 1, Type, _) & Type \== dispenser & Type \== marker & not(retrieve::block(0, 1))).
check_obstacle_special(e) :- default::obstacle(1,0)  | (default::thing(1, 0, Type, _) & Type \== dispenser & Type \== marker & not(retrieve::block(1, 0))).
check_obstacle_special(w) :- default::obstacle(-1,0) | (default::thing(-1, 0, Type, _) & Type \== dispenser & Type \== marker & not(retrieve::block(-1, 0))).

check_obstacle_special_1(n, 1) :- retrieve::block(0, -1) & (default::obstacle(0, -2) | (default::thing(0, -2, Type, _) & Type \== dispenser & Type \== marker)).
check_obstacle_special_1(n, 1) :- not(retrieve::block(0, -1)) & (default::obstacle(0, -1) | (default::thing(0, -1, Type, _) & Type \== dispenser & Type \== marker)).
check_obstacle_special_1(s, 1) :- retrieve::block(0, 1) & (default::obstacle(0, 2) | (default::thing(0, 2, Type, _) & Type \== dispenser & Type \== marker)).
check_obstacle_special_1(s, 1) :- not(retrieve::block(0, 1)) & (default::obstacle(0, 1) | (default::thing(0, 1, Type, _) & Type \== dispenser & Type \== marker)).
check_obstacle_special_1(w, 1) :- retrieve::block(-1, 0) & (default::obstacle(-2, 0) | (default::thing(-2, 0, Type, _) & Type \== dispenser & Type \== marker)).
check_obstacle_special_1(w, 1) :- not(retrieve::block(-1, 0)) & (default::obstacle(-1, 0) | (default::thing(-1, 0, Type, _) & Type \== dispenser & Type \== marker)).
check_obstacle_special_1(e, 1) :- retrieve::block(1, 0) & (default::obstacle(2, 0) | (default::thing(2, 0, Type, _) & Type \== dispenser & Type \== marker)).
check_obstacle_special_1(e, 1) :- not(retrieve::block(1, 0)) & (default::obstacle(1, 0) | (default::thing(1, 0, Type, _) & Type \== dispenser & Type \== marker)).
check_obstacle_special_1(n, 2) :- retrieve::block(0, -1) & (default::obstacle(0, -2) | default::obstacle(0, -3) | (default::thing(0, -2, Type, _) & Type \== dispenser & Type \== marker) | (default::thing(0, -3, Type1, _) & Type1 \== dispenser & Type1 \== marker)).
check_obstacle_special_1(n, 2) :- not(retrieve::block(0, -1)) & (default::obstacle(0, -1) | default::obstacle(0, -2) | (default::thing(0, -1, Type, _) & Type \== dispenser & Type \== marker) | (default::thing(0, -2, Type, _) & Type \== dispenser & Type \== marker)).
check_obstacle_special_1(s, 2) :- retrieve::block(0, 1) & (default::obstacle(0, 2) | default::obstacle(0, 3) | (default::thing(0, 2, Type, _) & Type \== dispenser & Type \== marker) | (default::thing(0, 3, Type1, _) & Type1 \== dispenser & Type1 \== marker)).
check_obstacle_special_1(s, 2) :- not(retrieve::block(0, 1)) & (default::obstacle(0, 1) | default::obstacle(0, 2) | (default::thing(0, 1, Type, _) & Type \== dispenser & Type \== marker) | (default::thing(0, 2, Type1, _) & Type1 \== dispenser & Type1 \== marker)).
check_obstacle_special_1(w, 2) :- retrieve::block(-1, 0) & (default::obstacle(-2, 0) | default::obstacle(-3, 0) | (default::thing(-2, 0, Type, _) & Type \== dispenser & Type \== marker) | (default::thing(-3, 0, Type1, _) & Type1 \== dispenser & Type1 \== marker)).
check_obstacle_special_1(w, 2) :- not(retrieve::block(-1, 0)) & (default::obstacle(-1, 0) | default::obstacle(-2, 0) | (default::thing(-1, 0, Type, _) & Type \== dispenser & Type \== marker) | (default::thing(-2, 0, Type1, _) & Type1 \== dispenser & Type1 \== marker)).
check_obstacle_special_1(e, 2) :- retrieve::block(1, 0) & (default::obstacle(2, 0) | default::obstacle(3, 0) | (default::thing(2, 0, Type, _) & Type \== dispenser & Type \== marker) | (default::thing(3, 0, Type1, _) & Type1 \== dispenser & Type1 \== marker)).
check_obstacle_special_1(e, 2) :- not(retrieve::block(1, 0)) & (default::obstacle(1, 0) | default::obstacle(2, 0) | (default::thing(1, 0, Type, _) & Type \== dispenser & Type \== marker) | (default::thing(2, 0, Type1, _) & Type1 \== dispenser & Type1 \== marker)).

check_obstacle_all(n) :- default::obstacle(0,-1) | default::thing(0, -1, Thing, _) & (Thing == entity | Thing == block).
check_obstacle_all(s) :- default::obstacle(0,1) | default::thing(0, 1, Thing, _) & (Thing == entity | Thing == block).
check_obstacle_all(e) :- default::obstacle(1,0) | default::thing(1, 0, Thing, _) & (Thing == entity | Thing == block).
check_obstacle_all(w) :- default::obstacle(-1,0) | default::thing(-1, 0, Thing, _) & (Thing == entity | Thing == block).

check_agent(n) :- ( default::thing(0, -1, entity, _) | (default::thing(0, -1, block, _) & retrieve::block(0,-1) & default::thing(0, -2, entity, _)) | (default::thing(-1, 0, block, _) & retrieve::block(-1,0) & default::thing(-1, -1, entity, _)) | (default::thing(0, 1, block, _) & retrieve::block(0,1) & default::thing(1, -1, entity, _))). 
check_agent(s) :- ( default::thing(0, 1, entity, _) | (default::thing(0, 1, block, _) & retrieve::block(0,1) & default::thing(0, 2, entity, _))  | (default::thing(1, 0, block, _) & retrieve::block(1,0) & default::thing(1, 1, entity, _))  | (default::thing(-1, 0, block, _) & retrieve::block(-1,0) & default::thing(-1, 1, entity, _))). 
check_agent(e) :- ( default::thing(1, 0, entity, _) | (default::thing(1, 0, block, _) & retrieve::block(1,0) & default::thing(2, 0, entity, _)) | (default::thing(0, -1, block, _) & retrieve::block(0,-1) & default::thing(1, -1, entity, _))  | (default::thing(0, 1, block, _) & retrieve::block(0,1) & default::thing(1, 1, entity, _))). 
check_agent(w) :- ( default::thing(-1, 0, entity, _) | (default::thing(-1, 0, block, _) & retrieve::block(-1,0) & default::thing(-2, 0, entity, _)) | (default::thing(0, 1, block, _) & retrieve::block(0,1) & default::thing(-1, 1, entity, _)) | (default::thing(0, -1, block, _) & retrieve::block(0,-1) & default::thing(-1, -1, entity, _))).

check_agent_special(n) :- retrieve::block(0, -1) & default::thing(0, -2, entity, _).
check_agent_special(n) :- (not retrieve::block(0, -1)) & default::thing(0, -1, entity, _).
check_agent_special(s) :- retrieve::block(0, 1) & default::thing(0, 2, entity, _).
check_agent_special(s) :- (not retrieve::block(0, 1)) & default::thing(0, 1, entity, _).
check_agent_special(e) :- retrieve::block(1, 0) & default::thing(2, 0, entity, _).
check_agent_special(e) :- (not retrieve::block(0, -1)) & default::thing(1, 0, entity, _).
check_agent_special(w) :- retrieve::block(-1, 0) & default::thing(-2, 0, entity, _).
check_agent_special(w) :- (not retrieve::block(-1, 0)) & default::thing(-1, 0, entity, _).

prune_direction([],PrunedDirListTemp,PrunedDirList) :- PrunedDirList = PrunedDirListTemp.
prune_direction([Dir|L],PrunedDirListTemp,PrunedDirList) :- check_obstacle(Dir) & prune_direction(L,PrunedDirListTemp,PrunedDirList).
prune_direction([Dir|L],PrunedDirListTemp,PrunedDirList) :- not check_obstacle(Dir) & prune_direction(L,[Dir|PrunedDirListTemp],PrunedDirList).

prune_direction_special([],PrunedDirListTemp,PrunedDirList) :- PrunedDirList = PrunedDirListTemp.
prune_direction_special([Dir|L],PrunedDirListTemp,PrunedDirList) :- check_obstacle_special(Dir) & prune_direction_special(L,PrunedDirListTemp,PrunedDirList).
prune_direction_special([Dir|L],PrunedDirListTemp,PrunedDirList) :- not check_obstacle_special(Dir) & prune_direction_special(L,[Dir|PrunedDirListTemp],PrunedDirList).

random_dir(PrunedDirList,4,Number,Dir) :- (Number <= 0.25 & .nth(0,PrunedDirList,Dir)) | (Number <= 0.5 & .nth(1,PrunedDirList,Dir)) | (Number <= 0.75 & .nth(2,PrunedDirList,Dir)) | (.nth(3,PrunedDirList,Dir)).
random_dir(PrunedDirList,3,Number,Dir) :- (Number <= 0.33 & .nth(0,PrunedDirList,Dir)) | (Number <= 0.66 & .nth(1,PrunedDirList,Dir)) | (.nth(2,PrunedDirList,Dir)).
random_dir(PrunedDirList,2,Number,Dir) :- (Number <= 0.5 & .nth(0,PrunedDirList,Dir)) | (.nth(1,PrunedDirList,Dir)).
random_dir([Dir|T],1,Number,Dir).

remove_opposite(n,s) :- true.
remove_opposite(s,n) :- true.
remove_opposite(e,w) :- true.
remove_opposite(w,e) :- true.

get_clear_direction(n,X,Y) :- X = 0 & Y = -2.
get_clear_direction(s,X,Y) :- X = 0 & Y = 2.
get_clear_direction(w,X,Y) :- X = -2 & Y = 0.
get_clear_direction(e,X,Y) :- X = 2 & Y = 0.

get_other_side(n,OtherDir1,OtherDir2) :- OtherDir1 = w & OtherDir2 = e.
get_other_side(s,OtherDir1,OtherDir2) :- OtherDir1 = w & OtherDir2 = e.
get_other_side(w,OtherDir1,OtherDir2) :- OtherDir1 = n & OtherDir2 = s.
get_other_side(e,OtherDir1,OtherDir2) :- OtherDir1 = n & OtherDir2 = s.

+!explore(DirList) 
	: common::my_role(explorer) & check_agent_special(n) & check_agent_special(s) & check_agent_special(e) & check_agent_special(w)  & .random(Number) & random_dir([n,s,e,w],4,Number,Dir)
<-
	.print("There is a friendly agent in all possible directions, trying to move randomly.");
	!action::move(Dir);
	!explore([n,s,e,w]);
	.

+!explore(DirList) 
	: common::my_role(explorer) & prune_direction(DirList,[],PrunedDirList)  & not .empty(PrunedDirList) & .length(PrunedDirList,Length) & .random(Number) & random_dir(PrunedDirList,Length,Number,Dir)
<-
	 !explore_until_obstacle(Dir);
	 .

+!explore(Dirlist)
	: (default::obstacle(0,1) | default::obstacle(0,2)) & (default::obstacle(0,-1) | default::obstacle(0,-2)) & (default::obstacle(1,0) | default::obstacle(2,0)) & (default::obstacle(-1,0) | default::obstacle(-2,0)) & common::my_role(explorer) & .random(Number) & random_dir([n,s,e,w],4,Number,Dir) & default::energy(Energy) & Energy >= 240 // & default::vision(V) & common::find_empty_position(X,Y,1,V)
<-
	.print("@@@@@ No movement options available");
	!action::skip;
	!try_to_clear(Dir);
//	!action::skip;
//	!planner::generate_goal(X, Y, notblock);
//	!!explore(Dirlist);
////	!default::always_skip;
	.

// special case	
+!explore(Dirlist)
	: common::my_role(explorer) & prune_direction_special([n,s,e,w],[],PrunedDirList) & not .empty(PrunedDirList) & .length(PrunedDirList,Length) & .random(Number) & random_dir(PrunedDirList,Length,Number,FirstDir)
<-
	?remove_opposite(FirstDir,OppDir);
	?get_other_side(FirstDir,OtherDir1,OtherDir2);
	if (check_obstacle(FirstDir) &  check_obstacle(OppDir) & (check_obstacle(OtherDir1) | check_obstacle(OtherDir2)) & default::energy(Energy) & default::energy(Energy) & Energy < 240) {
		if (not check_obstacle(OtherDir1)) {
			!explore_until_obstacle(OtherDir1);
		}
		elif (not check_obstacle(OtherDir2)) {
			!explore_until_obstacle(OtherDir2);
		}
		else {
			!action::skip;
			!!explore(Dirlist);
		}
		
	}
	else {
		+special(first);
		!explore_until_obstacle_special(FirstDir);
	}
	.
	
+!explore(Dirlist)
	: common::my_role(explorer)
<-
	!action::skip;
	!!explore([n,s,e,w]);
	.

+!explore(Dirlist).

// TODO what to do if I see an agent of another team (just keep trying won't solve it if the other team does the same)?
// TODO what about a block?

+!try_to_clear(Dir)
<-
	?get_clear_direction(Dir,X,Y);
	if (not check_obstacle(Dir)) {
		!action::move(Dir);
	}
	for(.range(I, 1, 3)){
		if ((not default::lastAction(clear) | default::lastAction(clear)) & (default::lastActionResult(success) | default::lastActionResult(failed_random))) {
			!action::clear(X,Y);
		}
	}
	if (Dir == n) {
		if (default::obstacle(X,Y-1) | default::obstacle(X,Y-2)) {
			for(.range(I, 1, 3)){
				if ((not default::lastAction(clear) | default::lastAction(clear)) & (default::lastActionResult(success) | default::lastActionResult(failed_random))) {
					!action::clear(X,Y-2);
				}
			}
		}
	}
	elif (Dir == s) {
		if (default::obstacle(X,Y+1) | default::obstacle(X,Y+2)) {
			for(.range(I, 1, 3)){
				if ((not default::lastAction(clear) | default::lastAction(clear)) & (default::lastActionResult(success) | default::lastActionResult(failed_random))) {
					!action::clear(X,Y+2);
				}
			}
		}
	}
	elif (Dir == w) {
		if (default::obstacle(X-1,Y) | default::obstacle(X-2,Y)) {
			for(.range(I, 1, 3)){
				if ((not default::lastAction(clear) | default::lastAction(clear)) & (default::lastActionResult(success) | default::lastActionResult(failed_random))) {
					!action::clear(X-2,Y);
				}
			}
		}
	}
	else {
		if (default::obstacle(X+1,Y) | default::obstacle(X+2,Y)) {
			for(.range(I, 1, 3)){
				if ((not default::lastAction(clear) | default::lastAction(clear)) & (default::lastActionResult(success) | default::lastActionResult(failed_random))) {
					!action::clear(X+2,Y);
				}
			}
		}
	}
	if (not check_obstacle(Dir)) {
		!action::move(Dir);
		!!explore_until_obstacle(Dir);
	}
	else {
		.delete(Dir,[n,s,e,w],DirList);
		!!explore(DirList);
	}
	.

+!explore_until_obstacle(Dir)
	: common::my_role(explorer) & check_agent(Dir)
<-
	.print("I see someone from my team, time to *try* to go around it.");
	!common::go_around(Dir);
	!explore_until_obstacle(Dir);
	.
	
+!explore_until_obstacle(Dir)
	: common::my_role(explorer) & action::out_of_bounds(Dir)
<-
	-action::out_of_bounds(Dir);
	.delete(Dir,[n,s,e,w],DirList);
	!!explore(DirList);
	.

+!explore_until_obstacle(Dir)
	: common::my_role(explorer) & not check_obstacle(Dir) & not action::out_of_bounds(Dir)
<-
	!action::move(Dir);
	!!explore_until_obstacle(Dir);
	.
	
+!explore_until_obstacle(Dir)
	: common::my_role(explorer) & check_obstacle(Dir) & default::energy(Energy) & Energy >= 240
<-
	!try_to_clear(Dir);
	.
	
+!explore_until_obstacle(Dir)
	: common::my_role(explorer) & .delete(Dir,[n,s,e,w],DirAux) & remove_opposite(Dir,NewDir) & .delete(NewDir,DirAux,DirList) 
<-
	!!explore(DirList);
	.
	
+!explore_until_obstacle(Dir)
	: common::my_role(explorer)
<-
	!action::skip;
	!!explore([n,s,e,w]);
	.

+!explore_until_obstacle(Dir).
	
+!explore_until_obstacle_special(Dir)
	: common::my_role(explorer) & not exploration::special(_) 
<-
	!explore_until_obstacle(Dir);
	.

+!explore_until_obstacle_special(Dir)
	: common::my_role(explorer) & exploration::special(_) & check_agent(Dir)
<-
	.print("I see someone from my team, time to *try* to go around it.");
	!common::go_around(Dir);
	!explore_until_obstacle_special(Dir);
	.
	
+!explore_until_obstacle_special(Dir)
	: common::my_role(explorer) & exploration::special(S) & action::out_of_bounds(Dir)
<-
	-exploration::special(S);
	-action::out_of_bounds(Dir);
	.delete(Dir,[n,s,e,w],DirList);
	!!explore(DirList);
	.

+!explore_until_obstacle_special(Dir)
	: common::my_role(explorer) & exploration::special(_) & not check_obstacle_special(Dir) & not action::out_of_bounds(Dir)
<-
	!action::move(Dir);
	!!explore_until_obstacle_special(Dir);
	.
	
+!explore_until_obstacle_special(Dir)
	: common::my_role(explorer) & exploration::special(first) & .delete(Dir,[n,s,e,w],DirAux) & remove_opposite(Dir,NewDir) & .delete(NewDir,DirAux,DirList) & prune_direction_special(DirList,[],PrunedDirList) & not .empty(PrunedDirList) & .length(PrunedDirList,Length) & .random(Number) & random_dir(PrunedDirList,Length,Number,SecondDir)
<-
	!action::move(SecondDir);
	-special(first);
	+special(second);
	!!explore_until_obstacle_special(SecondDir);
	.
	
+!explore_until_obstacle_special(Dir)
	: common::my_role(explorer) & exploration::special(first) & .delete(Dir,[n,s,e,w],DirAux) & remove_opposite(Dir,NewDir) & .delete(NewDir,DirAux,DirList) & prune_direction_special(DirList,[],PrunedDirList) & .empty(PrunedDirList) & not check_obstacle_special(NewDir)
<-
	!action::move(NewDir);
	!!explore_until_obstacle_special(NewDir);
	.
	
+!explore_until_obstacle_special(Dir)
	: common::my_role(explorer) & exploration::special(second) & .delete(Dir,[n,s,e,w],DirAux) & remove_opposite(Dir,NewDir) & .delete(NewDir,DirAux,DirList) 
<-
	-special(second);
	!!explore(DirList);
	.
	
+!explore_until_obstacle_special(Dir)
	: default::obstacle(0,1) & default::obstacle(0,-1) & default::obstacle(1,0) & default::obstacle(-1,0) & common::my_role(explorer)
<-
	.print("@@@@@ No movement options available AT SPECIAL, sending skip forever");
	!default::always_skip;
	.

+!explore_until_obstacle_special(Dir)
	: common::my_role(explorer)
<-
	!action::skip;
	-special(_);
	!!explore([n,s,e,w]);
	.

+!explore_until_obstacle_special(Dir).
