check_obstacle(n) :- default::obstacle(0,-1) | default::obstacle(0,-2) | default::obstacle(0,-3) | default::obstacle(0,-4) | default::obstacle(0,-5).
check_obstacle(s) :- default::obstacle(0,1) | default::obstacle(0,2) | default::obstacle(0,3) | default::obstacle(0,4) | default::obstacle(0,5).
check_obstacle(e) :- default::obstacle(1,0) | default::obstacle(2,0) | default::obstacle(3,0) | default::obstacle(4,0) | default::obstacle(5,0).
check_obstacle(w) :- default::obstacle(-1,0) | default::obstacle(-2,0) | default::obstacle(-3,0) | default::obstacle(-4,0) | default::obstacle(-5,0).

check_obstacle_special(n) :- default::obstacle(0,-1).
check_obstacle_special(s) :- default::obstacle(0,1).
check_obstacle_special(e) :- default::obstacle(1,0).
check_obstacle_special(w) :- default::obstacle(-1,0).

check_agent(n) :- default::team(Team) & ( default::thing(0, -1, entity, Team) | default::thing(0, -2, entity, Team) | default::thing(0, -3, entity, Team) | default::thing(0, -4, entity, Team) | default::thing(0, -5, entity, Team)).
check_agent(s) :- default::team(Team) & ( default::thing(0, 1, entity, Team) | default::thing(0, 2, entity, Team) | default::thing(0, 3, entity, Team) | default::thing(0, 4, entity, Team) | default::thing(0, 5, entity, Team)).
check_agent(e) :- default::team(Team) & ( default::thing(1, 0, entity, Team) | default::thing(2, 0, entity, Team) | default::thing(3, 0, entity, Team) | default::thing(4, 0, entity, Team) | default::thing(5, 0, entity, Team)).
check_agent(w) :- default::team(Team) & ( default::thing(-1, 0, entity, Team) | default::thing(-2, 0, entity, Team) | default::thing(-3, 0, entity, Team) | default::thing(-4, 0, entity, Team) | default::thing(-5, 0, entity, Team)).

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
	: prune_direction(DirList,[],PrunedDirList)  & not .empty(PrunedDirList) & .length(PrunedDirList,Length) & .random(Number) & random_dir(PrunedDirList,Length,Number,Dir)
<-
	 !explore_until_obstacle(Dir);
	 .
	 
+!explore(DirList)
	: prune_direction(DirList,[],PrunedDirList) & not .empty(PrunedDirList) & opposite(NewDir)  & .member(NewDir,PrunedDirList)
<-
	-opposite(NewDir);
	!explore_until_obstacle(NewDir);
	.
	
// special case	
+!explore(Dirlist)
	: prune_direction_special([n,s,e,w],[],PrunedDirList) & not .empty(PrunedDirList) & .length(PrunedDirList,Length) & .random(Number) & random_dir(PrunedDirList,Length,Number,FirstDir) 
<-
	!explore_until_obstacle_special_first(FirstDir);
	.

+!explore(Dirlist)
	: true
<-
	.print("@@@@@ No movement options available. Should never happen!");
	.

// TODO what to do if I see an agent of another team (just keep trying won't solve it if the other team does the same)?
// TODO what about a block?


+!explore_until_obstacle(Dir)
	: check_agent(Dir) & .delete(Dir,[n,s,e,w],DirList) 
<-
	.print("I see someone from my team, time to pick another direction.");
	!!explore(DirList);
	.

+!explore_until_obstacle(Dir)
	: not check_obstacle(Dir)
<-
	!action::move(Dir);
	!!explore_until_obstacle(Dir);
	.
	
+!explore_until_obstacle(Dir)
	: .delete(Dir,[n,s,e,w],DirAux) & remove_opposite(Dir,NewDir) & .delete(NewDir,DirAux,DirList) 
<-
	+opposite(NewDir);
	!!explore(DirList);
	.

//TODO SHOULD GO AROUND THE AGENT IN THIS CASE
+!explore_until_obstacle_special_first(Dir)
	: check_agent(Dir) & .delete(Dir,[n,s,e,w],DirList) 
<-
	.print("I see someone from my team, time to pick another direction.");
	!!explore(DirList);
	.

+!explore_until_obstacle_special_first(Dir)
	: not check_obstacle_special(Dir)
<-
	!action::move(Dir);
	!!explore_until_obstacle_special_first(Dir);
	.
	
+!explore_until_obstacle_special_first(Dir)
	: .delete(Dir,[n,s,e,w],DirAux) & remove_opposite(Dir,NewDir) & .delete(NewDir,DirAux,DirList) & prune_direction_special(DirList,[],PrunedDirList) & not .empty(PrunedDirList) & .length(PrunedDirList,Length) & .random(Number) & random_dir(PrunedDirList,Length,Number,SecondDir)
<-
	!action::move(SecondDir);
	!!explore_until_obstacle_special_second(SecondDir);
	.
	
+!explore_until_obstacle_special_first(Dir)
	: true
<-
	.print("@@@@@ No movement options available AT SPECIAL FIRST. Should never happen!");
	.

//TODO SHOULD GO AROUND THE AGENT IN THIS CASE	
+!explore_until_obstacle_special_second(Dir)
	: check_agent(Dir) & .delete(Dir,[n,s,e,w],DirList) 
<-
	.print("I see someone from my team, time to pick another direction.");
	!!explore(DirList);
	.

+!explore_until_obstacle_special_second(Dir)
	: not check_obstacle_special(Dir)
<-
	!action::move(Dir);
	!!explore_until_obstacle_special_second(Dir);
	.
	
+!explore_until_obstacle_special_second(Dir)
	: .delete(Dir,[n,s,e,w],DirAux) & remove_opposite(Dir,NewDir) & .delete(NewDir,DirAux,DirList) 
<-
	+opposite(NewDir);
	!!explore(DirList);
	.
