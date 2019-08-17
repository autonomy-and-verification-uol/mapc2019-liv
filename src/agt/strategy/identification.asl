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
	?identification::identified(OldList); 
	-identification::identified(OldList);  
	+identification::identified([Ag|OldList]);
	!add_identified_ags(Ags,IdList);
	.
	
	
//	?identification::identified(OldList);
//	Identified = .length(OldList);
////	.print("Adding new identified agent ",Ag);
//	!map::get_map_size(Size);
//	.print("Sending map size to ",Ag);
//	getMyPos(MyX,MyY);
//	?identification::i_know(Ag,LocalX,LocalY);
//	?map::myMap(Map);
//	.send(Ag,tell,map::map_size(Size,Identified,MyX,MyY,LocalX,LocalY,Map,OldList));
//	.print("Waiting for map size from ",Ag);
//	.wait(map::map_size(SizeOther,IdentifiedOther,OtherX,OtherY,LocalXOther,LocalYOther,MapOther,OldListOther)[source(Ag)]);
//	-map::map_size(SizeOther,IdentifiedOther,OtherX,OtherY,LocalXOther,LocalYOther,MapOther,OldListOther)[source(Ag)];
//	if (Size > SizeOther) {
//		.print("I am the origin!");
//		!merge_id(OldListOther,Ag);
//	}
//	elif (Size == SizeOther) {
//		if (Identified > IdentifiedOther) {
//			.print("I am the origin (second try, known agents)!");
//			!merge_id(OldListOther,Ag);
//		}
//		elif (Identified == IdentifiedOther) {
//			.print("We dont know how to decide the origin, time to pick randomly.");
//			.all_names(AllAgents);
//			.my_name(Me);
//			.nth(Pos,AllAgents,Me);
//			.nth(PosOther,AllAgents,Ag);
//			if (Pos > PosOther) {
//				.print("I am the origin (third try, random)!");
//				!merge_id(OldListOther,Ag);
//			}
//			else {
//				.print("I am not the origin (third try, random).");
//				!merge_map(Map,MapOther,LocalXOther,OtherX,LocalYOther,OtherY,MyX,MyY,OldList);
//			}
//		}
//		else {
//			.print("I am not the origin (second try, known agents).");
//			!merge_map(Map,MapOther,LocalXOther,OtherX,LocalYOther,OtherY,MyX,MyY,OldList);
//		}
//	}
//	else { 
//		.print("I am not the origin.");
//		!merge_map(Map,MapOther,LocalXOther,OtherX,LocalYOther,OtherY,MyX,MyY,OldList);
//	}
//	!add_identified_ags(Ags,IdList);
//	.

+!merge_id(OldListOther,AgSeen)
	: .my_name(Me)
<-
	?identification::identified(OldListOld);
	-identification::identified(OldListOld);
	+identification::identified([AgSeen|OldListOld]);
	for (.member(Ag,OldListOther)) {
		?identification::identified(OldList);
		-identification::identified(OldList);
		+identification::identified([Ag|OldList]);
	}
	?identification::identified(FinalList);
	for (.member(Ag,FinalList)) {
		.send(Ag,achieve,identification::update_identified([Me|FinalList]));
	}
	.

@updateid[atomic]
+!update_identified(List)[source(_)]
	: .my_name(Me)
<-
	?identification::identified(OldList);
	-identification::identified(OldList);
	.delete(Me,List,NewList);
	+identification::identified(NewList);
	.
	
+!merge_map(Map,MapOther,LocalXOther,OtherX,LocalYOther,OtherY,MyX,MyY,OldList)
	: true
<-
	NewOriginX = (LocalXOther + OtherX) - MyX;
	NewOriginY = (LocalYOther + OtherY) - MyY;
	for (.member(Ag,OldList)) {
		.send(Ag,achieve,identification::update_pos(NewOriginX,NewOriginY,MapOther));
	}
	updateMyPos(LocalXOther+OtherX,LocalYOther+OtherY);
	!map::get_dispensers(DispList);
	!map::get_goal(GoalList);
	-map::myMap(Map);
	+map::myMap(MapOther);
	for (.member(dispenser(Type,DX,DY),DispList)) {
		updateMap(MapOther,Type,NewOriginX+DX,NewOriginY+DY);
	}
	for (.member(goal(GX,GY),GoalList)) {
		updateMap(MapOther,goal,NewOriginX+GX,NewOriginY+GY);
	}
	.

@updatepos[atomic]
+!update_pos(OriginX,OriginY,MapOther)[source(_)]
	: map::myMap(Map) & .my_name(Me)
<-
	-map::myMap(Map);
	+map::myMap(MapOther);
	getMyPos(MyX,MyY);
	updateMyPos(MyX+OriginX,MyY+OriginY);
	.

+!check_all_agent_sees([]) 
	: .all_names(Ags)
<- 
	.findall(Ag, (identification::i_know(Ag, _, _) & not(identification::doubts_on(Ag))), Iknow);
	?identification::identified(IdList);
	!add_identified_ags(Iknow,IdList);
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
