#property library

#include <common.mqh>

#import "CppUtility.dll"
string GlobalStringGet(int ExecuteId,string name);
void GlobalStringSet(int ExecuteId,string name,string value);
int GenerateExecuteId();
int CreateLimitOrder(int ExecuteId,string symbol,int type,double price,double lots,int expdate);
int GetLimitOrderCount(int ExecuteId);
int GetLimitOrderId(int ExecuteId);
string GetLimitOrderSymbol(int ExecuteId);
int GetLimitOrderType(int ExecuteId);
double GetLimitOrderPrice(int ExecuteId);
double GetLimitOrderLots(int ExecuteId);
double GetLimitOrderSlip(int ExecuteId);
int GetLimitOrderExpdate(int ExecuteId);
void RemoveLimitOrder(int ExecuteId);
void TurnLimitOrder(int ExecuteId);



// 生成ExecuteId
int CppGenerateExecuteId() {
	return(GenerateExecuteId());
}

// 设置和读取全局字符串变量
string CppGlobalStringGet(string name) {
	return (GlobalStringGet(GetExecuteId(),name));
}

void CppGlobalStringSet(string name,string value) {
	GlobalStringSet(GetExecuteId(),name,value);
}

// 近距离限价单功能的数据结构支持
void CppCreateLimitOrder(string symbol,int type,double price,double lots,int expdate) {
	//  调用cpp库保存元素到队列
	int orderid = CreateLimitOrder(GetExecuteId(),symbol,type,price,lots,expdate);
	//  在图表上标注
	string objectname = GetExecuteId() + "#LimitOrder#" + orderid;
	ObjectCreate(objectname, OBJ_HLINE, 0, 0,price);
	if(type==OP_BUY) {
		ObjectSet(objectname,OBJPROP_COLOR,Blue);
	}
	if(type==OP_SELL) {
		ObjectSet(objectname,OBJPROP_COLOR,Red);
	}
	ObjectSet(objectname,OBJPROP_STYLE, STYLE_DASHDOTDOT);
}

int CppGetLimitOrderCount() {
	return(GetLimitOrderCount(GetExecuteId()));
}

int CppGetLimitOrderId() {
	return(GetLimitOrderId(GetExecuteId()));
}

string CppGetLimitOrderSymbol() {
	return(GetLimitOrderSymbol(GetExecuteId()));
}

int CppGetLimitOrderType() {
	return(GetLimitOrderType(GetExecuteId()));
}

double CppGetLimitOrderPrice() {
	return(GetLimitOrderPrice(GetExecuteId()));
}

double CppGetLimitOrderLots() {
	return(GetLimitOrderLots(GetExecuteId()));
}

double CppGetLimitOrderSlip() {
	return(GetLimitOrderSlip(GetExecuteId()));
}

int CppGetLimitOrderExpdate() {
	return(GetLimitOrderExpdate(GetExecuteId()));
}

void CppRemoveLimitOrder() {
	int orderid = CppGetLimitOrderId() ;
	if (orderid != -1) {
		//  删除队列中的挂单数据
		RemoveLimitOrder(GetExecuteId());
		//  在图表上删除挂单标志
		string objectname = GetExecuteId() + "#LimitOrder#" + orderid;
		ObjectDelete(objectname);
	}
}

void CppTurnLimitOrder() {
	TurnLimitOrder(GetExecuteId());
}




