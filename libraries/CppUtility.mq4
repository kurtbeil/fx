#property library

#include <common.mqh>

#import "CppUtility.dll"
// 全局变量
string GlobalStringGet(int ExecuteId,string name);
void GlobalStringSet(int ExecuteId,string name,string value);
// 执行标识符
int GenerateExecuteId();
// 限价单
int CreateLimitOrder(int ExecuteId,string symbol,int type,double price,double lots,int expdate,int createtime);
int GetLimitOrderCount(int ExecuteId);
int GetLimitOrderId(int ExecuteId);
string GetLimitOrderSymbol(int ExecuteId);
int GetLimitOrderType(int ExecuteId);
double GetLimitOrderPrice(int ExecuteId);
double GetLimitOrderLots(int ExecuteId);
double GetLimitOrderSlip(int ExecuteId);
int GetLimitOrderExpdate(int ExecuteId);
int GetLimitOrderCreateTime(int ExecuteId);
void RemoveLimitOrder(int ExecuteId);
void TurnLimitOrder(int ExecuteId);
// 配置数据读取
string PyConfigRead(string file,string var);



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
	int orderid = CreateLimitOrder(GetExecuteId(),symbol,type,price,lots,expdate,TimeCurrent());
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

int CppGetLimitOrderCreateTime() {
	return(GetLimitOrderCreateTime(GetExecuteId()));
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


int CppGetLimitOrderCountBy(string symbol,int  cmd) {
	int count = 0;
	int ordercnt = CppGetLimitOrderCount();	
	for(int i = 0; i < ordercnt; i++) {
		if (CppGetLimitOrderSymbol() ==  symbol && CppGetLimitOrderType() == cmd ){
			count++;
		}
		CppTurnLimitOrder();
	}		
	return (count);
}


int CppGetLastLimitOrderCrtTimeBy(string symbol,int  cmd) {
	datetime time = 0;
	int ordercnt = CppGetLimitOrderCount();	
	for(int i = 0; i < ordercnt; i++) {
		if (CppGetLimitOrderSymbol() ==  symbol && CppGetLimitOrderType() == cmd ){
			if (CppGetLimitOrderCreateTime() > time) time = CppGetLimitOrderCreateTime();
		}
		CppTurnLimitOrder();
	}		
	return (time);
}

// 读取py配置文件
string CppPyConfigRead(string file,string var){
	string result = PyConfigRead(file,var);
	return (result);
}

// 解析py配置返回字串中的类型字串
string CppPyResultReadType(string PyResult){
	int i = StringFind(PyResult,":",0);
	int j = StringFind(PyResult,",",0);		
    string type = StringSubstr(PyResult,i+1,j-i-1);
	return (type);
}

// 解析py配置返回字串中的具体值得字串
string CppPyResultReadValue(string PyResult){
	string result = StringTrimRight(PyResult);
	// 找到字符串中第2个":"的位置
	int i = StringFind(PyResult,":",0);
	i = StringFind(result,":",i+1);      
    // 找到结束"}"的位置
	int j = StringLen(result)-1;   
	string value = StringSubstr(result,i+1,j-i-1);
	return(value);
}

// 在配置数据中读取一个浮点数
double CppPyConfigReadDouble(string file,string var,double df){
	string pyresult = CppPyConfigRead(file,var);
	string type = CppPyResultReadType(pyresult);
	string value = CppPyResultReadValue(pyresult);
	double result = df;
	if ( type == "float" || type == "int" ) {
		result = StrToDouble(value);
	}else{		
		Print("read var : \""+var+"\""+" failed");		
		Print("default value : \"" + df + "\" is used");
		Print("file =\""+file+"\"");
	}
	return(result);
}

// 在配置数据中读取一个浮点数
int CppPyConfigReadInt(string file,string var,int df){
	string pyresult = CppPyConfigRead(file,var);
	string type = CppPyResultReadType(pyresult);
	string value = CppPyResultReadValue(pyresult);
	int result = df;
	if ( type == "int" ) {
		result = StrToInteger(value);
	}else{		
		Print("read var : \""+var+"\""+" failed");		
		Print("default value : \"" + df + "\" is used");
		Print("file =\""+file+"\"");
	}
	return(result);
}






