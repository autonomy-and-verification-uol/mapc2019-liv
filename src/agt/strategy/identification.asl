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
+agent_sees(_,_)[source(_)] 
	: .all_names(Ags) & .length(Ags,NumberAgents) & .count(identification::agent_sees(_,_)[source(_)],NumberAgents-1)
<-
//	for (identification::agent_sees(see,Arg)[source(Name)]){
//		.print("Everything seen by ",Name,": ",Arg);
//	}
	.print("I AM HERE!");
	!!identify(Ags);
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
 

+!add_identified_ags([],IdList) : true <- true.
+!add_identified_ags([Ag|Ags],IdList) : .member(Ag,IdList)  <- !add_identified_ags(Ags,IdList).
+!add_identified_ags([Ag|Ags],IdList) 
	: not .member(Ag,IdList) //& not identification::merged
<- 
	?identification::identified(OldList); 
	-identification::identified(OldList);  
	+identification::identified([Ag|OldList]);
//	.print("Adding new identified agent ",Ag);
	!map::get_map_size(Size);
	?identification::identified(IdListAux);
	Identified = .length(IdListAux);
	.print("Sending map size to ",Ag);
	.send(Ag,tell,map::map_size(Size,Identified));
	.print("Waiting for map size from ",Ag);
	.wait(map::map_size(SizeOther,IdentifiedOther)[source(Ag)]);
	-map::map_size(SizeOther,IdentifiedOther)[source(Ag)];
	if (Size > SizeOther) {
		.print("I am the origin!");
	}
	elif (Size == SizeOther) {
		if (Identified > IdentifiedOther) {
			.print("I am the origin (second try, known agents)!");	
		}
		elif (Identified == IdentifiedOther) {
			.print("We dont know how to decide the origin, time to pick randomly.");
			.all_names(AllAgents);
			.my_name(Me);
			.nth(Pos,AllAgents,Me);
			.nth(PosOther,AllAgents,Ag);
			if (Pos > PosOther) {
				.print("I am the origin (third try, random)!");
			}
			else {
				.print("I am not the origin (third try, random).");
			}
		}
		else {
			.print("I am not the origin (second try, known agents).");
		}
	}
	else { .print("I am not the origin."); }
	getMyPos(MyX,MyY);
//	mergeMaps(MyX,MyY,List);
//	+identification::merged;
	!add_identified_ags(Ags,IdList);
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
