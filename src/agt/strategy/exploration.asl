check_obstacle(n) :- default::obstacle(0,-1) | default::obstacle(0,-2) | default::obstacle(0,-3) | default::obstacle(0,-4) | default::obstacle(0,-5).
check_obstacle(s) :- default::obstacle(0,1) | default::obstacle(0,2) | default::obstacle(0,3) | default::obstacle(0,4) | default::obstacle(0,5).
check_obstacle(e) :- default::obstacle(1,0) | default::obstacle(2,0) | default::obstacle(3,0) | default::obstacle(4,0) | default::obstacle(5,0).
check_obstacle(w) :- default::obstacle(-1,0) | default::obstacle(-2,0) | default::obstacle(-3,0) | default::obstacle(-4,0) | default::obstacle(-5,0).

prune_direction([],PrunedDirListTemp,PrunedDirList) :- PrunedDirList = PrunedDirListTemp.
prune_direction([Dir|L],PrunedDirListTemp,PrunedDirList) :- check_obstacle(Dir) & prune_direction(L,PrunedDirListTemp,PrunedDirList).
prune_direction([Dir|L],PrunedDirListTemp,PrunedDirList) :- not check_obstacle(Dir) & prune_direction(L,[Dir|PrunedDirListTemp],PrunedDirList).

random_dir(PrunedDirList,4,Number,Dir) :- (Number <= 0.25 & .nth(0,PrunedDirList,Dir)) | (Number <= 0.5 & .nth(1,PrunedDirList,Dir)) | (Number <= 0.75 & .nth(2,PrunedDirList,Dir)) | (.nth(3,PrunedDirList,Dir)).
random_dir(PrunedDirList,3,Number,Dir) :- (Number <= 0.33 & .nth(0,PrunedDirList,Dir)) | (Number <= 0.66 & .nth(1,PrunedDirList,Dir)) | (.nth(2,PrunedDirList,Dir)).
random_dir(PrunedDirList,2,Number,Dir) :- (Number <= 0.5 & .nth(0,PrunedDirList,Dir)) | (.nth(1,PrunedDirList,Dir)).
random_dir([Dir|T],1,Number,Dir).

+!explore(DirList) 
	: prune_direction(DirList,[],PrunedDirList) & not .empty(PrunedDirList) & .length(PrunedDirList,Length) & .random(Number) & .print(Number," random number") & .print(PrunedDirList, " pruned list") & .print(Length," list length") & random_dir(PrunedDirList,Length,Number,Dir)
<-
	 !explore_until_obstacle(Dir);
	 .
// TODO add plan for when there are obstacles in all four directions
// TODO if I see an agent I should stop this plan
// TODO remember the previous direction and exclude it from the list?
	 
+!explore_until_obstacle(Dir)
	: not check_obstacle(Dir)
<-
	!action::move(Dir);
	!!explore_until_obstacle(Dir);
	.
	
+!explore_until_obstacle(Dir)
	: .delete(Dir,[n,s,e,w],DirList) 
<-
	!explore(DirList);
	.
