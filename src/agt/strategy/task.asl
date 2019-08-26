evaluate_task([], AgList, CommitListTemp, CommitList) :- CommitList = CommitListTemp.
evaluate_task([req(X,Y,Type)|ReqList], AgList, CommitListTemp, CommitList) :- .member(agent(Ag, Type), AgList) & .delete(agent(Ag, Type), AgList, NewAgList) & evaluate_task(ReqList, NewAgList, [agent(Ag,Type,X,Y)|CommitListTemp], CommitList).
evaluate_task([req(X,Y,Type)|ReqList], AgList, CommitListTemp, CommitList) :- not .member(agent(Ag, Type), AgList) & CommitList = [].

//// this it to simulate when an agent arrives in distance 2 of the target goal position
//+default::step(1)
//	: default::goal(0,0) & .my_name(Me) & default::attached(0,1) & default::thing(0,1, block, Type)
//<-
//	+task::origin;
//	addAvailableAgent(Me,Type);
//	.
//+default::step(1)
//	: .my_name(Me) & default::attached(0,1) & default::thing(0,1, block, Type)
//<-
//	addAvailableAgent(Me,Type);
//	.

@task[atomic]
+default::task(Id, Deadline, Reward, ReqList)
	: task::origin & not task::committed(Id2) & default::attached(0,1) & default::thing(0,1, block, Type)
<-
	.print("@@@@@@@@@@@@@@@@@@ ", Id, "  ",Deadline);
	getAvailableAgent(AgList);
	?task::evaluate_task(ReqList, AgList, [], CommitList);
	.print("New task required length ",.length(ReqList));
	.print("Committed length ",.length(CommitList));
	if (.length(ReqList) == .length(CommitList)) {
		+committed(Id);
		.print("Task ",Id," with deadline ",Deadline," , reward ",Reward," and requirements ",ReqList," is eligible to be performed");
		.print("Agents committed: ",CommitList);
		.print("Agent list used: ",AgList);
		for (.member(agent(Ag,Type,X,Y), CommitList)) {
			removeAvailableAgent(Ag);
		}
		getAvailableAgent(AgListNew);
		.print("Remaining agent list: ",AgListNew);
	}
	.