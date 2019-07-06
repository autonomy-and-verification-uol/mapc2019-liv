/* Initial beliefs and rules */

identify_1(WhatItSees, WhoX, WhoY) :-
	.findall(Name,
	(
		.member(see(X, Y, Kind, Name), WhatItSees) &
		X1 = WhoX + X & Y1 = WhoY + Y &
		X1 < 5 & Y1 < 5 &
		not(default::thing(X1, Y1, Kind, Name))
	), []).
	
identify(_, [], _, _) :- true.
identify(Agent, [see(Agent, X, Y, entity, _)|L], WhoX, WhoY) :-
	MyViewX = -X & MyViewY = -Y & default::thing(MyViewX, MyViewY, entity, _) &
	.findall(see(X1, Y1, Kind, Name), see(Agent, X1, Y1, Kind, Name), WhatItSees) &
	identify_1(WhatItSees, WhoX, WhoY) &
	identify(Agent, L, WhoX, WhoY).
identify(Agent, [_|L], WhoX, WhoY) :-
	identify(Agent, L, WhoX, Whoy).
	
i_see_it(EverythingSeen, MyViewX, MyViewY) :-
 	.member(see(X, Y, _, _), EverythingSeen) &
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

/* Initial goals */

 
/* 
+default::thing(0, 0, entity, Team)
	: true //default::team(Team) & .my_name(Me) & (X \== 0 | Y \== 0)
<-
	//.print("I see another agent of my team at ",X,",",Y);
	//.broadcast(tell, see(Me, X, Y));
	!!check_things.*/
	
+!check_things : .my_name(Me)
<- 
	.findall(see(X, Y, Kind, Name), (thing(X, Y, Kind, Name) & (X \== 0 | Y \== 0)), EverythingSeen);
	.broadcast(tell, agent_sees(Me, EverythingSeen));
	-+identification::go(Me).

+default::agent_sees(Name, EverythingSeen)[source(Name)]: true
<-
	.wait("+identification::go(_)");
	!check_agent_sees(Name, EverythingSeen);
	-agent_sees(Name, EverythingSeen).

+!check_agent_sees(Name, EverythingSeen): 
	.findall(agent_sees(N, ES), (default::agent_sees(N, ES) & N \== Name), AS) &
	no_more_on_sight(AS) & i_see_it(EverythingSeen, MyViewX, MyViewY)
<- 
	.print("I have only one agent on my sight.. So I know who he/she is");
	+i_know(Name, MyViewX, MyViewY).
+!check_agent_sees(Name, EverythingSeen):
	i_see_it(EverythingSeen, MyViewX, MyViewY) &
	identify(Name, EverythingSeen, MyViewX, MyViewY)
<- 
	+i_know(Name, MyViewX, MyViewY).
+!check_agent_sees(Name, EverythingSeen) : true 
<- 
	.print("I am not able to identify the agent ", Name, " yet.").
 	



{ include("$jacamoJar/templates/common-cartago.asl") }
{ include("$jacamoJar/templates/common-moise.asl") }


// uncomment the include below to have an agent compliant with its organisation
//{ include("$moiseJar/asl/org-obedient.asl") }
