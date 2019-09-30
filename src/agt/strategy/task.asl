evaluate_task([], AgList, CommitListTemp, CommitList) :- CommitList = CommitListTemp.
evaluate_task([req(X,Y,Type)|ReqList], AgList, CommitListTemp, CommitList) :- .member(agent(Ag, Type), AgList) & .delete(agent(Ag, Type), AgList, NewAgList) & evaluate_task(ReqList, NewAgList, [agent(Ag,Type,X,Y)|CommitListTemp], CommitList).
evaluate_task([req(X,Y,Type)|ReqList], AgList, CommitListTemp, CommitList) :- not .member(agent(Ag, Type), AgList) & CommitList = [].

//can_contribute(ReqList,CommitListTemp,ReqListNew) :- default::thing(0,1, block, Type) & .member(req(0,1,Type), ReqList) & .delete(req(0,1,Type),ReqList,ReqListNew) & .my_name(Ag) & CommitListTemp = [agent(Ag,Type,0,1)].
//can_contribute(ReqList,CommitListTemp,ReqListNew) :- default::thing(0,1, block, Type) & .member(req(X,Y,Type), ReqList) & .delete(req(X,Y,Type),ReqList,ReqListNew) & .my_name(Ag) & CommitListTemp = [agent(Ag,Type,X,Y)].
//can_contribute(ReqList,CommitListTemp,ReqList) :- CommitListTemp = [].

sort_committed([], CommitListTemp, CommitListSort) :- CommitListSort = CommitListTemp.
sort_committed([agent(Ag,Type,X,Y)|CommitList], CommitListTemp, CommitListSort) :- X >= 0 & Y >= 0 & sort_committed(CommitList, [agent(X+Y,Ag,Type,X,Y)|CommitListTemp], CommitListSort).
sort_committed([agent(Ag,Type,X,Y)|CommitList], CommitListTemp, CommitListSort) :- X < 0 & Y >= 0 & sort_committed(CommitList, [agent(-X+Y,Ag,Type,X,Y)|CommitListTemp], CommitListSort).
sort_committed([agent(Ag,Type,X,Y)|CommitList], CommitListTemp, CommitListSort) :- X >= 0 & Y < 0 & sort_committed(CommitList, [agent(X-Y,Ag,Type,X,Y)|CommitListTemp], CommitListSort).
sort_committed([agent(Ag,Type,X,Y)|CommitList], CommitListTemp, CommitListSort) :- X < 0 & Y < 0 & sort_committed(CommitList, [agent(-X-Y,Ag,Type,X,Y)|CommitListTemp], CommitListSort).

check_pos(X,Y,NewX,NewY) :- not (default::thing(X, Y-1, Thing, _) & (Thing == entity | Thing == block)) & NewX = X & NewY = Y-1.
check_pos(X,Y,NewX,NewY) :- not (default::thing(X-1, Y, Thing, _) & (Thing == entity | Thing == block)) & NewX = X-1 & NewY = Y.
check_pos(X,Y,NewX,NewY) :- not (default::thing(X, Y+1, Thing, _) & (Thing == entity | Thing == block)) & NewX = X & NewY = Y+1.
check_pos(X,Y,NewX,NewY) :- not (default::thing(X+1, Y, Thing, _) & (Thing == entity | Thing == block)) & NewX = X+1 & NewY = Y.

where_is_my_block(X,Y,DetachPos) :- default::thing(0,1,block,_) & retrieve::block (0,1) & X = 0 & Y = 1 & DetachPos = s.
where_is_my_block(X,Y,DetachPos) :- default::thing(0,-1,block,_) & retrieve::block (0,-1) & X = 0 & Y = -1 & DetachPos = n.
where_is_my_block(X,Y,DetachPos) :- default::thing(1,0,block,_) & retrieve::block (1,0) & X = 1 & Y = 0 & DetachPos = e.
where_is_my_block(X,Y,DetachPos) :- default::thing(-1,0,block,_) & retrieve::block (-1,0) & X = -1 & Y = 0 & DetachPos = w.

get_direction(0,-1,Dir) :- Dir = n.
get_direction(0,1,Dir) :- Dir = s.
get_direction(1,0,Dir) :- Dir = e.
get_direction(-1,0,Dir) :- Dir = w.

get_block_connect(TargetX, TargetY, X, Y) :- default::thing(TargetX-1,TargetY,block,_) & X = TargetX-1 & Y = TargetY.
get_block_connect(TargetX, TargetY, X, Y) :- default::thing(TargetX+1,TargetY,block,_) & X = TargetX+1 & Y = TargetY.
get_block_connect(TargetX, TargetY, X, Y) :- default::thing(TargetX,TargetY-1,block,_) & X = TargetX & Y = TargetY-1.
get_block_connect(TargetX, TargetY, X, Y) :- default::thing(TargetX,TargetY+1,block,_) & X = TargetX & Y = TargetY+1.

@task[atomic]
+default::task(Id, Deadline, Reward, ReqList)
	: task::origin & not task::committed(Id2,_) & .my_name(Me) & ((default::energy(Energy) & Energy < 30) | not default::obstacle(_,_)) & .count(task::stocker(_)[source(_)],2) & helper(HelperAg)
<-
	.print("@@@@@@@@@@@@@@@@@@ ", Id, "  ",Deadline);
//	?can_contribute(ReqList,CommitListTemp,ReqListNew);
//	.print("I can commit to ",CommitListTemp);
//	.print("New req list ",ReqListNew);
	getAvailableBlocks(AgList);
	?evaluate_task(ReqList, AgList, [], CommitList);
	.print("New task required length ",.length(ReqList));
	.print("Committed length ",.length(CommitList));
//	if (.length(ReqList) == .length(CommitList) + .length(CommitListTemp)) {
	if (.length(ReqList) == .length(CommitList)) {
//		if (not .empty(CommitListTemp)) {
//			.concat(CommitList,CommitListTemp,CommitListConcat);
//			?sort_committed(CommitListConcat,[],NewCommitList);
//			if (not .member(agent(Me,Type,0,1),CommitListTemp) & not .empty(CommitListTemp)) {
//				+help;
//			}
//		}
//		else {
		?sort_committed(CommitList,[],NewCommitList);
//		}
		.sort(NewCommitList,CommitListSort);
//		if (task::help) {
//			-help;
//			.print("New commit list sorted ",CommitListSort);
//			.nth(Pos,CommitListSort,agent(Sum,Me,Type,MyX,MyY));
//			+help(MyX,MyY);
//			.nth(Pos-1,CommitListSort,agent(_,Helper,_,_,_));
//			.send(Helper,tell,task::help);
//			.delete(Pos,CommitListSort,CommitListSortDelete);
//			.sort([agent(Sum,Helper,Type,MyX,MyY)|CommitListSortDelete],CommitListSortNew);
//		}
//		else {
//			CommitListSortNew = CommitListSort;
//		}
		+committed(Id,CommitListSort);
		.print("New commit list sorted ",CommitListSort);
		.print("Task ",Id," with deadline ",Deadline," , reward ",Reward," and requirements ",ReqList," is eligible to be performed");
		.print("Agents committed: ",CommitList);
		.print("Agent list used: ",AgList);
//		getMyPos(MyX,MyY);
//		for (.member(agent(Ag,TypeAux,X,Y), CommitList)) {
////			if (Me \== Ag) {
////				if (not task::helper(_) & not .member(agent(Me,Type,0,1),CommitListTemp)) {
////					+helper(Ag);
////				}
////				.send(Ag,achieve,task::perform_task(TypeAux,MyX+X,MyY+Y-1,ReqList));
//				removeAvailableAgent(Ag);
////			}
//		}
//		getAvailableAgent(AgListNew);
//		.print("Remaining agent list: ",AgListNew);
//		if (.member(agent(Me,Type,X,Y), CommitListTemp)) {
//			!!perform_task_origin(X,Y);
//		}
//		else {
		!!perform_task_origin;
//		}
	}
	.
	
@updatecommitlist[atomic]
+!update_commitlist(CommitListSort)
	: committed(Id,CommitListSortOld)
<-
	-committed(Id,CommitListSortOld);
	+committed(Id,CommitListSort);
	.print("New commit list ",CommitListSort);
	.

@next_job_task[atomic]
+!perform_task_origin_next
	: committed(Id,CommitListSort) & not .empty(CommitListSort) & helper(HelperAg)
<-
	.nth(0,CommitListSort,agent(Sum,Ag,TypeAg,X,Y));
	.delete(0,CommitListSort,CommitListSortNew);
	!update_commitlist(CommitListSortNew);
	getMyPos(MyX,MyY);
	?check_pos(X,Y,NewX,NewY);
	if (task::no_block) {
	.send(HelperAg,achieve,task::perform_task(Ag,TypeAg,MyX+NewX,MyY+NewY,MyX+X,MyY+Y,noblock));
	}
	else {
//		if (help(HelpX,HelpY) & HelpX == X & HelpY == Y) {
//			-help(HelpX,HelpY);
//			.send(Ag,achieve,task::collect_block(TypeAg,MyX+NewX,MyY+NewY,MyX+X,MyY+Y,MyX-1,MyY-1));
//			!action::detach(n);
//		}
//		else {
		.send(HelperAg,achieve,task::perform_task(Ag,TypeAg,MyX+NewX,MyY+NewY,MyX+X,MyY+Y));
//		}
	}
	!!default::always_skip;
	.
+!perform_task_origin_next
	: committed(Id,CommitListSort) & helper(HelperAg)
<-
	!action::submit(Id);
	-committed(Id,CommitListSort);
	.send(HelperAg,achieve,default::always_skip);
	!default::always_skip;
	.

//// Update this plan after adding the belief for attached blocks
//+!verify_block
//	: retrieve::block(0,-1) & default::thing(0,-1, block, Type)
//<-
//	!action::rotate(cw);
//	!action::rotate(cw);
//	.
//+!verify_block.	
	
//+!perform_task_origin(0,1)
//	: retrieve::block(0,1) & default::thing(0,1, block, Type) & committed(Id,CommitListSort) & .my_name(Me)
//<-
//	.delete(agent(1,Me,Type,0,1),CommitListSort,CommitListSortNew);
//	.nth(0,CommitListSortNew,agent(Sum,Ag,TypeAg,X,Y));
//	.delete(0,CommitListSortNew,CommitListSortNewNew);
//	!update_commitlist(CommitListSortNewNew);
//	getMyPos(MyX,MyY);
////	+connect(0,1);
//	.send(Ag,achieve,task::perform_task(TypeAg,MyX+X,MyY+Y-1,MyX+X,MyY+Y));
//	.
//+!perform_task_origin
//	: retrieve::block(0,1) & default::thing(0,1, block, Type)
//<-
//	!action::forget_old_action(default,always_skip);
//	!action::rotate(cw);
//	!action::rotate(cw);
//	+no_block;
//	!perform_task_origin_next;
//	.
+!perform_task_origin
	: true
<-
	!action::forget_old_action(default,always_skip);
	+no_block;
	!perform_task_origin_next;
	.
//+!perform_task_origin(X,Y)
//	: retrieve::block(0,1) & default::thing(0,1, block, Type) & help(X,Y)
//<-
//	!action::forget_old_action(default,always_skip);
//	!action::rotate(cw);
//	!action::rotate(cw);
//	+no_block;
//	!perform_task_origin_next;
//	.

+!request_block(Type, Gate)[source(Help)]
	: retrieve::block(X, Y) & default::thing(X, Y, block, Type) & get_direction(X, Y, Gate).
+!request_block(Type, Gate)[source(Help)]
	: retrieve::block(X, Y) & default::thing(X, Y, block, Type) & get_direction(GX, GY, Gate)
<-
	!action::forget_old_action(default,always_skip);
	while (not default::thing(GX, GY, block, Type)) {
		!action::rotate(cw);
	}
	!default::always_skip;
	.

+!help_detach(Gate)[source(Help)]
	: get_direction(GX, GY, Gate) & default::thing(GX, GY, block, Type) & .my_name(Me)
<-
	!action::forget_old_action(default,always_skip);
	!action::detach(Gate);
	if (default::lastAction(detach) & default::lastActionResult(success)) {
		.send(Help, tell, task::detach_complete);
		removeStockerBlock(Me, Type);
	}
	!default::always_skip;
	.

+!help_attach(ConX,ConY)[source(Help)]
	: no_block
<-
	getMyPos(MyX,MyY);
	!action::forget_old_action(default,always_skip);
	?get_direction(ConX-MyX, ConY-MyY, Dir)
	!action::attach(Dir);
	-no_block;
//	+connect(ConX-MyX,ConY-MyY);
	!perform_task_origin_next;
	.
	
+!help_connect(ConX,ConY)[source(Help)]
//	:  connect(X,Y) & retrieve::block(X,Y) & default::thing(X,Y, block, Type)
<-
	getMyPos(MyX,MyY);
	?get_block_connect(ConX-MyX, ConY-MyY, X, Y);
	!action::forget_old_action(default,always_skip);
	while (not (default::lastAction(connect) & default::lastActionResult(success))) {
		!action::connect(Help,X,Y);
	}
//	-connect(X,Y);
//	.print(ConX-MyX);
//	.print(ConY-MyY);
//	+connect(ConX-MyX,ConY-MyY);
	!perform_task_origin_next;
	.
	
+!perform_task(Stocker,Type,X,Y,LocalX,LocalY,noblock)[source(Origin)]
//	: retrieve::block(0,1) & default::thing(0,1, block, Type)
<-
	.print("@@@@ Received order for new task, origin does not have a block");
//	removeRetriever;
//	removeBlock(Type);
	!action::forget_old_action(default,always_skip);
	getStockerPos(Stocker,StockerX,StockerY,GateS);
	.term2string(Gate,GateS);
	?get_direction(GateX,GateY,Gate);
	if (Gate == s) {
		AddPosX = 0;
		AddPosY = 1; 
	}
	elif (Gate == n) {
		AddPosX = 0;
		AddPosY = -1; 
	}
	elif (Gate == w) {
		AddPosX = -1;
		AddPosY = 0; 
	}
	else {
		AddPosX = 1;
		AddPosY = 0; 
	}
	getMyPos(MyX,MyY);
//	addAvailablePos(MyX, MyY);
	.send(Stocker, achieve, task::request_block(Type, Gate));
	!get_to_pos_vert(MyX,MyY,StockerX+GateX+AddPosX,StockerY+GateY+AddPosY,StockerX+GateX,StockerY+GateY);
	.send(Stocker, achieve, task::help_detach(Gate));
	?exploration::remove_opposite(Gate,OppositeGate);
	!action::attach(OppositeGate);
	.wait(task::detach_complete[source(Stocker)]);
	-task::detach_complete[source(Stocker)];
	.print("@@@@@ Detach complete");
	!rotate_back;
	getMyPos(MyXNew,MyYNew);
	!get_to_pos_vert(MyXNew,MyYNew,X,Y,LocalX,LocalY);
	.send(Origin, achieve, task::help_attach(LocalX,LocalY));
	?retrieve::block(BX,BY);
	?get_direction(BX,BY,DetachPos);
	!action::detach(DetachPos);
//	!default::always_skip;
	.
	
+!perform_task(Stocker,Type,X,Y,LocalX,LocalY)[source(Origin)]
//	: retrieve::block(0,1) & default::thing(0,1, block, Type)
<-
//	removeRetriever;
	.print("@@@@ Received order for new task, origin already has a block.");
//	removeBlock(Type);
	!action::forget_old_action(default,always_skip);
	getStockerPos(Stocker,StockerX,StockerY,GateS);
	.term2string(Gate,GateS);
	?get_direction(GateX,GateY,Gate);
	if (Gate == s) {
		AddPosX = 0;
		AddPosY = 1; 
	}
	elif (Gate == n) {
		AddPosX = 0;
		AddPosY = -1; 
	}
	elif (Gate == w) {
		AddPosX = -1;
		AddPosY = 0; 
	}
	else {
		AddPosX = 1;
		AddPosY = 0; 
	}
	getMyPos(MyX,MyY);
//	addAvailablePos(MyX, MyY);
	.send(Stocker, achieve, task::request_block(Type, Gate));
	!get_to_pos_vert(MyX,MyY,StockerX+GateX+AddPosX,StockerY+GateY+AddPosY,StockerX+GateX,StockerY+GateY);
	.send(Stocker, achieve, task::help_detach(Gate));
	?exploration::remove_opposite(Gate,OppositeGate);
	!action::attach(OppositeGate);
	.wait(task::detach_complete[source(Stocker)]);
	-task::detach_complete[source(Stocker)];
	.print("@@@@@ Detach complete");
	!rotate_back;
	getMyPos(MyXNew,MyYNew);
	!get_to_pos_vert(MyXNew,MyYNew,X,Y,LocalX,LocalY);
	getMyPos(MyXNew2,MyYNew2);
	?retrieve::block(BX,BY);
	?get_direction(BX,BY,DetachPos);
	.send(Origin, achieve, task::help_connect(MyXNew2+BX,MyYNew2+BY));
	while (not (default::lastAction(connect) & default::lastActionResult(success))) {
		!action::connect(Origin,BX,BY);
	}
	!action::detach(DetachPos);
//	!default::always_skip;
	.
//	
//+!find_empty_goal_close_to(OriginX, OriginY, Clusters, X, Y) :
//	.member(cluster(_, GoalList), Clusters) & .member(origin(OriginX, OriginY), GoalList)
//<-
//	getMyPos(MyX, MyY);
//	!get_closest_goal(Myx, MyY, GoalList, goal(X, Y), _);
//	.
//
//+!get_closest_goal(MyX, MyY, [], _, 10000000000).
//+!get_closest_goal(MyX, MyY, [origin(X, Y)|Goals], Goal, Distance) : true <- !get_closest_goal(MyX, MyY, Goals, Goal, Distance).
//+!get_closest_goal(MyX, MyY, [goal(X, Y)|Goals], Goal, Distance) :
//	true
//<- 
//	!get_closest_goal(MyX, MyY, Goals, Goal2, Distance2);
//	Distance1 = (math.abs(MyX-X)+math.abs(MyY-Y));
//	if(Distance1 < Distance2){
//		Goal = goal(X, Y);
//		Distance = Distance1;
//	} else{
//		Goal =  Goal2;
//		Distance = Distance2;
//	}
//	.
	
//+!collect_block(Type,X,Y,LocalX,LocalY,CollectX,CollectY)[source(Origin)]
//	: true
//<-
////	.print("@@@@ Received order for new task");
////	!action::forget_old_action(default,always_skip);
//	getMyPos(MyX,MyY);
//	!get_to_pos_horiz(MyX,MyY,CollectX,CollectY,CollectX+1,CollectY);
//	!action::attach(e);
//	!action::rotate(cw);
//	getMyPos(MyXNew,MyYNew);
//	!get_to_pos_vert(MyXNew,MyYNew,X,Y,LocalX,LocalY);
//	getMyPos(MyXNewNew,MyYNewNew);
//	?where_is_my_block(BlockX,BlockY,DetachPos);
//	.send(Origin, achieve, task::help_connect(MyXNewNew+BlockX,MyYNewNew+BlockY));
//	!action::connect(Origin,BlockX,BlockY);
//	!action::detach(DetachPos);
//	-help[source(_)];
////	!retrieve::retrieve_block;
//	-retrieve::retriever;
//	-stop::stop;
//	+exploration::explorer;
//	!!exploration::explore([n,s,e,w]);
//	.
	
+!rotate_back
	: retrieve::block(X,Y) & not retrieve::block(0,1)
<-
	if (retrieve::block(0,-1)) {
		if (not (default::thing(1,0,Thing,_) & (Thing == entity | Thing == block))) {
			!action::rotate(cw);
		}
		else {
			!action::rotate(ccw);
		}
	}
	elif (retrieve::block(1,0)) {
		!action::rotate(cw);
	}
	else {
		!action::rotate(ccw);
	}	
	!rotate_back;
	.
+!rotate_back.

+!get_to_pos_vert(MyX,MyY,MyX,MyY,LocalX,LocalY) : default::thing(LocalX-MyX,LocalY-MyY, block, Type).	
+!get_to_pos_vert(MyX,MyY,MyX,MyY,LocalX,LocalY) 
	: not default::thing(MyX-LocalX,MyY-LocalY, block, Type)
<-
	!action::rotate(ccw);
	!get_to_pos_vert(MyX,MyY,MyX,MyY,LocalX,LocalY);
	.
+!get_to_pos_vert(MyX,MyY,X,MyY,LocalX,LocalY)
	: true
<-	
	!get_to_pos_horiz(MyX,MyY,X,MyY,LocalX,LocalY);
	.
+!get_to_pos_vert(MyX,MyY,X,Y,LocalX,LocalY)
	: true
<-	
	if ( Y - MyY < 0 ) {
		if (not default::thing(0,-1,block,_)) {
			if (default::obstacle(0,-1)) {
				!action::clear(0,-2);
				!action::clear(0,-2);
				!action::clear(0,-2);
			}
			!action::move(n);
			if (default::thing(0,-1,entity,_)) {
				!common::go_around(n);
				!rotate_back;
//				!action::move(s);
			}
		}
//		else {
//			.print("@@@@@@@ Obstacle at south");
//			!action::move(z);
//			// go around
//		}
	}
	else {
		if ( not default::thing(0,2,block,_) ) {
			if (default::obstacle(0,2)) {
				!action::clear(0,3);
				!action::clear(0,3);
				!action::clear(0,3);
			}
			!action::move(s);
			if (default::thing(0,2,entity,_)) {
				!common::go_around(s);
				!rotate_back;
//				!action::move(n);
			}
		}
//		else {
//			.print("@@@@@@@ Obstacle at north");
//			!action::move(z);
//			// go around
//		}
	}
	getMyPos(MyXNew,MyYNew);
	!get_to_pos_horiz(MyXNew,MyYNew,X,Y,LocalX,LocalY);
	.
	
+!get_to_pos_horiz(MyX,MyY,MyX,MyY,LocalX,LocalY) : default::thing(LocalX-MyX,LocalY-MyY, block, Type).
+!get_to_pos_horiz(MyX,MyY,MyX,MyY,LocalX,LocalY) 
	: not default::thing(MyX-LocalX,MyY-LocalY, block, Type)
<-
	!action::rotate(ccw);
	!get_to_pos_horiz(MyX,MyY,MyX,MyY,LocalX,LocalY);
	.
+!get_to_pos_horiz(MyX,MyY,MyX,Y,LocalX,LocalY)
	: true
<-	
	!get_to_pos_vert(MyX,MyY,MyX,Y,LocalX,LocalY);
	.
+!get_to_pos_horiz(MyX,MyY,X,Y,LocalX,LocalY)
	: true
<-	
	if ( X - MyX > 0  ) {
		if (not default::thing(1,0,block,_)) {
			if (default::obstacle(1,0)) {
				!action::clear(2,0);
				!action::clear(2,0);
				!action::clear(2,0);
			}
			!action::move(e);
			if (default::thing(1,0,entity,_)) {
				!common::go_around(e);
				!rotate_back;
//				!action::move(e);
			}
		}
//		else {
//			.print("@@@@@@@ Obstacle at east");
//			!action::move(z);
//			// go around
//		}
	}
	else {
		if ( not default::thing(-1,0,block,_) ) {
			if (default::obstacle(-1,0)) {
				!action::clear(-2,0);
				!action::clear(-2,0);
				!action::clear(-2,0);
			}
			!action::move(w);
			if (default::thing(-1,0,entity,_)) {
				!common::go_around(w);
				!rotate_back;
//				!action::move(w);
			}
		}
//		else {
//			.print("@@@@@@@ Obstacle at west");
//			!action::move(z);
//			// go around
//		}
	}
	getMyPos(MyXNew,MyYNew);
	!get_to_pos_vert(MyXNew,MyYNew,X,Y,LocalX,LocalY);
	.

