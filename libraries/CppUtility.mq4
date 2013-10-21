#property library

#include <common.mqh>

#import "CppUtility.dll"
string GlobalStringGet(int ExecuteId,string name);
void GlobalStringSet(int ExecuteId,string name,string value);
int GenerateExecuteId();
void CreateLimitOrder(int ExecuteId,string symbol,int type,double price,double lots,double slip,int expdate);
int GetLimitOrderCount(int ExecuteId);
string GetLimitOrderSymbol(int ExecuteId);
int GetLimitOrderType(int ExecuteId);
double GetLimitOrderPrice(int ExecuteId);
double GetLimitOrderLots(int ExecuteId);
double GetLimitOrderSlip(int ExecuteId);
int GetLimitOrderExpdate(int ExecuteId);
void RemoveLimitOrder(int ExecuteId);
void TurnLimitOrder(int ExecuteId);



// 生成ExecuteId
int CppGenerateExecuteId(){
	return(GenerateExecuteId());
}

// 设置和读取全局字符串变量
string CppGlobalStringGet(string name){
	return (GlobalStringGet(GetExecuteId(),name));	
}

void CppGlobalStringSet(string name,string value) {
	GlobalStringSet(GetExecuteId(),name,value);
}

// 近距离限价单功能的数据结构支持
void CppCreateLimitOrder(string symbol,int type,double price,double lots,double slip,int expdate){
	CreateLimitOrder(GetExecuteId(),symbol,type,price,lots,slip,expdate);
}

int CppGetLimitOrderCount(){
	return(GetLimitOrderCount(GetExecuteId()));
}

string CppGetLimitOrderSymbol(){
	return(GetLimitOrderSymbol(GetExecuteId()));
}

int CppGetLimitOrderType(){
	return(GetLimitOrderType(GetExecuteId()));
}

double CppGetLimitOrderPrice(){
	return(GetLimitOrderPrice(GetExecuteId()));
}

double CppGetLimitOrderLots(){
	return(GetLimitOrderLots(GetExecuteId()));
}

double CppGetLimitOrderSlip(){
	return(GetLimitOrderSlip(GetExecuteId()));
}

int CppGetLimitOrderExpdate(){
	return(GetLimitOrderExpdate(GetExecuteId()));
}

void CppRemoveLimitOrder(){
	RemoveLimitOrder(GetExecuteId());
}

void CppTurnLimitOrder(){
	TurnLimitOrder(GetExecuteId());
}




