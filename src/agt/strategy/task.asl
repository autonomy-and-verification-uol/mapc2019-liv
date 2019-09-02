evaluate_task([], AgList, CommitListTemp, CommitList) :- CommitList = CommitListTemp.
evaluate_task([req(X,Y,Type)|ReqList], AgList, CommitListTemp, CommitList) :- .member(agent(Ag, Type), AgList) & .delete(agent(Ag, Type), AgList, NewAgList) & evaluate_task(ReqList, NewAgList, [agent(Ag,Type,X,Y)|CommitListTemp], CommitList).
evaluate_task([req(X,Y,Type)|ReqList], AgList, CommitListTemp, CommitList) :- not .member(agent(Ag, Type), AgList) & CommitList = [].

can_contribute(ReqList,CommitListTemp,ReqListNew) :- default::thing(0,1, block, Type) & .member(req(0,1,Type), ReqList) & .delete(req(0,1,Type),ReqList,ReqListNew) & .my_name(Ag) & CommitListTemp = [agent(Ag,Type,0,1)].
can_contribute(ReqList,CommitListTemp,ReqListNew) :- default::thing(0,1, block, Type) & .member(req(X,Y,Type), ReqList) & .delete(req(X,Y,Type),ReqList,ReqListNew) & .my_name(Ag) & CommitListTemp = [agent(Ag,Type,X,Y)].
can_contribute(ReqList,CommitListTemp,ReqList) :- CommitListTemp = [].

sort_committed([], CommitListTemp, CommitListSort) :- CommitListSort = CommitListTemp.
sort_committed([agent(Ag,Type,X,Y)|CommitList], CommitListTemp, CommitListSort) :- X >= 0 & Y >= 0 & sort_committed(CommitList, [agent(X+Y,Ag,Type,X,Y)|CommitListTemp], CommitListSort).
sort_committed([agent(Ag,Type,X,Y)|CommitList], CommitListTemp, CommitListSort) :- X < 0 & Y >= 0 & sort_committed(CommitList, [agent(-X+Y,Ag,Type,X,Y)|CommitListTemp], CommitListSort).
sort_committed([agent(Ag,Type,X,Y)|CommitList], CommitListTemp, CommitListSort) :- X >= 0 & Y < 0 & sort_committed(CommitList, [agent(X-Y,Ag,Type,X,Y)|CommitListTemp], CommitListSort).
sort_committed([agent(Ag,Type,X,Y)|CommitList], CommitListTemp, CommitListSort) :- X < 0 & Y < 0 & sort_committed(CommitList, [agent(-X-Y,Ag,Type,X,Y)|CommitListTemp], CommitListSort).

check_pos(X,Y,NewX,NewY) :- not default::thing(X, Y-1, block, Type) & NewX = X & NewY = Y-1.
check_pos(X,Y,NewX,NewY) :- not default::thing(X-1, Y, block, Type) & NewX = X-1 & NewY = Y.
check_pos(X,Y,NewX,NewY) :- not default::thing(X, Y+1, block, Type) & NewX = X & NewY = Y+1.
check_pos(X,Y,NewX,NewY) :- not default::thing(X+1, Y, block, Type) & NewX = X+1 & NewY = Y.

where_is_my_block(X,Y,DetachPos) :- default::thing(0,1,block,_) & default::attached (0,1) & X = 0 & Y = 1 & DetachPos = s.
where_is_my_block(X,Y,DetachPos) :- default::thing(0,-1,block,_) & default::attached (0,-1) & X = 0 & Y = -1 & DetachPos = n.
where_is_my_block(X,Y,DetachPos) :- default::thing(1,0,block,_) & default::attached (1,0) & X = 1 & Y = 0 & DetachPos = e.
where_is_my_block(X,Y,DetachPos) :- default::thing(-1,0,block,_) & default::attached (-1,0) & X = -1 & Y = 0 & DetachPos = w.

// this it to simulate when an agent arrives in distance 2 of the target goal position
+default::step(0)
	: default::goal(0,0) & default::attached(0,1) & default::thing(0,1, block, Type) & .my_name(agent4)
<-
	+origin;
	.
+default::step(0)
	: default::attached(0,1) & default::thing(0,1, block, Type) & .my_name(Me)
<-
	addAvailableAgent(Me,Type);
	.

@task[atomic]
+default::task(Id, Deadline, Reward, ReqList)
	: task::origin & not task::committed(Id2,_) & default::attached(0,1) & default::thing(0,1, block, Type) & .my_name(Me)
<-
	.print("@@@@@@@@@@@@@@@@@@ ", Id, "  ",Deadline);
	?can_contribute(ReqList,CommitListTemp,ReqListNew);
	.print("I can commit to ",CommitListTemp);
	.print("New req list ",ReqListNew);
	getAvailableAgent(AgList);
	?evaluate_task(ReqListNew, AgList, CommitListTemp, CommitList);
	.print("New task required length ",.length(ReqList));
	.print("Committed length ",.length(CommitList));
	if (.length(ReqList) == .length(CommitList)) {
		?sort_committed(CommitList,[],NewCommitList);
		.sort(NewCommitList,CommitListSort);
		+committed(Id,CommitListSort);
		.print("New commit list sorted ",CommitListSort);
		.print("Task ",Id," with deadline ",Deadline," , reward ",Reward," and requirements ",ReqList," is eligible to be performed");
		.print("Agents committed: ",CommitList);
		.print("Agent list used: ",AgList);
//		getMyPos(MyX,MyY);
		for (.member(agent(Ag,TypeAux,X,Y), CommitList)) {
			if (Me \== Ag) {
				if (not task::helper(_) & not .empty(ReqListNew)) {
					+helper(Ag);
				}
//				.send(Ag,achieve,task::perform_task(TypeAux,MyX+X,MyY+Y-1,ReqList));
				removeAvailableAgent(Ag);
			}
		}
		getAvailableAgent(AgListNew);
		.print("Remaining agent list: ",AgListNew);
		if (.member(agent(Me,Type,X,Y), CommitList)) {
			!!perform_task_origin(X,Y);
		}
		else {
			!!perform_task_origin;
		}
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
	
+!perform_task_origin_next
	: committed(Id,CommitListSort) & not .empty(CommitListSort)
<-
	.nth(0,CommitListSort,agent(Sum,Ag,TypeAg,X,Y));
	.delete(0,CommitListSort,CommitListSortNew);
	!update_commitlist(CommitListSortNew);
	getMyPos(MyX,MyY);
	?check_pos(X,Y,NewX,NewY);
	.send(Ag,achieve,task::perform_task(TypeAg,MyX+NewX,MyY+NewY,MyX+X,MyY+Y));
	!default::always_skip;
	.
+!perform_task_origin_next
	: committed(Id,CommitListSort)
<-
	!action::submit(Id);
	!default::always_skip;
	.
	
+!perform_task_origin(0,1)
	: default::attached(0,1) & default::thing(0,1, block, Type) & committed(Id,CommitListSort) & .my_name(Me)
<-
	.delete(agent(1,Me,Type,0,1),CommitListSort,CommitListSortNew);
	.nth(0,CommitListSortNew,agent(Sum,Ag,TypeAg,X,Y));
	.delete(0,CommitListSortNew,CommitListSortNewNew);
	!update_commitlist(CommitListSortNewNew);
	getMyPos(MyX,MyY);
	+connect(0,1);
	.send(Ag,achieve,task::perform_task(TypeAg,MyX+X,MyY+Y-1,MyX+X,MyY+Y));
	.
+!perform_task_origin
	: default::attached(0,1) & default::thing(0,1, block, Type)
<-
	!action::forget_old_action(default,always_skip);
	!action::rotate(cw);
	!action::rotate(cw);
	!default::always_skip;
	.
+!perform_task_origin(X,Y)
	: default::attached(0,1) & default::thing(0,1, block, Type) & helper(Ag)
<-
	!action::forget_old_action(default,always_skip);
	getMyPos(MyX,MyY);
	.send(Ag, tell, task::help_requested(MyX+X,MyY+Y));
	!action::rotate(cw);
	!action::rotate(cw);
	!default::always_skip;
	.
	
+!help_connect(ConX,ConY)[source(Help)]
	: connect(X,Y) & default::attached(X,Y) & default::thing(X,Y, block, Type)
<-
	!action::forget_old_action(default,always_skip);
	!action::connect(Help,X,Y);
	-connect(X,Y);
	getMyPos(MyX,MyY);
	.print(ConX-MyX);
	.print(ConY-MyY);
	+connect(ConX-MyX,ConY-MyY);
	!perform_task_origin_next;
	.
	
+!perform_task(Type,X,Y,LocalX,LocalY)[source(Origin)]
	: default::attached(0,1) & default::thing(0,1, block, Type)
<-
//	.print("@@@@ Received order for new task");
	!action::forget_old_action(default,always_skip);
	getMyPos(MyX,MyY);
	!get_to_pos_vert(MyX,MyY,X,Y,LocalX,LocalY);
	getMyPos(MyXNew,MyYNew);
	?where_is_my_block(BlockX,BlockY,DetachPos);
	.send(Origin, achieve, task::help_connect(MyXNew+BlockX,MyYNew+BlockY));
	!action::connect(Origin,BlockX,BlockY);
	!action::detach(DetachPos);
	!default::always_move_north;
	.

+!get_to_pos_vert(MyX,MyY,MyX,MyY,LocalX,LocalY) : .print(MyX)  & .print(LocalX) & .print(MyX-LocalX) & .print(MyY) & .print(LocalY) & .print(MyY-LocalY) & default::thing(LocalX-MyX,LocalY-MyY, block, Type).	
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
	if ( Y - MyY > 0 ) {
		if (not default::thing(0,-1,block,_)) {
			!action::move(s);
		}
		else {
			// go around
		}
	}
	else {
		if ( not default::thing(0,2,block,_) ) {
			!action::move(n);
		}
		else {
			// go around
		}
	}
	getMyPos(MyXNew,MyYNew);
	!get_to_pos_horiz(MyXNew,MyYNew,X,Y,LocalX,LocalY);
	.
	
+!get_to_pos_horiz(MyX,MyY,MyX,MyY,LocalX,LocalY) : .print(MyX)  & .print(LocalX) & .print(MyX-LocalX) & .print(MyY) & .print(LocalY) & .print(MyY-LocalY) & default::thing(LocalX-MyX,LocalY-MyY, block, Type).
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
			!action::move(e);
		}
		else {
			!action::move(n);
			!action::rotate(ccw);
		}
	}
	else {
		if ( not default::thing(-1,0,block,_) ) {
			!action::move(w);
		}
		else {
			// go around
		}
	}
	getMyPos(MyXNew,MyYNew);
	!get_to_pos_vert(MyXNew,MyYNew,X,Y,LocalX,LocalY);
	.
	