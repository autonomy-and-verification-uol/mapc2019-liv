+!new_round
	: .my_name(Me)
<-
	+action::current_token(0);
	+identification::identified([]);
	+map::myMap(Me);
	+identification::count(0);
	!common::update_role_to(explorer);
	//+exploration::explorer;
//	+stop::stop;
	.