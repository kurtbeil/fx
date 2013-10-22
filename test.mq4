//+------------------------------------------------------------------+
//|                                               Moving Average.mq4 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+


#include <utility.mqh>
#include <common.mqh>
#include <CppUtility.mqh>

int init() {
	OnInitBegin(WindowExpertName());
	
	double p1 = Ask-Point*50;
	double p2 = Bid+Point*50;
	
	CppCreateLimitOrder(Symbol(),OP_BUY,p1,0.1,TimeCurrent()+5*60);	
	CppCreateLimitOrder(Symbol(),OP_SELL,p2,0.1,TimeCurrent()+5*60);		
	
	return(0);
}

int deinit(){	
	OnDeinitEnd();
}

void start()
{
	OnStartBegin();
    // ...
	OnStartEnd();	
}  


