/* Initial beliefs and rules */

identify(WhatItSees, WhoX, WhoY) :-
	.findall(Name,
	(
		.member(see(X, Y, Kind, Name), WhatItSees) &
		X1 = WhoX + X & Y1 = WhoY + Y &
		(math.abs(X1) + math.abs(Y1)) <= 5 & 
		not(default::thing(X1, Y1, Kind, Name))
	), L) & .print("L: ", L) & L = [] &
	.findall(Name,
	(
		default::thing(X, Y, Kind, Name) &
		X1 = X - WhoX & Y1 = Y - WhoY &
		(math.abs(X1) + math.abs(Y1)) <= 5 & 
		not(.member(see(X1, Y1, Kind, Name), WhatItSees))
	), L1) & .print("L1: ", L1) & L1 = [].
	
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

i_see_someone :- 
	default::team(Team) &
	.findall(dummy(X, Y), (default::thing(X, Y, entity, Team) & not(X == 0 & Y == 0)), L) &
	.length(L, N) & N \== 0.
	
// To be removed, we can simply call the standard one of Jacamo
//identification::agents([agent1, agent2, agent3, agent4]).//, agent5, agent6, agent7, agent8, agent9, agent10]).

/* Initial goals */

+default::thing(X, Y, entity, Team)
	: not(X = 0 & Y = 0) & default::team(Team) & not(action::reasoning_about_belief(identification)) & default::actionID(ID)
<-
	+action::reasoning_about_belief(identification);
	.print("I see another agent of my team at ", X, ",", Y);
	!check_things(ID);
	.
	
+!send_to_interested_ags(_, [], _, _) : true <- true.
+!send_to_interested_ags(ID, [Me|Ags], Me, EverythingSeen) : true
<- !send_to_interested_ags(ID, Ags, Me, EverythingSeen).
+!send_to_interested_ags(ID, [Ag|Ags], Me, EverythingSeen) : identification::identified(Ag)
<- !send_to_interested_ags(ID, Ags, Me, EverythingSeen).
+!send_to_interested_ags(ID, [Ag|Ags], Me, EverythingSeen) : true
<- 
	.print("Send to ", Ag," what I see: ", EverythingSeen);
	//.send(Ag, untell, agent_sees(Me, _));
	.send(Ag, tell, agent_sees(ID, Me, EverythingSeen));
	!send_to_interested_ags(ID, Ags, Me, EverythingSeen).

+!check_things(ID) : .my_name(Me) & .all_names(Ags)
<- 
	.print("START TURN");
	//+action::reasoning_about_belief(identification);
	-identification::go(Me);
	.findall(see(X, Y, Kind, Name), default::thing(X, Y, Kind, Name), EverythingSeen);
	!send_to_interested_ags(ID, Ags, Me, EverythingSeen);
	-+sent(ID);
	+identification::go(Me).

/*+!identify : .my_name(Me) & i_see_someone & .all_names(Ags)
<- 
	.print("START TURN");
	+action::reasoning_about_belief(identification);
	-identification::go(Me);
	.findall(see(X, Y, Kind, Name), default::thing(X, Y, Kind, Name), EverythingSeen);
	!send_to_interested_ags(Ags, Me, EverythingSeen);
	+identification::go(Me).
+!identify : .my_name(Me) 
<- 
	.print("START TURN");
	+action::reasoning_about_belief(identification);
	-identification::go(Me);
	.broadcast(achieve, skip(Me));
	.print("I do not see anyone around me.. Identification skipped");
	+identification::go(Me).*/

 +default::agent_sees(ID, Name, EverythingSeen)[source(Name)] : true <- .wait(default::actionID(ID)); !agent_sees_plan(ID, Name, EverythingSeen).
 
 +!agent_sees_plan(ID, Name, EverythingSeen) : sent(ID) <- !agent_sees_plan_aux(Name, EverythingSeen).
 +!agent_sees_plan(ID, Name, EverythingSeen) : true <- !check_things(ID); !agent_sees_plan_aux(Name, EverythingSeen).
 
//@agseen1[atomic]
+!agent_sees_plan_aux(Name, EverythingSeen) : 
	.my_name(Me) & .all_names(Ags) & not(identification::agents_to_hear_from(_)) & 
	default::team(Team) & default::thing(X, Y, entity, Team) & not(X = 0 & Y = 0)
<- 
	.print("start1");
	.delete(Me, Ags, Ags1);
	.delete(Name, Ags1, Ags2);
	.print("First time.. Add agent_to_hear_from: ", Ags2);
	+identification::agents_to_hear_from(Ags2);
	.print("finish1").
	//-+default::agent_sees(Name, EverythingSeen)[source(Name)].
//@agseen2[atomic]
+!agent_sees_plan_aux(Name, EverythingSeen): 
	.all_names(Ags) & identification::agents_to_hear_from([Name]) &
	default::team(Team) & default::thing(X, Y, entity, Team) & not(X = 0 & Y = 0)
<-
	.print("start2");
	.print("Wait to be sure to have things loaded");
	.wait(identification::go(_));
	//.print("After go: ", Things);
	-identification::go(_);
	.print("Check all_agent_sees: ", Ags);
	.findall(agent_sees(Ag, See), default::agent_sees(Ag, See), AgentSees);
	.print("agent_sees: ", AgentSees);
	!check_all_agent_sees(Ags);
	.abolish(default::agent_sees(_, _, _)[source(_)]);
	.print("finish2");
	-action::reasoning_about_belief(identification);
	.print("END TURN").
//@agseen3[atomic]
+!agent_sees_plan_aux(Name, EverythingSeen): 
	identification::agents_to_hear_from(Ags) & 
	default::team(Team) & default::thing(X, Y, entity, Team) & not(X = 0 & Y = 0)
<- 
	.print("start3");
	.delete(Name, Ags, Ags1);
	.print(Name, " sent me a msg, but I have to wait for others to communicate their position to me.. or skip..", Ags1);
	//.findall(agent_sees(Ag, See), (default::agent_sees(Ag, See)), AgentSees);
	//.print("agent_sees: ", AgentSees);
	-+identification::agents_to_hear_from(Ags1);
	.print("finish3").
+!agent_sees_plan_aux(Name, EverythingSeen): 
	.my_name(Me)
<- 
	.print("Send a skip to ", Name);
	.send(Name, achieve, skip(Me));
	.abolish(default::agent_sees(_, _, _)[source(_)]).
//@agskip1[atomic]
+!default::skip(Name)[source(Name)]: .my_name(Me) & .all_names(Ags) & not(identification::agents_to_hear_from(_))
<- 
	.print("start4");
	.delete(Me, Ags, Ags1);
	.delete(Name, Ags1, Ags2);
	.print("First time.. Add agent_to_hear_from: ", Ags2);
	+identification::agents_to_hear_from(Ags2);
	.print("finish4").
//@agskip2[atomic]
+!default::skip(Name)[source(Name)]: .all_names(Ags) & identification::agents_to_hear_from([Name])
<- 
	.print("start5");
	.print(Name, " sent me a skip");
	.wait(identification::go(_));
	-identification::go(_);
	.print("Check all agents_sees: ", Ags);
	.findall(agent_sees(Ag, See), default::agent_sees(_, Ag, See)[source(Ag)], AgentSees);
	.print("agent_sees: ", AgentSees);
	!check_all_agent_sees(Ags);
	.abolish(default::agent_sees(_, _, _)[source(_)]);
	.print("finish5");
	-action::reasoning_about_belief(identification);
	.print("END TURN").
//@agskip3[atomic]
+!default::skip(Name)[source(Name)]: identification::agents_to_hear_from(Ags)
<- 
	.print("start6");
	.delete(Name, Ags, Ags1);
	.print(Name, " sent me a skip, but I have to wait for others to communicate their position to me.. or skip..", Ags1);
	-+identification::agents_to_hear_from(Ags1);
	.print("finish6").

+!add_identified_ags([]) : true <- true.
+!add_identified_ags([Ag|Ags]) : identification::identified(Ag) <- !add_identified_ags(Ags).
+!add_identified_ags([Ag|Ags]) : true <- +identification::identified(Ag); !add_identified_ags(Ags).

+!check_all_agent_sees([]) : .my_name(Me) & .all_names(Ags)
<- 
	//.delete(Me, Agents, Agents1);
	.findall(Ag, (identification::i_know(Ag, _, _) & not(identification::doubts_on(Ag))), Iknow);
	!add_identified_ags(Iknow);
	.abolish(identification::i_know(_, _, _));
	.abolish(identification::doubts_on(_));
	.findall(Ag, (.member(Ag, Ags) & not(identification::identified(Ag)) & Ag \== Me), Ags1); 
	.print("Next round Agents unknown: ", Ags1);
	-+identification::agents_to_hear_from(Ags1).
+!check_all_agent_sees([Ag|Ags]) : default::agent_sees(_, Ag, EverythingSeen)
<- 
	.print("Check ", Ag);
	!check_agent_sees(Ag, EverythingSeen);
	!check_all_agent_sees(Ags);
	.print("outside check agent").
+!check_all_agent_sees([Ag|Ags]) : true
<- 
	!check_all_agent_sees(Ags).


+!check_agent_sees(Name, EverythingSeen):
	.print("Try to see: ", EverythingSeen) &
	.findall(thing(X, Y, entity, Team), (default::thing(X, Y, entity, Team)), Things) &
	.print("Things: ", Things) &
	i_see_it(EverythingSeen, MyViewX, MyViewY) & 
	.print("Try to identify") &
	identify(EverythingSeen, MyViewX, MyViewY)
<- !update_known_agents(Name, MyViewX, MyViewY).
+!check_agent_sees(Name, EverythingSeen) : true 
<- .print("I am not able to identify the agent ", Name, " yet.").
 	
+!update_known_agents(Name, MyViewX, MyViewY) : identification::i_know(Name1, MyViewX, MyViewY) & Name \== Name1
<- 
	.print("I am not sure who is ", Name, " and who ", Name1, ".. So I do not decide for now."); 
	-identification::i_know(Name1, _, _);
	-+identification::doubts_on(Name).
+!update_known_agents(Name, MyViewX, MyViewY) : true
<- -identification::i_know(Name, _, _); +identification::i_know(Name, MyViewX, MyViewY).


{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }


// uncomment the include below to have an agent compliant with its organisation
//{ include("$moiseJar/asl/org-obedient.asl") }
