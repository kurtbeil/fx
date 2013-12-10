//+------------------------------------------------------------------+
//|                                               Moving Average.mq4 |
//|                      Copyright � 2005, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+


#include <utility.mqh>
#include <common.mqh>
#include <CppUtility.mqh>

int init() {
	OnInitBegin(WindowExpertName());
	// 读取相关参数
	double d1 = ConfigGetDouble("bands_period1",-1);
	Print("d1=",d1);
	
	OnInitEnd();
}

int deinit(){	
	OnDeinitBegin();
	
	OnDeinitEnd();
}


void CheckForOpen(){
	// ... ... 
	Print("CheckForOpen() is called ,LotsSize=",GetLotSize());
	
}

void CheckForClose(){
	// ... ... 
	Print("CheckForClose() is called ");
}

void start()
{
	// 如果初始化失败，不进行任何动作
	if(!IsInitialized()) return;
	// start() begin 
	OnStartBegin();
	
	// 判断如果时间周期发生变化重新加载配置参数	

	
	if (GetTradingAllowed()){
		CheckForOpen();
	}
	CheckForClose();		
	
	// start() end    
	OnStartEnd();	
}  


