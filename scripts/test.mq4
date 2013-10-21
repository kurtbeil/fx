

#include <CppUtility.mqh>
#include <common.mqh>
#include <utility.mqh>
#property show_confirm


int init() {
	OnInitBegin(WindowExpertName());
	return(0);
}

int deinit(){	
	OnDeinitEnd();
}

int start() {	
	OnStartBegin();
	Print("-------------test.start() begin-----------------");
	CppCreateLimitOrder(Symbol(),OP_SELL,Bid,0.1,GetDefaulSlipPoints(Symbol()),TimeCurrent());
	Print("-------------test.start() end-------------------");
	OnStartEnd();	
}