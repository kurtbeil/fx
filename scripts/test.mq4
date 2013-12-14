

#include <CppUtility.mqh>
#include <common.mqh>
#include <utility.mqh>
#property show_confirm


int init() {
	//OnInitBegin(WindowExpertName());
	return(0);
}

int deinit(){	
	//OnDeinitEnd();
}



int start() {	
	//Print("WindowExpertName=",WindowExpertName());
	//Print("StopOut level = ", AccountStopoutLevel());
	Print("STOPLEVEL= ", MarketInfo(Symbol(),MODE_STOPLEVEL));

}