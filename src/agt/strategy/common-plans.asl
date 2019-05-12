centre_map(CLat,CLon)
:-
	default::minLat(MinLat) & 
	default::minLon(MinLon) & 
	default::maxLat(MaxLat) & 
	default::maxLon(MaxLon) & 
	CLat = (MinLat+MaxLat)/2 & 
	CLon = (MinLon+MaxLon)/2 
	.
get_best_facilities([],Lat,Lon,Route,Temp,ChosenFacilities)
:-
	ChosenFacilities = Temp
	.
get_best_facilities([Storage|Storages],Lat,Lon,Route,Temp,ChosenFacilities)
:-
	actions.route(truck,1,Lat,Lon,Storage,_,RouteStorage) &
	new::workshopList(WList) & 
	rules::closest_facility_truck(WList,Storage,Workshop) &
	actions.route(truck,1,Storage,Workshop,RouteLen) &
	RouteStorage+RouteLen < Route &
	get_best_facilities(Storages,Lat,Lon,RouteStorage+RouteLen,chosen(Storage,Workshop),ChosenFacilities)
	.
get_best_facilities([Storage|Storages],Lat,Lon,Route,Temp,ChosenFacilities)
:-
	get_best_facilities(Storages,Lat,Lon,Route,Temp,ChosenFacilities)
	.
+!set_center_storage_workshop(ForbiddenStorages)
	: 	::centre_map(CLat,CLon) & 
		new::storageList(SList) &
		.difference(SList,ForbiddenStorages,NewList) &		 
		get_best_facilities(NewList,CLat,CLon,500,Temp,chosen(Storage,Workshop)) 
<-
	.broadcast(tell,strategies::centerStorage(Storage));
	.broadcast(tell,strategies::centerWorkshop(Workshop));
	-+centerStorage(Storage);
	-+centerWorkshop(Workshop);
	.print("Closest storage from the center is ",Storage);
	.print("Closest workshop from the storage above is ",Workshop);
	.	

+default::well(Well,Lat,Lon,Type,Team,Integrity)
	: default::team(MyTeam) & not .substring(MyTeam,Team) & not team::enemyWell(Well,_,_,_)
<-
	.print(">>>>>>>>>>>>>>>>>>>> I found a well that doesn't belong to my team ",Well);	
	addEnemyWell(Well,Lat,Lon,road);
	.

+team::resNode(NodeId,Lat,Lon,Item)
	: not ::analysing_resource & .findall(Item,team::resNode(_,_,_,Item),List) & .length(List)==1 & .my_name(Me) & default::play(Me,gatherer,g1)
<- 
	+::analysing_resource;
	.print("Found resource node: ",NodeId," for item: ",Item,", I can go there");
	.wait({+default::actionID(_)});
	!!reconsider_gather;
	-::analysing_resource;
	.
+team::resNode(NodeId,Lat,Lon,Item)
<- 
	.print("Found resource node: ",NodeId," for item: ",Item);
	.

+default::lastAction(Action)
	: Action \== noAction
<-
	-+::noActionCount(0);
	.
+default::lastAction(Action)
	: default::step(S) & S \== 0 & Action == noAction & new::noActionCount(Count)
<-
	-+new::noActionCount(Count+1);
	.print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Step ",S-1," I have done ",Count+1," noActions.");
	-+metrics::noAction(Count+1);
	if ((not ::team_ready) | (::noActionCount(C) & C+1 < 3)){
		-+::noActionCount(C+1);
	} else{
		.print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> I died");
		!reborn::revive;
	}
	.
	
+default::massium(Money)
	: not ::becoming_builder & .my_name(Me) & default::play(Me,Role,g1) & (Role==builder | Role==super_builder)
<-
	+::becoming_builder;
	.print("We have enough money!!!");
	.wait({+default::actionID(_)});
	!!demanded_well;
	-::becoming_builder;
	.

+!always_recharge <- !action::recharge_is_new_skip; !always_recharge.

+!change_role(OldRole2,NewRole)
	: .my_name(Me) & default::play(Me,OldRole,g1) & OldRole==NewRole
<-
	.print("I'm already ",NewRole);
	.
@change_role[atomic]
+!change_role(OldRole2, NewRole)
	: .my_name(Me) & default::play(Me,OldRole,g1) & default::group(_,team,GroupId)
<-
	.print("I was ",OldRole," becoming ",NewRole);
	leaveRole(OldRole)[artifact_id(GroupId)];
	adoptRole(NewRole)[artifact_id(GroupId)];
	.wait(default::play(Me,NewRole,g1));
	.
	
// ### AWARD ###
+default::winner(Me,assembly,Duty,Tasks,TaskId)
	: .my_name(Me) & default::joined(org,OrgId) & .term2string(TaskId,STaskId) & default::play(Me,CurrentRole,g1)
<-
	+::winner(Me,assembly,Duty,Tasks,TaskId);
	-default::winner(Me,assembly,Duty,Tasks,TaskId);
	.print("*************************************************** I'm winner ",TaskId," ",Duty," ",Tasks);
	!action::forget_old_action;	
 	!change_role(CurrentRole,assembler);
 	!prepare_assembly(TaskId,Duty);
	.
+!prepare_assembly(TaskId,[]).
+!prepare_assembly(TaskId,[assemble(Item,Qty)|Duty])
	: default::joined(org,OrgId) & .concat(TaskId,"_",Item,"_group",GroupName) & .concat(TaskId,"_",Item,SchemeName) & .my_name(Me)
<-
	org::createGroup(GroupName, manufactory, GroupId)[artifact_id(OrgId)];
	org::focus(GroupId)[wid(OrgId)];
	org::adoptRole(assembler)[artifact_name(GroupName)];
	org::createScheme(SchemeName, assembly, SchArtId)[wid(OrgId)];	
	org::setArgumentValue(item_manufactured,"Item",Item)[artifact_id(SchArtId)];
	org::setArgumentValue(item_manufactured,"Qty",Qty)[artifact_id(SchArtId)];
	org::focus(SchArtId)[wid(OrgId)];
	org::addScheme(SchemeName)[artifact_name(GroupName)];
	org::commitMission(mretrieve)[artifact_id(SchArtId)];
	org::commitMission(massemble)[artifact_id(SchArtId)];
   	!prepare_assembly(TaskId,Duty);
	.
+!prepare_assembly(TaskId,[assist(Assembler,Item)|Duty])
	: default::joined(org,OrgId) & .concat(TaskId,"_",Item,"_group",GroupName) & .concat(TaskId,"_",Item,SchemeName)
<-	
	org::focusWhenAvailable(GroupName)[wid(OrgId)];
	org::adoptRole(assistant)[artifact_name(GroupName),wid(OrgId)];
	org::focusWhenAvailable(SchemeName)[wid(OrgId)];
	org::commitMission(mretrieve)[artifact_name(SchemeName),wid(OrgId)];
	org::commitMission(massist)[artifact_name(SchemeName),wid(OrgId)];
   	!prepare_assembly(TaskId,Duty);
	.
	
+default::winner(TaskId,Tasks,DeliveryPoint)
	: .my_name(Me) & default::joined(org,OrgId) & default::play(Me,CurrentRole,g1)
<-
	+::winner(TaskId,Tasks,DeliveryPoint);
	-default::winner(TaskId,Tasks,DeliveryPoint);
	.print("*************************************************** I'm winner ",TaskId," ",Tasks," at ",DeliveryPoint);	
	!change_role(CurrentRole,deliveryagent);	
	!action::forget_old_action; 		
	!perform_delivery;
	.	
-default::job(JobId,Storage,Reward,Start,End,Items)
	: ::winner(JobId,_,_) & default::lastAction(LastAction) & .substring("deliver_job",LastAction) & default::lastActionResult(successful_partial)
<-
	.print("### I've delivered my part of Priced Job ",JobId," ###");
	.
-default::job(JobId,Storage,Reward,Start,End,Items)
	: ::winner(JobId,_,_) & default::lastAction(LastAction) & .substring("deliver_job",LastAction) & default::lastActionResult(successful)
<-
	.print("### Priced Job ",JobId," Done, ",Reward,"$ in cash ###");
	.
-default::job(JobId,_,Reward,Start,End,Items)
	: ::winner(JobId,_,_)
<-
	.print("### Priced Job ",JobId," has FAILED");
	!recover_delivery(JobId);
	.

-default::mission(MissionId,_,_,_,End,Fine,_,_,Items)
	: default::step(Step) & Step > End // the mission could be deliveried at the final step, then this context is wrong
<-
	.print("### Mission ",MissionId," has FAILED, ",Fine,"$ we have to pay ### ",Items);
	if (::winner(MissionId,_,_)){
		!recover_delivery(MissionId);
	}
	.
-default::mission(MissionId,_,Reward,_,_,_,_,_,_)
<-
	.print("### Mission ",MissionId," Done, ",Reward,"$ in cash ###");
	.
	
+!go_back_to_work
	: .my_name(Me) & default::play(Me,gatherer,g1)
<-
	!action::forget_old_action;
	!gather;
	.
+!go_back_to_work
	: .my_name(Me) & default::play(Me,Role,g1) & (Role==explorer_drone | Role==super_explorer)
<-
	!action::forget_old_action;
	!explore::go_walk;
	.
+!go_back_to_work
	: .my_name(Me) & default::play(Me,Role,g1) & (Role==builder | Role==super_builder)
<-
	!action::forget_old_action;
	!strategies::build;
	.
	
// ### WHAT BUILDERS DO ###
select_random_facility(Facility)
:-
	new::dumpList(DList) &
	new::storageList(StList) &
	new::shopList(ShList) & 
	new::workshopList(WList) &
	.concat(DList,StList,ShList,WList,AllList) &
	.shuffle(AllList,List) &
	.nth(0,List,Facility)
	.
+!demanded_well
	: not .desire(build::_) & rules::enough_money
<-
	.current_intention(intention(IntentionId,_));
	.print("I need to build a Well right now!!! ",IntentionId);
	!action::forget_old_action;	
	!::build;	
	.
+!demanded_well.
+!build 
	: rules::enough_money
<-
	!build::buy_well; 	
	!build;
	.
+!build 
	: .my_name(Me) & default::play(Me,builder,g1) & team::enemyWell(Well,_,_,_) & attack::can_I_attack_well(Well)
<-
	.print("I was a builder, but there is an enemy well ",Well,", going to destroy it");
	!!become_attacker;
	.
+!build
	: select_random_facility(Facility)
<-	
	.print("Going to ",Facility," to explore");
	!action::goto(Facility);
	!build;
	.

// ### WHAT ATTACKERS DO ###
+team::enemyWell(Well,Lat,Lon,Type)
	:  not ::becoming_atacker & ::team_ready & attack::can_I_attack_well(Well)
<-	
	+::becoming_atacker;
	.print("Some teammate has discovered a well ",Well," at ",Lat," ",Lon," on ",Type,", becoming attacker");	
	.wait({+default::actionID(_)});
	!!become_attacker;
	-::becoming_atacker;
	.
-team::enemyWell(Well,_,_,_)
	: .desire(attack::dismantle_well(Well))
<-
	.print("I was going to dismantle ",Well,", but it's not necessary anymore");
	.wait({+default::actionID(_)});
	!!reconsider_attack(Well);
	.
canUpdateSkill 
:- 
	default::skill(Skill) & 
	default::role(drone,_,_,_,_,_,MaxSkill,_,_,_,_) & 
	(Skill < MaxSkill) & 
	default::upgrade(skill,Cost,_) & 
	default::massium(Massium) & 
	(Cost <= Massium)
	.
+!make_upgrade
	: canUpdateSkill & new::shopList(List) & rules::closest_facility(List,Facility)
<-
	.print("I'm going to make an upgrade at ",Facility);
	!action::goto(Facility);
	!action::upgrade(skill);
	!make_upgrade;
	.
+!make_upgrade.
-!make_upgrade[code(.fail(action(Action),result(Result)))]

<-
	.print("Action ",Action," failed because of ",Result);
	.
+!become_attacker
//	: not rules::am_I_winner & .my_name(Me) & default::play(Me,Role,g1) & ((Role==builder & not .desire(build::_)) | (Role==gatherer) | (Role==explorer_drone))
//	: not rules::am_I_winner & .my_name(Me) & default::play(Me,Role,g1) & ((Role==builder & not .desire(build::_) & not rules::enough_money) | (Role==gatherer))
//	: not rules::am_I_winner & .my_name(Me) & default::play(Me,Role,g1) & ((Role==super_explorer) | (Role==builder & not .desire(build::_) & not rules::enough_money))
	: not rules::am_I_winner & .my_name(Me) & default::play(Me,Role,g1) & ((Role==builder & not .desire(build::_) & not rules::enough_money) | (Role==gatherer) | (Role==super_explorer))
//	: not rules::am_I_winner & .my_name(Me) & default::play(Me,Role,g1) & (Role==gatherer)
<-
	.current_intention(intention(IntentionId,_));
	.print("Becoming attacker ",IntentionId);
	!change_role(Role,attacker);	
	!action::forget_old_action;	
	!::attack;	
	.
+!become_attacker.
+!reconsider_attack(Well)
	: .my_name(Me) & default::play(Me,attacker,g1) & .desire(attack::dismantle_well(Well)) & .desire(action::goto(_,_))
<-
	.print("Reconsidering attack");
	!action::forget_old_action;	
	!action::clean_route;
	!::attack;
	.
+!reconsider_attack(Well).
+!attack
	: ::should_become(super_explorer) & ::canUpdateSkill
<-
	.print("I was attacking but I had better to make an upgrade");
	!make_upgrade;
	!attack;
	.
+!attack
	: ::should_become(builder) & rules::enough_money
<-
	.print("I was attacking but I can build a well");
	!change_role(attacker,builder);
	!!go_back_to_work;
	.
+!attack
//	: team::enemyWell(Well,_,_,_) & attack::can_I_attack_well(Well)
	: team::enemyWell(Some,_,_,_) & .findall(Well,team::enemyWell(Well,Lat,Lon,_),Wells) & 	rules::closest_facility(Wells,Well)
//	: team::enemyWell(Some,_,_,_) & .findall(Well,team::enemyWell(Well,_,_,_),Wells) & .shuffle(Wells,ShuffleWells) & .nth(0,ShuffleWells,Well)
<-
	.print("I'm going to attack ",Well);
	!attack::dismantle_well(Well);
	removeEnemyWell(Well);
	!attack;
	.
+!attack
	: ::should_become(Role)
<-
	!change_role(attacker,Role);
	!!go_back_to_work;
	.
	
// ### WHAT DELIVERY AGENTS DO ###
+!perform_delivery
	: ::winner(JobId,Deliveries,DeliveryPoint)
<-
	.print("I won the tasks to ",Deliveries," at ",DeliveryPoint);	
	!delivery::delivery_job(JobId,Deliveries,DeliveryPoint);	
	-::winner(JobId,Deliveries,DeliveryPoint);	
	.print("I've finished my deliveries'");
	?::should_become(Role);
	!change_role(deliveryagent,Role);
	!!go_back_to_work;
	.
+!recover_delivery(JobId)
<-
	!action::forget_old_action;	
	!give_back_delivery;	
	-::winner(JobId,_,_);	
	?::should_become(Role);
	!change_role(deliveryagent,Role);
	!!go_back_to_work;
	.
+!give_back_delivery
	: default::hasItem(_,_) & strategies::centerStorage(Storage) 
<-
	.print("I'm carrying some items, going to store ");
	!stock::store_all_items(Storage);
	.
+!give_back_delivery
<-
	.print("I have to do nothing");
	.
	
// ### WHAT GATHERS DO ###
+!reconsider_gather
	: .my_name(Me) & default::play(Me,gatherer,g1) & .desire(action::goto(_,_))
<-
	.print("Reconsidering gather");
	!action::forget_old_action;
	!action::clean_route;
	!gather;
	.
+!reconsider_gather.
+!gather
	: rules::can_I_use_center_storage & default::load(Load) & default::maxLoad(Max) & (Load*2 > Max) & strategies::centerStorage(Storage)
<-	
	.print("Going to storage ",Storage," to store items");
	!action::goto(Storage);
	!stock::store_all_items(Storage);
	!gather;
	.
+!gather
	: rules::can_I_use_center_storage & rules::select_resource_node(SelectedResource) & .literal(SelectedResource)
<-
	!gather(SelectedResource);
	.
+!gather
	: select_random_facility(Facility)
<-	
	.print("No need to gather, going to ",Facility," to explore");
	!action::goto(Facility);
	!gather;
	.
+!gather(ResourceNode)
	: team::resNode(ResourceNode,Lat,Lon,Base)
<-
	.print("Going to resource node ",ResourceNode," to gather ",Base);
	!action::goto(Lat,Lon);
	!gather::gather_full(Base);
	!gather;
	.
	