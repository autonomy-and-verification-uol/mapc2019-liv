/* Initial beliefs and rules */


// trigger for new task addition 
@trigger1[atomic]
+default::task(ID, Deadline, Reward, Blocks) : 
	not(stop::stop)
 <- 
 	!map::get_dispensers(Dispensers);
	!stop::update_blocks_count(Blocks);
	!map::get_goal(GoalList);
	.length(GoalList, NGoals);
	!stop::conditional_stop(Blocks, NGoals, Dispensers, Stop);
	!stop::update_stop(Stop).
@trigger2[atomic]
+default::task(ID, Deadline, Reward, Blocks) : 
	stop::stop <- true.
	
+!stop::update_stop(true) : true <- +stop::stop.
+!stop::update_stop(false) : true <- true.

+!stop::update_blocks_count([]) : true <- true.
+!stop::update_blocks_count([req(_, _, Type)|Blocks]) : 
	retrieve::block_count(Type, Count) 
<-
	-retrieve::block_count(Type, _);
	Count1 = Count + 1;
	+retrieve::block_count(Type, Count1);
	!stop::update_blocks_count(Blocks).
+!stop::update_blocks_count([req(_, _, Type)|Blocks]) : true <-
	+retrieve::block_count(Type, 1);
	!stop::update_blocks_count(Blocks).
	
+!stop::conditional_stop(Blocks, NGoals, Dispensers, true) : 
	NGoals >= 1 &  // at least one goal position known
	.length(Blocks, NBlocks) & 
	identification::identified(KnownAgs) & .length(KnownAgs, NKnownAgs) & (NKnownAgs + 1) >= NBlocks & // enough agents to build the structure
	.findall(Type, (.member(req(_, _, Type), Blocks) & not(.member(dispenser(Type, _, _), Dispensers))), []) // all the necessary types are known
<- 
	.print("I can stop exploring now..").
+!stop::conditional_stop(Blocks, NGoals, Dispensers, false) : 
	true
<- 
	.print("I cannot stop exploring yet..").

+!stop::new_dispenser_trigger(Type, Dispensers) : 
	.member(dispenser(Type, X1, Y1), Dispensers) &
	.member(dispenser(Type, X2, Y2), Dispensers) &
	(X1 \== X2 | Y1 \== Y2)
<-
	true.
+!stop::new_dispenser_trigger(Type, Dispensers) : 
	.findall(task(ID, Deadline, Reward, Blocks), default::task(ID, Deadline, Reward, Blocks), Tasks) 
<-
	!stop::check_active_tasks(Tasks, Dispensers).

@trigger3[atomic]
+!stop::check_active_tasks([], Dispensers) : not(stop::stop) <- .print("I cannot stop exploring yet..").
@trigger4[atomic]
+!stop::check_active_tasks([], Dispensers) : stop::stop <- .print("I can stop exploring now..").
@trigger5[atomic]
+!stop::check_active_tasks([task(ID, Deadline, Reward, Blocks)|Tasks], Dispensers) :
	not(stop::stop) 
<-
	!map::get_goal(GoalList);
	.length(GoalList, NGoals);
	!stop::conditional_stop(Blocks, NGoals, Dispensers, Stop);
	!stop::update_stop(Stop);
	!stop::check_active_tasks(Tasks, Dispensers).
@trigger6[atomic]
+!stop::check_active_tasks([task(ID, Deadline, Reward, Blocks)|Tasks], Dispensers) : stop::stop <- .print("I can stop exploring now..").



