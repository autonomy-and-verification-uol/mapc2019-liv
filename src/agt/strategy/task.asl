evaluate_task([], AgList, CommitListTemp, CommitList) :- CommitList = CommitListTemp.
evaluate_task([req(X,Y,Type)|ReqList], AgList, CommitListTemp, CommitList) :- .member(agent(Ag, Type), AgList) & .delete(agent(Ag, Type), AgList, NewAgList) & evaluate_task(ReqList, NewAgList, [agent(Ag,Type,X,Y)|CommitListTemp], CommitList).
evaluate_task([req(X,Y,Type)|ReqList], AgList, CommitListTemp, CommitList) :- not .member(agent(Ag, Type), AgList) & CommitList = [].

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

get_block_connect(TargetX, TargetY, X, Y) :- retrieve::block(TargetX-1,TargetY) & X = TargetX-1 & Y = TargetY.
get_block_connect(TargetX, TargetY, X, Y) :- retrieve::block(TargetX+1,TargetY) & X = TargetX+1 & Y = TargetY.
get_block_connect(TargetX, TargetY, X, Y) :- retrieve::block(TargetX,TargetY-1) & X = TargetX & Y = TargetY-1.
get_block_connect(TargetX, TargetY, X, Y) :- retrieve::block(TargetX,TargetY+1) & X = TargetX & Y = TargetY+1.

@task[atomic]
+default::task(Id, Deadline, Reward, ReqList)
	: task::origin & not task::committed(Id2,_) & .my_name(Me) & ((default::energy(Energy) & Energy < 30) | not default::obstacle(_,_)) & .length(ReqList) <= 6 //& .count(task::stocker(_)[source(_)],2) & helper(HelperAg)
<-
	.print("@@@@@@@@@@@@@@@@@@ ", Id, "  ",Deadline);
	getAvailableAgent(AgList);
	?evaluate_task(ReqList, AgList, [], CommitList);
	.print("New task required length ",.length(ReqList));
	.print("Committed length ",.length(CommitList));
	if (.length(ReqList) == .length(CommitList)) {
		?sort_committed(CommitList,[],NewCommitList);
		.sort(NewCommitList,CommitListSort);
		+committed(Id,CommitListSort);
		.print("New commit list sorted ",CommitListSort);
		.length(CommitListSort,AgentsRequired);
		+ready_submit(AgentsRequired);
		+batch(0);
		.print("Task ",Id," with deadline ",Deadline," , reward ",Reward," and requirements ",ReqList," is eligible to be performed");
		.print("Agents committed: ",CommitList);
		.print("Agent list used: ",AgList);
		!!perform_task_origin;
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

@update_beliefs_submit[atomic]
+!update_beliefs_submit
	: committed(Id,CommitListSort)
<-
	.print("Submitted task ",Id);
	-ready_submit(0);
	-batch(_);
	if (default::lastAction(submit) & not default::lastActionResult(success)) {
		.print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ TASK FAILED")
	}
	.abolish(retrieve::block(_,_));
	+task::no_block;
	-committed(Id,CommitListSort);
	.

+!perform_task_origin_next
	: committed(Id,CommitListSort) & ready_submit(0)
<-
	!action::submit(Id);
	!update_beliefs_submit;
	!default::always_skip;
	.

@next_job_task[atomic]
+!perform_task_origin_next
	: committed(Id,CommitListSort) & not .empty(CommitListSort) & batch(0) //& helper(HelperAg)
<-
//	.wait(not action::move_sent);
	getMyPos(MyX,MyY);
	.nth(0,CommitListSort,agent(Sum,_,_,_,_));
	for (.member(agent(Sum,Ag,TypeAg,X,Y),CommitListSort)) {
		if (task::no_block) {
			.send(Ag,achieve,task::perform_task(MyX+X,MyY+Y,noblock));
		}
		else {
			.send(Ag,achieve,task::perform_task(MyX+X,MyY+Y));
		}
		?batch(Batch);
		-+batch(Batch+1);
		?committed(Id,CommitListSortAux);
		.delete(agent(Sum,Ag,TypeAg,X,Y),CommitListSortAux,CommitListSortNew);
		!update_commitlist(CommitListSortNew);
	}
	!!default::always_skip;
	.
	
+!perform_task_origin_next <- !!default::always_skip.

+!perform_task_origin
	: true
<-
	!action::forget_old_action(default,always_skip);
	+no_block;
	!perform_task_origin_next;
	.
	
@updatetaskbeliefsattach[atomic]
+!update_task_beliefs_attach
	: batch(Batch) & ready_submit(AgentsRequired)
<-
	-+ready_submit(AgentsRequired-1);
	-+batch(Batch-1);
	-no_block;
	.
	
@updatetaskbeliefsconnect[atomic]
+!update_task_beliefs_connect(X,Y)
	: batch(Batch) & ready_submit(AgentsRequired)
<-
	-+ready_submit(AgentsRequired-1);
	-+batch(Batch-1);
	-helping_connect;
	+retrieve::block(X,Y);
	.

+!help_attach(ConX,ConY)[source(Help)]
	: no_block
<-
//	.wait(not action::move_sent);
	getMyPos(MyX,MyY);
	!action::forget_old_action(default,always_skip);
	?get_direction(ConX-MyX, ConY-MyY, Dir)
	while (not (default::lastAction(attach) & default::lastActionResult(success))) {
		!action::attach(Dir);
	}
	.send(Help, tell, task::synch_complete);
	!update_task_beliefs_attach;
	!perform_task_origin_next;
	.
	
+!help_connect(ConX,ConY)[source(Help)]
	:  not helping_connect
<-
	+helping_connect;
//	.wait(not action::move_sent);
	getMyPos(MyX,MyY);
	.print("My pos X ",MyX," Y ",MyY);
	.print("Help local block X ",ConX-MyX," Y ",ConY-MyY);
	?get_block_connect(ConX-MyX, ConY-MyY, X, Y);
	!action::forget_old_action(default,always_skip);
	!action::connect(Help,X,Y);
	while (not (default::lastAction(connect) & default::lastActionResult(success))) {
		!action::connect(Help,X,Y);
	}
	.send(Help, tell, task::synch_complete);
	!update_task_beliefs_connect(ConX-MyX,ConY-MyY);
	!perform_task_origin_next;
	.
	
+!help_connect(ConX,ConY)[source(Help)] <- .wait({+default::actionID(_)}); !help_connect(ConX,ConY)[source(Help)].
	
+!perform_task(X,Y,noblock)[source(Origin)]
	: .my_name(Me) & retrieve::block(BBX, BBY) & default::thing(BBX, BBY, block, Type)
<-
	!action::forget_old_action(default,always_skip);
	.print("@@@@ Received order for new task, origin does not have a block");
	removeAvailableAgent(Me);
	removeBlock(Type);
	getMyPos(MyX,MyY);
	addRetrieverAvailablePos(MyX,MyY);
//	.print("MyXNew ",MyXNew);
//	.print("MyYNew ",MyYNew);
//	.print("X ",X);
//	.print("Y ",Y);
	NewTargetX = X - MyX;
	NewTargetY = Y - MyY;
//	.print("NewTargetX ",NewTargetX);
//	.print("NewTargetY ",NewTargetY);
	!planner::generate_goal(NewTargetX, NewTargetY, notblock);
	getMyPos(MyXNew,MyYNew);
	?retrieve::block(BX,BY);
	.send(Origin, achieve, task::help_attach(MyXNew+BX,MyYNew+BY));
	?get_direction(BX,BY,DetachPos);
	!action::detach(DetachPos);
	.wait(task::synch_complete[source(Origin)]);
	-task::synch_complete[source(Origin)];
	!!retrieve::retrieve_block;
	.
	
+!perform_task(X,Y)[source(Origin)]
	: .my_name(Me) & retrieve::block(BBX, BBY) & default::thing(BBX, BBY, block, Type)
<-
	!action::forget_old_action(default,always_skip);
	.print("@@@@ Received order for new task, origin does not have a block");
	removeAvailableAgent(Me);
	removeBlock(Type);
	getMyPos(MyX,MyY);
	addRetrieverAvailablePos(MyX,MyY);
//	.print("MyXNew ",MyXNew);
//	.print("MyYNew ",MyYNew);
//	.print("X ",X);
//	.print("Y ",Y);
	NewTargetX = X - MyX;
	NewTargetY = Y - MyY;
//	.print("NewTargetX ",NewTargetX);
//	.print("NewTargetY ",NewTargetY);
	!planner::generate_goal(NewTargetX, NewTargetY, notblock);
	getMyPos(MyXNew,MyYNew);
	?retrieve::block(BX,BY);
	.send(Origin, achieve, task::help_connect(MyXNew+BX,MyYNew+BY));
	while (not (default::lastAction(connect) & default::lastActionResult(success))) {
		!action::connect(Origin,BX,BY);
	}
	.wait(task::synch_complete[source(Origin)]);
	-task::synch_complete[source(Origin)];
	?get_direction(BX,BY,DetachPos);
	!action::detach(DetachPos);
	!!retrieve::retrieve_block;
	.
