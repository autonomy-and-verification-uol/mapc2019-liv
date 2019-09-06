/* Initial beliefs and rules */
identify(WhatItSees, WhoX, WhoY) :-
	.findall(Name,
	(
		.member(see(X, Y, Kind, Name), WhatItSees) &
		X1 = WhoX + X & Y1 = WhoY + Y &
		(math.abs(X1) + math.abs(Y1)) <= 5 & 
		not(default::thing(X1, Y1, Kind, Name))
	), L) & L = [] &
	.findall(Name,
	(
		default::thing(X, Y, Kind, Name) &
		X1 = X - WhoX & Y1 = Y - WhoY &
		(math.abs(X1) + math.abs(Y1)) <= 5 & 
		not(.member(see(X1, Y1, Kind, Name), WhatItSees))
	), L1) & L1 = [].
	
i_see_it(EverythingSeen, MyViewX, MyViewY) :-
	default::team(Team) &
 	.member(see(X, Y, entity, Team), EverythingSeen) & not(X = 0 & Y = 0) &
 	MyViewX = -X &
 	MyViewY = -Y &
 	default::thing(MyViewX, MyViewY, entity, Team).
only_one_on_sight([agent_sees(Agent, EverythingSeen)]) :-
	i_see_it(EverythingSeen, _, _).
only_one_on_sight([agent_sees(Agent, EverythingSeen)|L]) :-
	i_see_it(EverythingSeen, _, _) &
	no_more_on_sight(L).
only_one_on_sight([agent_sees(Agent, EverythingSeen)|L]) :-
	not(i_see_it(EverythingSeen, _, _)) &
	only_one_on_sight(L).
no_more_on_sight([]) :- true.
no_more_on_sight([agent_sees(Agent, EverythingSeen)|L]) :-
	not(i_see_it(EverythingSeen, _, _)) &
	no_more_on_sight(L).
	
i_met_new_agent(Iknow, IdList) :-
	.member(Ag, Iknow) & not .member(Ag, IdList).


@thing[atomic]
+default::thing(X, Y, entity, Team)
	: not(X == 0 & Y == 0) & default::team(Team) & not(action::reasoning_about_belief(identification)) & default::actionID(ID) & identification::identified(List) & .all_names(Ags) & .length(Ags,NumberAgents) & not .length(List,NumberAgents-1)
<-
	+action::reasoning_about_belief(identification);
//	.print("I see another agent of my team at ", X, ",", Y);
	.print("START TURN");
	.broadcast(achieve, identification::request_information(ID));
	.

@agentseesfinal[atomic]
+agent_sees(_,_)[source(Name)] 
	: .all_names(Ags) & .length(Ags,NumberAgents) & count(NumberAgents-2)
<-
	.print("I AM HERE!");
	-count(_);
	+count(0);
	!!identify(Ags);
	.
@agentseesfinal2[atomic]
+agent_sees(_,_)[source(Name)] 
	: count(N)
<-
	-count(N);
	+count(N+1);
	.

	
+!identify(Ags)
	: true
<-
	!check_all_agent_sees(Ags);
	.abolish(identification::agent_sees(_,_)[source(_)]);
	.print("END TURN");
	-action::reasoning_about_belief(identification);
	.

+!request_information(ID)[source(Name)] 
	: true 
<- 
	.wait(default::actionID(ID)); 
	!send_information(Name);
	.
	
+!send_information(Name)
	: default::team(Team) & default::thing(MyX, MyY, entity, Team) & not(MyX == 0 & MyY == 0)
<-
	.findall(see(X, Y, Kind, Thing), default::thing(X, Y, Kind, Thing), EverythingSeen);
	.send(Name, tell, identification::agent_sees(see,EverythingSeen));
	.
	
+!send_information(Name)
	: true
<-
	.send(Name, tell, identification::agent_sees(skip,_));
	.
 
@addid1[atomic]
+!add_identified_ags([],IdList) : true <- true.
@addid2[atomic]
+!add_identified_ags([Ag|Ags],IdList) : .member(Ag,IdList)  <- !add_identified_ags(Ags,IdList).
@addid3[atomic]
+!add_identified_ags([Ag|Ags],IdList) 
	: not .member(Ag,IdList)
<- 
	?identification::merge(MergeOldList); 
	-identification::merge(MergeOldList);
	?identification::i_know(Ag,LocalX,LocalY);
	+identification::merge([agent(Ag,LocalX,LocalY)|MergeOldList]);
	!add_identified_ags(Ags,IdList);
	.
	
@updateidmergeside[atomic]
+!update_identified(List)[source(Ag)]
	: .my_name(Me)
<-
	?identification::identified(OldList);
	-identification::identified(OldList);
	.delete(Me,List,AuxList);
	.union(AuxList,[Ag],NewList);
	+identification::identified(NewList);
	!stop::new_dispenser_or_merge;
	if(not retrieve::retriever){
		!stop::check_join_group;
	}
	.
@updateidother[atomic]
+!update_identified(List,NewOriginX,NewOriginY)[source(Ag)]
	: .my_name(Me)
<-
	?identification::identified(OldList);
	-identification::identified(OldList);
	.delete(Me,List,AuxList);
	.union(AuxList,[Ag],NewList);
	+identification::identified(NewList);
	!update_pos(Ag,NewOriginX,NewOriginY);
	!stop::new_dispenser_or_merge;
	if(not retrieve::retriever){
		!stop::check_join_group;
	}
	.
	
@updatepos[atomic]
+!update_pos(MapOther,OriginX,OriginY)
	: map::myMap(Map) & .my_name(Me) & .all_names(AllAgents) & .nth(Pos,AllAgents,Me)
<-
	-map::myMap(Map);
	+map::myMap(MapOther);
	getMyPos(MyX,MyY);
	updateMyPos(MyX+OriginX,MyY+OriginY);
	if(retrieve::target(TargetX, TargetY)){
		-+retrieve::target(TargetX+OriginX,TargetY+OriginY);
	}
	if(Map \== MapOther){
		getTargetGoal(GoalAgent, GoalX, GoalY);
		.term2string(Me, Me1);
		if(GoalAgent == Me1){
			setTargetGoal(Pos, Me, OriginX+GoalX, OriginY+GoalY);
		}
	}
	.

@requestmerge[atomic]
+!request_merge(MergeList,GlobalX,GlobalY)[source(_)]
	: true
<-
	for (.member(agent(Ag,LocalX,LocalY),MergeList)) {
		?identification::identified(IdList);
		if (not .member(Ag,IdList)) {
			.send(Ag, achieve, identification::request_leader(Ag,LocalX,LocalY,GlobalX,GlobalY));
		}
	}
	.

+!request_leader(Ag,LocalX,LocalY,GlobalX,GlobalY)[source(Source)]
	: map::myMap(Leader)
<-
	.print(Source," requested leader to merge with ",Ag);
	!map::get_dispensers(DispList);
	!map::get_clusters(Clusters);
	getMyPos(OtherX,OtherY);
	.send(Source, achieve, identification::reply_leader(Leader,LocalX,LocalY,GlobalX,GlobalY,OtherX,OtherY,DispList,Clusters));
	.

@replyleaderme[atomic]
+!reply_leader(Leader,LocalX,LocalY,GlobalX,GlobalY,OtherX,OtherY,DispList,ClusterGoalList)[source(Source)]
	: .my_name(Me) & map::myMap(Me) & .all_names(AllAgents) & .nth(Pos,AllAgents,Me) & .nth(PosOther,AllAgents,Leader) & Pos < PosOther
<-
	.send(Leader, achieve, identification::confirm_merge);
	.wait(identification::merge_confirmed(IdListOther)[source(Leader)] | identification::merge_canceled[source(Leader)]);
	if (identification::merge_confirmed(IdListOther)[source(Leader)]) {
		-identification::merge_confirmed(IdListOther)[source(Leader)];
		NewOriginX = (GlobalX + LocalX) - OtherX;
		NewOriginY = (GlobalY + LocalY) - OtherY;
		for (.member(dispenser(Type,DX,DY),DispList)) {
			updateMap(Me,Type,NewOriginX+DX,NewOriginY+DY);
		}
		for(.member(cluster(ClusterId, GoalList),ClusterGoalList)){
			for (.member(goal(GX,GY),GoalList)) {
				updateGoalMap(Me,NewOriginX+GX,NewOriginY+GY, _);
			}
			for (.member(origin(GX,GY),GoalList)) {
				updateGoalMap(Me,NewOriginX+GX,NewOriginY+GY, _);
			}
			//!retrieve::update_target;
		}
		?identification::identified(IdList);
		-identification::identified(IdList);
		.union(IdList,IdListOther,NewListAux);
		.union(NewListAux,[Leader],NewList);
		+identification::identified(NewList);
		.send(Leader, tell, identification::merge_completed(NewList,NewOriginX,NewOriginY));
		for (.member(Ag,IdList)) {
			.send(Ag, achieve, identification::update_identified(NewList));
		}
		for (.member(Ag,IdListOther)) {
			.send(Ag, achieve, identification::update_identified(NewList,NewOriginX,NewOriginY));
		}
		!stop::new_dispenser_or_merge;
		if(not retrieve::retriever){
			!stop::check_join_group;
		}
	}
	else {
		-identification::merge_canceled[source(Leader)];
		.print("Merge has been canceled!");
	}
	.
@replyleadernotme[atomic]
+!reply_leader(Leader,LocalX,LocalY,GlobalX,GlobalY,OtherX,OtherY,DispList,GoalList)[source(Source)].

@waitformerge[atomic]
+!identification::confirm_merge[source(Ag)]
	: .my_name(Me) & map::myMap(Me)
<-
	?identification::identified(IdListOther);
	.send(Ag, tell, identification::merge_confirmed(IdListOther));
	.wait(identification::merge_completed(NewListAux,NewOriginX,NewOriginY)[source(Ag)]);
	-identification::merge_completed(NewListAux,NewOriginX,NewOriginY)[source(Ag)];
	-identification::identified(IdListOther);
	.delete(Me,NewListAux,NewListAux2);
	.union(NewListAux2,[Ag],NewList);
	+identification::identified(NewList);
	!update_pos(Ag,NewOriginX,NewOriginY);
	!stop::new_dispenser_or_merge;
	.
@cancelmerge[atomic]
+!identification::confirm_merge[source(Ag)]
	: true
<-
	.send(Ag, tell, identification::merge_canceled);
	.

+!check_all_agent_sees([]) 
	: .all_names(Ags) & .my_name(Me)
<- 
	.findall(Ag, (identification::i_know(Ag, _, _) & not(identification::doubts_on(Ag))), Iknow);
	+merge([]);
	?identification::identified(IdList);
	!add_identified_ags(Iknow,IdList);
	?merge(MergeList);
	-merge(MergeList);
	?map::myMap(Leader);
	if (not .empty(MergeList)) {
		getMyPos(MyX,MyY);
		if (Me == Leader) {
			!request_merge(MergeList,MyX,MyY);
		}
		else {
			.send(Leader, achieve, identification::request_merge(MergeList,MyX,MyY));
		}
	}
	.abolish(identification::i_know(_, _, _));
	.abolish(identification::doubts_on(_));
	.
+!check_all_agent_sees([Ag|Ags]) 
	: agent_sees(see, EverythingSeen)[source(Ag)]
<- 
	!check_agent_sees(Ag, EverythingSeen);
	!check_all_agent_sees(Ags);
	.
+!check_all_agent_sees([Ag|Ags]) 
	: true
<- 
	!check_all_agent_sees(Ags);
	.

+!check_agent_sees(Name, EverythingSeen)
	: .findall(thing(X, Y, entity, Team), (default::thing(X, Y, entity, Team)), Things) & i_see_it(EverythingSeen, MyViewX, MyViewY) & identify(EverythingSeen, MyViewX, MyViewY)
<- 
	!update_known_agents(Name, MyViewX, MyViewY);
	.
+!check_agent_sees(Name, EverythingSeen) : true <- true.
 	
+!update_known_agents(Name, MyViewX, MyViewY) : identification::i_know(Name1, MyViewX, MyViewY) & Name \== Name1
<- 
//	.print("I am not sure who is ", Name, " and who ", Name1, ".. So I do not decide for now."); 
	-identification::i_know(Name1, _, _);
	-+identification::doubts_on(Name).
+!update_known_agents(Name, MyViewX, MyViewY) : true
<- -identification::i_know(Name, _, _); +identification::i_know(Name, MyViewX, MyViewY).
