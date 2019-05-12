{begin namespace(lNewRound, global)}

+!add_initiator_beliefs
	: true
<-
	+initiator::max_bid_time(2000);
	+initiator::max_bidders(28);	
	+metrics::money(0);
	+metrics::completedJobs(0);
	+metrics::failedJobs(0);
	+metrics::failedFreeJobs(0);
	+metrics::completedAuctions(0);
	+metrics::failedAuctions(0);
	+metrics::lostAuctions(0);
	+metrics::completedMissions(0);
	+metrics::failedMissions(0);
	+metrics::finePaid(0);
	+metrics::failedEvalJobs(0);
	+metrics::noBids(0);
	+metrics::missBidAuction(0);
	.
{end}

{begin namespace(new, global)}

+!new_round
	: .my_name(Me)
<-
	+chargingList([]);
	+dumpList([]);
	+storageList([]);
	+shopList([]);
	+workshopList([]);
	+resourceList([]);
		
	+noActionCount(0);
	
	+metrics::noAction(0);
	+metrics::jobHaveWorked(0);
	+metrics::next_actions(0);
	+metrics::jobHaveFailed(0);
	+metrics::missionHaveFailed(0);
	+metrics::auctionHaveFailed(0);
	
	+action::current_token(0);
	
	+explore::n_steps(0);
	+explore::n_walks(0);
	
	+explore::vLat(0);
	+explore::vLon(0);
	+explore::vVolta(0);
	
	+delivery::current_load_item([],0);
	+delivery::current_load([],0);
	
	+strategies::noActionCount(0);
	
	if (Me == vehicle1) { !lNewRound::add_initiator_beliefs; }
	setReady;
	.

@shopList[atomic]
+default::shop(ShopId, Lat, Lon)
	: shopList(List) & not .member(ShopId,List)
<-
	-+shopList([ShopId|List]);
	.

@storageListInit[atomic]
+default::storage(StorageId, Lat, Lon, TotCap, UsedCap, Items)
	: .my_name(vehicle1) & storageList(List) & not .member(StorageId,List)
<-
	createAvailableList(StorageId);
	-+storageList([StorageId|List]);
	.
@storageList[atomic]
+default::storage(StorageId, Lat, Lon, TotCap, UsedCap, Items)
	: storageList(List) & not .member(StorageId,List)
<-
	-+storageList([StorageId|List]);
	.

@chargingList[atomic]
+default::chargingStation(ChargingId,Lat,Lon,Rate) 
	:  chargingList(List) & not .member(ChargingId,List)
<-
	-+chargingList([ChargingId|List]);
	.
@chargingList2[atomic]
+default::chargingStation(ChargingId,Lat,Lon,Rate) 
	:  chargingList(List) & not .member(ChargingId,List) 
<-
	-+chargingList([ChargingId|List]);
	.

	
@workshopList[atomic]
+default::workshop(WorkshopId,Lat,Lon) 
	:  workshopList(List) & not .member(WorkshopId,List)
<- 
	-+workshopList([WorkshopId|List]);
	.

@dumpList[atomic]
+default::dump(DumpId,Lat,Lon) 
	:  dumpList(List) & not .member(DumpId,List)
<- 
	-+dumpList([DumpId|List]);
	.
	
@resource[atomic]
+default::resourceNode(NodeId,Lat,Lon,Item)
	: not team::resNode(NodeId,Lat,Lon,Item)
<-
	addResourceNode(NodeId,Lat,Lon,Item);
	.
	
//@resourceList[atomic]
//+team::resNode(NodeId,Lat,Lon,Item)
//	: resourceList(List) & not .member(NodeId,List)
//<- 
//	.print("New resource node: ",NodeId," for item: ",Item);
//	-+resourceList([NodeId|List]);
//	.
	
{end}