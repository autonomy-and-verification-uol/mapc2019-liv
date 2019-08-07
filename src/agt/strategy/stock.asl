// test plan, should be removed later on
+default::step(X)
	: X mod 100 = 0
<-
	!get_dispensers(List);
	.print(List);
	.

+!get_dispensers(List)
	: true
<-
	getDispensers(List);
	.