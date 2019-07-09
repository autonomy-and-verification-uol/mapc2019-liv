/* Initial beliefs and rules */

identify(WhatItSees, WhoX, WhoY) :-
	.findall(Name,
	(
		.member(see(X, Y, Kind, Name), WhatItSees) &
		X1 = WhoX + X & Y1 = WhoY + Y &
		math.abs(X1 + Y1) <= 5 & 
		not(default::thing(X1, Y1, Kind, Name))
	), []) &
	.findall(Name,
	(
		default::thing(X, Y, Kind, Name) &
		X1 = X - WhoX & Y1 = Y - WhoY &
		math.abs(X1 + Y1) <= 5 & 
		not(.member(see(X1, Y1, Kind, Name), WhatItSees))
	), []).
	
i_see_it(EverythingSeen, MyViewX, MyViewY) :-
 	.member(see(X, Y, _, _), EverythingSeen) & not(X = 0 & Y = 0) &
 	MyViewX = -X &
 	MyViewY = -Y &
 	default::thing(MyViewX, MyViewY, entity, _).
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

i_see_someone :- 
	default::team(Team) &
	.findall(dummy(X, Y), (default::thing(X, Y, entity, Team) & not(X == 0 & Y == 0)), L) &
	.length(L, N) & N \== 0.
	
// To be removed, we can simply call the standard one of Jacamo
identification::agents([agent1, agent2, agent3, agent4]).//, agent5, agent6, agent7, agent8, agent9, agent10]).

/* Initial goals */

 
/* 
+default::thing(0, 0, entity, Team)
	: true //default::team(Team) & .my_name(Me) & (X \== 0 | Y \== 0)
<-
	//.print("I see another agent of my team at ",X,",",Y);
	//.broadcast(tell, see(Me, X, Y));
	!!check_things.*/
	
+!send_to_interested_ags([], _, _) : true <- true.
+!send_to_interested_ags([Me|Ags], Me, EverythingSeen) : true
<- !send_to_interested_ags(Ags, Me, EverythingSeen).
+!send_to_interested_ags([Ag|Ags], Me, EverythingSeen) : identification::i_know(Ag, _, _)
<- !send_to_interested_ags(Ags, Me, EverythingSeen).
+!send_to_interested_ags([Ag|Ags], Me, EverythingSeen) : true
<- 
	.print("Send what I see to other agents");
	.send(Ag, untell, agent_sees(Me, _));
	.send(Ag, tell, agent_sees(Me, EverythingSeen));
	!send_to_interested_ags(Ags, Me, EverythingSeen).
	
+!check_things : .my_name(Me) & i_see_someone & identification::agents(Ags)
<- 
	.findall(see(X, Y, Kind, Name), default::thing(X, Y, Kind, Name), EverythingSeen);
	!send_to_interested_ags(Ags, Me, EverythingSeen);
	-+identification::go(Me).
+!check_things : .my_name(Me) 
<- 
	.broadcast(achieve, skip(Me));
	.print("I do not see anyone around me.. Identification skipped").

//@agseen1[atomic]
+default::agent_sees(Name, EverythingSeen)[source(Name)] : .my_name(Me) & identification::agents(Ags) & not(identification::agents_to_hear_from(_))
<- 
	.delete(Me, Ags, Ags1);
	.delete(Name, Ags1, Ags2);
	.print("First time.. Add agent_to_hear_from: ", Ags2);
	+identification::agents_to_hear_from(Ags2).
	//-+default::agent_sees(Name, EverythingSeen)[source(Name)].
//@agseen2[atomic]
+default::agent_sees(Name, EverythingSeen)[source(Name)]: identification::agents(Ags) & identification::agents_to_hear_from([Name])
<-
	.print("Wait to be sure to have things loaded");
	.wait("+identification::go(_)");
	.print("Check all_agent_sees");
	!check_all_agent_sees(Ags);
	-agent_sees(_, _).
//@agseen3[atomic]
+default::agent_sees(Name, EverythingSeen)[source(Name)]: identification::agents_to_hear_from(Ags)
<- 
	.print("Waiting for others to communicate their position to me.. or skip..", Ags);
	.delete(Name, Ags, Ags1);
	-+identification::agents_to_hear_from(Ags1).
//@agskip1[atomic]
+!default::skip(Name)[source(Name)]: .my_name(Me) & identification::agents(Ags) & not(identification::agents_to_hear_from(_))
<- 
	.delete(Me, Ags, Ags1);
	.delete(Name, Ags1, Ags2);
	.print("First time.. Add agent_to_hear_from: ", Ags2);
	+identification::agents_to_hear_from(Ags2).
//@agskip2[atomic]
+!default::skip(Name)[source(Name)]: identification::agents(Ags) & identification::agents_to_hear_from([Name])
<- 
	.wait("+identification::go(_)");
	.print("Check all agents_sees");
	!check_all_agent_sees(Ags);
	-agent_sees(_, _).
//@agskip3[atomic]
+!default::skip(Name)[source(Name)]: identification::agents_to_hear_from(Ags)
<- 
	.print("Waiting for others to communicate their position to me.. or skip..", Ags);
	.delete(Name, Ags, Ags1);
	-+identification::agents_to_hear_from(Ags1).


+!check_all_agent_sees([]) : .my_name(Me) & identification::agents(Agents)
<- 
	//.delete(Me, Agents, Agents1);
	.findall(Ag, (.member(Ag, Agents) & Ag \== Me & not(identification::i_know(Ag, _, _))), Agents1);
	.print("Next round Agents unknown: ", Agents1);
	-agents_to_hear_from(_);
	+agents_to_hear_from(Agents1).
+!check_all_agent_sees([Ag|Ags]) : default::agent_sees(Ag, EverythingSeen)
<- 
	!check_agent_sees(Ag, EverythingSeen);
	!check_all_agent_sees(Ags).
+!check_all_agent_sees([Ag|Ags]) : true
<- 
	!check_all_agent_sees(Ags).


+!check_agent_sees(Name, EverythingSeen):
	i_see_it(EverythingSeen, MyViewX, MyViewY) & 
	identify(EverythingSeen, MyViewX, MyViewY)
<- !update_known_agents(Name, MyViewX, MyViewY).
+!check_agent_sees(Name, EverythingSeen) : true 
<- .print("I am not able to identify the agent ", Name, " yet.").
 	
+!update_known_agents(Name, MyViewX, MyViewY) : identification::i_know(Name1, MyViewX, MyViewY) & Name \== Name1
<- .print("I am not sure who is ", Name, " and who ", Name1, ".. So I do not decide for now."); -identification::i_know(Name1, _, _).
+!update_known_agents(Name, MyViewX, MyViewY) : true
<- +identification::i_know(Name, MyViewX, MyViewY).


{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }


// uncomment the include below to have an agent compliant with its organisation
//{ include("$moiseJar/asl/org-obedient.asl") }
