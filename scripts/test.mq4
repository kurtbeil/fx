

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
	CppCreateLimitOrder(Symbol(),OP_SELL,1.6,0.1,TimeCurrent());	
	Print("-------------test.start() end-------------------");
	OnStartEnd();		
}