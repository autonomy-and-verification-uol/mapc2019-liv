check_obstacle(n) :- default::obstacle(0,-1) | default::obstacle(0,-2). //| default::obstacle(0,-3) | default::obstacle(0,-4) | default::obstacle(0,-5).
check_obstacle(s) :- default::obstacle(0,1) | default::obstacle(0,2). //| default::obstacle(0,3) | default::obstacle(0,4) | default::obstacle(0,5).
check_obstacle(e) :- default::obstacle(1,0) | default::obstacle(2,0). //| default::obstacle(3,0) | default::obstacle(4,0) | default::obstacle(5,0).
check_obstacle(w) :- default::obstacle(-1,0) | default::obstacle(-2,0). //| default::obstacle(-3,0) | default::obstacle(-4,0) | default::obstacle(-5,0).

check_obstacle_special(n) :- default::obstacle(0,-1) | (default::thing(0, -1, Type, _) & Type \== dispenser & Type \== marker & not(default::attached(0, -1))).
check_obstacle_special(s) :- default::obstacle(0,1)  | (default::thing(0, 1, Type, _) & Type \== dispenser & Type \== marker & not(default::attached(0, 1))).
check_obstacle_special(e) :- default::obstacle(1,0)  | (default::thing(1, 0, Type, _) & Type \== dispenser & Type \== marker & not(default::attached(1, 0))).
check_obstacle_special(w) :- default::obstacle(-1,0) | (default::thing(-1, 0, Type, _) & Type \== dispenser & Type \== marker & not(default::attached(-1, 0))).

check_obstacle_special_1(n) :- default::attached(0, -1) & (default::obstacle(0, -2) | (default::thing(0, -2, Type, _) & Type \== dispenser & Type \== marker)).
check_obstacle_special_1(n) :- not(default::attached(0, -1)) & (default::obstacle(0, -1) | (default::thing(0, -1, Type, _) & Type \== dispenser & Type \== marker)).
check_obstacle_special_1(s) :- default::attached(0, 1) & (default::obstacle(0, 2) | (default::thing(0, 2, Type, _) & Type \== dispenser & Type \== marker)).
check_obstacle_special_1(s) :- not(default::attached(0, 1)) & (default::obstacle(0, 1) | (default::thing(0, 1, Type, _) & Type \== dispenser & Type \== marker)).
check_obstacle_special_1(w) :- default::attached(-1, 0) & (default::obstacle(-2, 0) | (default::thing(-2, 0, Type, _) & Type \== dispenser & Type \== marker)).
check_obstacle_special_1(w) :- not(default::attached(-1, 0)) & (default::obstacle(-1, 0) | (default::thing(-1, 0, Type, _) & Type \== dispenser & Type \== marker)).
check_obstacle_special_1(e) :- default::attached(1, 0) & (default::obstacle(2, 0) | (default::thing(2, 0, Type, _) & Type \== dispenser & Type \== marker)).
check_obstacle_special_1(e) :- not(default::attached(1, 0)) & (default::obstacle(1, 0) | (default::thing(1, 0, Type, _) & Type \== dispenser & Type \== marker)).

check_obstacle_all(n) :- default::obstacle(0,-1) | default::thing(0, -1, Thing, _) & (Thing == entity | Thing == block).
check_obstacle_all(s) :- default::obstacle(0,1) | default::thing(0, 1, Thing, _) & (Thing == entity | Thing == block).
check_obstacle_all(e) :- default::obstacle(1,0) | default::thing(1, 0, Thing, _) & (Thing == entity | Thing == block).
check_obstacle_all(w) :- default::obstacle(-1,0) | default::thing(-1, 0, Thing, _) & (Thing == entity | Thing == block).

check_agent(n) :- default::team(Team) & ( default::thing(0, -1, entity, Team) | (default::thing(0, -1, block, _) & default::attached(0,-1) & default::thing(0, -2, entity, Team)) | (default::thing(-1, 0, block, _) & default::attached(-1,0) & default::thing(-1, -1, entity, Team)) | (default::thing(0, 1, block, _) & default::attached(0,1) & default::thing(1, -1, entity, Team))). 
check_agent(s) :- default::team(Team) & ( default::thing(0, 1, entity, Team) | (default::thing(0, 1, block, _) & default::attached(0,1) & default::thing(0, 2, entity, Team))  | (default::thing(1, 0, block, _) & default::attached(1,0) & default::thing(1, 1, entity, Team))  | (default::thing(-1, 0, block, _) & default::attached(-1,0) & default::thing(-1, 1, entity, Team))). 
check_agent(e) :- default::team(Team) & ( default::thing(1, 0, entity, Team) | (default::thing(1, 0, block, _) & default::attached(1,0) & default::thing(2, 0, entity, Team)) | (default::thing(0, -1, block, _) & default::attached(0,-1) & default::thing(1, -1, entity, Team))  | (default::thing(0, 1, block, _) & default::attached(0,1) & default::thing(1, 1, entity, Team))). 
check_agent(w) :- default::team(Team) & ( default::thing(-1, 0, entity, Team) | (default::thing(-1, 0, block, _) & default::attached(-1,0) & default::thing(-2, 0, entity, Team)) | (default::thing(0, 1, block, _) & default::attached(0,1) & default::thing(-1, 1, entity, Team)) | (default::thing(0, -1, block, _) & default::attached(0,-1) & default::thing(-1, -1, entity, Team))).

check_agent_special(n) :- default::attached(0, -1) & default::team(Team) & default::thing(0, -2, entity, Team).
check_agent_special(n) :- (not default::attached(0, -1)) & default::team(Team) & default::thing(0, -1, entity, Team).
check_agent_special(s) :- default::attached(0, 1) & default::team(Team) & default::thing(0, 2, entity, Team).
check_agent_special(s) :- (not default::attached(0, 1)) & default::team(Team) & default::thing(0, 1, entity, Team).
check_agent_special(e) :- default::attached(1, 0) & default::team(Team) & default::thing(2, 0, entity, Team).
check_agent_special(e) :- (not default::attached(0, -1)) & default::team(Team) & default::thing(1, 0, entity, Team).
check_agent_special(w) :- default::attached(-1, 0) & default::team(Team) & default::thing(-2, 0, entity, Team).
check_agent_special(w) :- (not default::attached(-1, 0)) & default::team(Team) & default::thing(-1, 0, entity, Team).

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



+!explore(DirList) 
	: explorer & check_agent_special(n) & check_agent_special(s) & check_agent_special(e) & check_agent_special(w) & random_dir([n,s,e,w],4,Number,Dir)
<-
	.print("There is a friendly agent in all possible directions, trying to move randomly.");
	!action::move(Dir);
	!explore([n,s,e,w]);
	.

+!explore(DirList) 
	: explorer & prune_direction(DirList,[],PrunedDirList)  & not .empty(PrunedDirList) & .length(PrunedDirList,Length) & .random(Number) & random_dir(PrunedDirList,Length,Number,Dir)
<-
	 !explore_until_obstacle(Dir);
	 .
	
// special case	
+!explore(Dirlist)
	: explorer & prune_direction_special([n,s,e,w],[],PrunedDirList) & not .empty(PrunedDirList) & .length(PrunedDirList,Length) & .random(Number) & random_dir(PrunedDirList,Length,Number,FirstDir) 
<-
	+special(first);
	!explore_until_obstacle_special(FirstDir);
	.

+!explore(Dirlist)
	: explorer
<-
	.print("@@@@@ No movement options available, sending skip forever");
	//!default::always_skip;
	.

// TODO what to do if I see an agent of another team (just keep trying won't solve it if the other team does the same)?
// TODO what about a block?


+!explore_until_obstacle(Dir)
	: explorer & check_agent(Dir)
<-
	.print("I see someone from my team, time to *try* to go around it.");
	!common::go_around(Dir);
	!explore_until_obstacle(Dir);
	.
	
+!explore_until_obstacle(Dir)
	: explorer & action::out_of_bounds(Dir)
<-
	-action::out_of_bounds(Dir);
	.delete(Dir,[n,s,e,w],DirList);
	!!explore(DirList);
	.

+!explore_until_obstacle(Dir)
	: explorer & not check_obstacle(Dir) & not action::out_of_bounds(Dir)
<-
	!action::move(Dir);
	!!explore_until_obstacle(Dir);
	.
	
+!explore_until_obstacle(Dir)
	: explorer & .delete(Dir,[n,s,e,w],DirAux) & remove_opposite(Dir,NewDir) & .delete(NewDir,DirAux,DirList) 
<-
	!!explore(DirList);
	.
	
+!explore_until_obstacle_special(Dir)
	: explorer & not exploration::special(_) 
<-
	!explore_until_obstacle(Dir);
	.

+!explore_until_obstacle_special(Dir)
	: explorer & exploration::special(_) & check_agent(Dir)
<-
	.print("I see someone from my team, time to *try* to go around it.");
	!common::go_around(Dir);
	!explore_until_obstacle_special(Dir);
	.
	
+!explore_until_obstacle_special(Dir)
	: explorer & exploration::special(S) & action::out_of_bounds(Dir)
<-
	-exploration::special(S);
	-action::out_of_bounds(Dir);
	.delete(Dir,[n,s,e,w],DirList);
	!!explore(DirList);
	.

+!explore_until_obstacle_special(Dir)
	: explorer & exploration::special(_) & not check_obstacle_special(Dir) & not action::out_of_bounds(Dir)
<-
	!action::move(Dir);
	!!explore_until_obstacle_special(Dir);
	.
	
+!explore_until_obstacle_special(Dir)
	: explorer & exploration::special(first) & .delete(Dir,[n,s,e,w],DirAux) & remove_opposite(Dir,NewDir) & .delete(NewDir,DirAux,DirList) & prune_direction_special(DirList,[],PrunedDirList) & not .empty(PrunedDirList) & .length(PrunedDirList,Length) & .random(Number) & random_dir(PrunedDirList,Length,Number,SecondDir)
<-
	!action::move(SecondDir);
	-special(first);
	+special(second);
	!!explore_until_obstacle_special(SecondDir);
	.
	
+!explore_until_obstacle_special(Dir)
	: explorer & exploration::special(first) & .delete(Dir,[n,s,e,w],DirAux) & remove_opposite(Dir,NewDir) & .delete(NewDir,DirAux,DirList) & prune_direction_special(DirList,[],PrunedDirList) & .empty(PrunedDirList) & not check_obstacle_special(NewDir)
<-
	!action::move(NewDir);
	!!explore_until_obstacle_special(NewDir);
	.
	
+!explore_until_obstacle_special(Dir)
	: explorer & exploration::special(second) & .delete(Dir,[n,s,e,w],DirAux) & remove_opposite(Dir,NewDir) & .delete(NewDir,DirAux,DirList) 
<-
	-special(second);
	!!explore(DirList);
	.
	
+!explore_until_obstacle_special(Dir)
	: explorer
<-
	.print("@@@@@ No movement options available AT SPECIAL, sending skip forever");
	//!default::always_skip;
	.
	