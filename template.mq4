//+------------------------------------------------------------------+
//|                                               Moving Average.mq4 |
//|                      Copyright � 2005, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+

#include <common.mqh>

int magic;

int a;
double b;
string c;
int d[24];

void LoadTradingConfig(){
	// ... 加载交易参数 ... 
	a = ConfigGetInt("a",100);
	b = ConfigGetDouble("b",100);
	c = ConfigGetString("c",100);
	int i;
	for(i=0; i<24; i++){
		d[i] = ConfigGetInt("d/"+i,100);
	}
	Print("a=",a);
	Print("b=",b);
	Print("c=",c);
	for(i=0; i<24; i++){
		Print("d[",i,"]=",d[i]);
	}	
}

void CheckForOpen(){
	// ... 开仓逻辑 ... 
	//Print("CheckForOpen() is called ,LotsSize=",GetLotSize());
	
}

void CheckForClose(){
	// ... 平仓逻辑 ... 
	//Print("CheckForClose() is called ");
}

int init() {
	Print("init is call");
	// 调用init()开始事件	
	OnInitBegin(WindowExpertName());
	magic = GetExecuteId();
	
	// 读取相关参数
	LoadTradingConfig();
	
	// 调用init()结束事件
	OnInitEnd();
}

int deinit(){	
    Print("deinit is call");
	// 调用deinit()开始事件
	OnDeinitBegin();
	
	// 调用deinit()结束事件
	OnDeinitEnd();
}

void start()
{	
	// 如果初始化失败，不进行任何动作
	if(!IsInitialized()) return;
		
	// 发送start()开始事件
	OnStartBegin();
	
	// 调用交易逻辑
	if (GetTradingAllowed()){
		CheckForOpen();
	}
	CheckForClose();			
	
	// 发送start()结束事件
	OnStartEnd();	
}  


