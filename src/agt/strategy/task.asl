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
	
+!perform_task_origin(0,1)
	: default::attached(0,1) & default::thing(0,1, block, Type) & committed(Id,CommitListSort) & .my_name(Me)
<-
	.delete(agent(1,Me,Type,0,1),CommitListSort,CommitListSortNew);
	.nth(0,CommitListSortNew,agent(Sum,Ag,TypeAg,X,Y));
	.delete(0,CommitListSortNew,CommitListSortNewNew);
	!update_commitlist(CommitListSortNewNew);
	getMyPos(MyX,MyY);
	+connect(0,1);
	.send(Ag,achieve,task::perform_task(TypeAg,MyX+X,MyY+Y-1));
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
	!default::always_skip;
	.
	
+!perform_task(Type,X,Y)[source(Origin)]
	: default::attached(0,1) & default::thing(0,1, block, Type)
<-
//	.print("@@@@ Received order for new task");
	!action::forget_old_action(default,always_skip);
	getMyPos(MyX,MyY);
	!get_to_pos_vert(MyX,MyY,X,Y);
	getMyPos(MyXNew,MyYNew);
	.send(Origin, achieve, task::help_connect(MyXNew+0,MyYNew+1));
	!action::connect(Origin,0,1);
	!action::detach(s);
	!default::always_move_north;
	.
	
+!get_to_pos_vert(MyX,MyY,MyX,MyY).
+!get_to_pos_vert(MyX,MyY,X,MyY)
	: true
<-	
	!get_to_pos_horiz(MyX,MyY,X,MyY);
	.
+!get_to_pos_vert(MyX,MyY,X,Y)
	: true
<-	
	if ( Y - MyY > 0 ) {
		!action::move(s);
	}
	else {
		!action::move(n);
	}
	getMyPos(MyXNew,MyYNew);
	!get_to_pos_horiz(MyXNew,MyYNew,X,Y);
	.
	
+!get_to_pos_horiz(MyX,MyY,MyX,MyY).
+!get_to_pos_horiz(MyX,MyY,MyX,Y)
	: true
<-	
	!get_to_pos_vert(MyX,MyY,MyX,Y);
	.
+!get_to_pos_horiz(MyX,MyY,X,Y)
	: true
<-	
	if ( X - MyX > 0 ) {
		!action::move(e);
	}
	else {
		!action::move(w);
	}
	getMyPos(MyXNew,MyYNew);
	!get_to_pos_vert(MyXNew,MyYNew,X,Y);
	.
	