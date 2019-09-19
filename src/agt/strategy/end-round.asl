+!end_round
	: .my_name(Me) & default::score(Score)
<-
	.print("---------------- END OF THE ROUND ----------------");
	.print("££££££££££££££££ ",Score," ££££££££££££££££");
	.print("---------------- END OF THE ROUND ----------------");
	.abolish(org::_[source(_)]);
	.abolish(action::_[source(_)]);
	.abolish(exploration::_[source(_)]);
	.abolish(identification::_[source(_)]);
	.abolish(task::_[source(_)]);
	.abolish(stop::_[source(_)]);
	.abolish(retrieve::_[source(_)]);
	.abolish(map::_[source(_)]);
	.abolish(common::_[source(_)]);
	.abolish(newround::_[source(_)]);
	.abolish(endround::_[source(_)]);
	.abolish(team::chosenActions(_, _)[source(_)]);
	resetMyPos;
	-default::start;
    .drop_all_intentions;
    .drop_all_desires;
    .drop_all_events;
	.
+!end_round
	: .my_name(Me)
<-
	.print("---------------- END OF THE ROUND ----------------");
	.abolish(org::_[source(_)]);
	.abolish(action::_[source(_)]);
	.abolish(exploration::_[source(_)]);
	.abolish(identification::_[source(_)]);
	.abolish(task::_[source(_)]);
	.abolish(stop::_[source(_)]);
	.abolish(retrieve::_[source(_)]);
	.abolish(map::_[source(_)]);
	.abolish(common::_[source(_)]);
	.abolish(newround::_[source(_)]);
	.abolish(endround::_[source(_)]);
	.abolish(team::chosenActions(_, _)[source(_)]);
	resetMyPos;
	-default::start;
    .drop_all_intentions;
    .drop_all_desires;
    .drop_all_events;
	.
	
+!change_round
	: .my_name(Me)
<-
	if (Me == agent1) { 
		clearTeam; 
		.broadcast(tell, endround::wait_change_round);		
	}
	else {
		.wait(endround::wait_change_round[source(_)]);
	}
	!end_round;
	!newround::new_round;
	.
	
@change[atomic]
+default::simEnd 
<- 
	!change_round;
	.