#property library

#include <CppUtility.mqh>
#include <utility.mqh>


int GetExecuteId() {
	//return(GlobalVariableGet("ExecuteId"));
	return(StrToInteger(ObjectDescription("ExecuteId")));
}


int SetExecuteId(int ExecuteId) {
	// 是在没有办法由于 MQL4 的全局变量在不同的文件里调用有不同的拷贝,导致无法将ExecuteId存放在一个普通的全局变量中,
	// 使用GlobalVariableGet 也达不到目的因为该变量的范围是整个MT4程序的所有窗口
	// 使用Cpp库也解决不了这个问题，因为调用Cpp库首先要解决唯一调用标识的问题
	// 所有最终的解决方法,使用MQL4是的Object相关函数,这样的解决方法并不干净,其他EA和Indicator可能会对此造成干扰,在界面上
	// 也存在删除这个对象的可能，但没有办法这是目前知道的唯一解决办法。	
	ObjectCreate("ExecuteId", OBJ_LABEL, 0, 0, 0);
	ObjectSetText("ExecuteId",DoubleToStr(ExecuteId,0) , 10, "Times New Roman", Red);
	ObjectSet("ExecuteId", OBJPROP_YDISTANCE, 15);
	ObjectSet("ExecuteId", OBJPROP_XDISTANCE, 5);
}



// ****************************    注意  *******************************
// ***** 该函数已弃用目前使用Python调用服务段程序生成这个ID，确保绝对不会重复 
// ****************************    注意  *******************************
void GenerateExecuteId() {
	// 目前暂用系统时间作为ExecuteId这存在重复的可能性
	// 该方法基于考虑:在同一秒时间内同时在一个客户端内执行两个不同的EA或者指标的可能性几乎为0
	// 但在不同的交易平台偶然出现出现重复，但是由于ExecuteId主要是在调用c语言的dll中对调用者做区分，
	// 在不同交易终端中使用的dll一定是不同的，所以不存在这个问题
	// ExecuteId主要还是解决同一个终端中的不同EA实例之间的冲突问题
	// 用系统时间作为ExecuteId不是一个十分严密的方法，但是为了能用和OrderMagicNumber关联起来，
	// 只能保留期32为整型数的类型（如果扩展类型长度我们能保证这个不重复），
	// 所以系统时间（到秒）可能是一个比较合适的选择。

	/*
	该方法存在的问题主要是一旦周末系统关闭，市场时间停留在关闭前一刻，如果此时正好操作挂多个EA，则ExecuteId重复
	int ExecuteId = 0;
	ExecuteId  += Month() * 100000000;
	ExecuteId  += Day()  * 1000000;
	ExecuteId  += Hour() * 10000;
	ExecuteId  += Minute() * 100;
	ExecuteId  += Seconds() ;
	*/

	// 使用windows的系统时间做为ExecuteId
	int ExecuteId = 0;
	ExecuteId = CppGenerateExecuteId();
	// 是在没有办法由于 MQL4 的全局变量在不同的文件里调用有不同的拷贝,导致无法将ExecuteId存放在一个普通的全局变量中,
	// 使用GlobalVariableGet 也达不到目的因为该变量的范围是整个MT4程序的所有窗口
	// 使用Cpp库也解决不了这个问题，因为调用Cpp库首先要解决唯一调用标识的问题
	// 所有最终的解决方法,使用MQL4是的Object相关函数,这样的解决方法并不干净,其他EA和Indicator可能会对此造成干扰,在界面上
	// 也存在删除这个对象的可能，但没有办法这是目前知道的唯一解决办法。
	ObjectCreate("ExecuteId", OBJ_LABEL, 0, 0, 0);
	ObjectSetText("ExecuteId",DoubleToStr(ExecuteId,0) , 10, "Times New Roman", Red);
	ObjectSet("ExecuteId", OBJPROP_YDISTANCE, 15);
	ObjectSet("ExecuteId", OBJPROP_XDISTANCE, 5);
}


void SetMainExpertName(string MainExpertName) {
	CppGlobalStringSet("MainExpertName",MainExpertName);
}

string GetMainExpertName() {
	return(CppGlobalStringGet("MainExpertName"));
}

void SetTradingAllowed(bool TradingAllowed){
	if (TradingAllowed){
		CppGlobalStringSet("TradingAllowed","True");
	}else{
		CppGlobalStringSet("TradingAllowed","False");
	}
}

bool GetTradingAllowed(){
	string TradingAllowed = CppGlobalStringGet("TradingAllowed");
	if (TradingAllowed=="True") {
		return(true);
	}else{
		return(false);
	}	
}

void SetAccountTypeName(string AccountTypeName){	
	CppGlobalStringSet("AccountTypeName",AccountTypeName);
}

string GetAccountTypeName(){	
	return(CppGlobalStringGet("AccountTypeName"));
}


void SetLotSize(double LotSize){
	CppGlobalStringSet("LotSize",DoubleToStr(LotSize,5));
}

double GetLotSize(){
	return(StrToDouble(CppGlobalStringGet("LotSize")));
}

void SetToken(string Token){
	CppGlobalStringSet("Token",Token);
}


string GetToken(){
	return (CppGlobalStringGet("Token"));
}


bool Initialized = false;
bool IsInitialized(){
	return (Initialized);
}


string PeriodName(){
	string result = "unknown";
	int period = Period();
	if (period == 1)  			result = "M1";
	if (period == 5)  			result = "M5";
	if (period == 15)  		result = "M15";
	if (period == 30)  		result = "M30";
	if (period == 60)  		result = "H1";
	if (period == 240)  		result = "H4";
	if (period == 1440)  		result = "D1";
	if (period == 10080) 	result = "W1";
	if (period == 43200) 	result = "MN";	
	return (result);
}


double ConfigGetDouble(string path,double df){
	double result;
	string fullpath = AccountCompany() +"/" + GetAccountTypeName() + "/" + Symbol() + "/" + PeriodName()+ "/" + path;
	string config = CppGlobalStringGet("config");
	string value = CppPyReadDictValueStr(config,fullpath);
	string type = CppPyReadDictValueType(config,fullpath);
	if ( value == "None" || ( type != "float" && type != "int" ) ){
		Print("ConfigGetDouble(\"" + fullpath+ "\") : fail! default value \"" + df + "\"  is used ");
		result = df;
	}else{
		result = StrToDouble(value);
	}
	return (result);
}

int ConfigGetInt(string path,int df){
	int result;
	string fullpath = AccountCompany() +"/" + GetAccountTypeName() + "/" + Symbol() + "/" + PeriodName()+ "/" + path;
	string config = CppGlobalStringGet("config");
	string value = CppPyReadDictValueStr(config,fullpath);
	string type = CppPyReadDictValueType(config,fullpath);
	if ( value == "None" || ( type != "int" ) ){
		Print("ConfigGetInt(\"" + fullpath+ "\") : fail! default value \"" + df + "\"  is used ");
		result = df;
	}else{
		result = StrToInteger(value);
	}
	return (result);
}

string ConfigGetString(string path,string df){
	string result;
	string fullpath = AccountCompany() +"/" + GetAccountTypeName() + "/" + Symbol() + "/" + PeriodName()+ "/" + path;
	string config = CppGlobalStringGet("config");
	string value = CppPyReadDictValueStr(config,fullpath);
	string type = CppPyReadDictValueType(config,fullpath);
	if (  type != "unicode" && type != "str" ){
		//Print("type=",type);
		Print("ConfigGetString(\"" + fullpath+ "\") : fail! default value \"" + df + "\"  is used ");
		result = df;
	}else{
		result = value;
	}
	return (result);
}


void OnInitBegin(string MainExpertName) {	
	
	//*********************************************************************************//
	//                                                   向服务器发送请求并保存相关信息                                             *//
	//*********************************************************************************//
	//Print("MainExpertName=",MainExpertName);
	// 调用expert注册服务
	string response = CppPyExpertRegister(MainExpertName,AccountNumber(),AccountCompany(),AccountServer());
	response = CppPyExpertRegister(MainExpertName,AccountNumber(),AccountCompany(),AccountServer());
	//Print("response=",response);
	string errcode = CppPyReadDictValueStr(response,"errcode");	
	//Print("errcode=",errcode);
	// 读取返回值
	if (errcode != "0") {
		// 初始化失败 ... ...
		Print("initial operation fail(1)");
		return;
	}
	
	// 读取ExecuteId
	string ExecuteId = CppPyReadDictValueStr(response,"data/ExpertInstanceId");
	string ExecuteId_t = CppPyReadDictValueType(response,"data/ExpertInstanceId");
	if ( ExecuteId == "None" || ExecuteId_t != "int" ){
		// 初始化失败 ... ... 
		Print("initial operation fail(2)");
		return;
	}	
	SetExecuteId(StrToInteger(ExecuteId));
	
	// *********************************** 注意 ******************************************
	// 在SetExecuteId(StrToInteger(ExecuteId)); 之前 CppGlobalStringSet 和 CppGlobalStringGet是无法调用的     * 
	// 所以之前是不能调用SetMainExpertName                                                                                          *
	// *********************************** 注意 ******************************************
	SetMainExpertName(MainExpertName);
	
	// 检查帐号是否允许交易
	string  TradingAllowed = CppPyReadDictValueStr(response,"data/TradingAllowed");
	string  TradingAllowed_t = CppPyReadDictValueType(response,"data/TradingAllowed");
	if ( TradingAllowed == "None" || TradingAllowed_t != "bool" ){
		// 初始化失败 ... ... 
		Print("initial operation fail(3)");
		return;
	}
	if (TradingAllowed == "True"){
		SetTradingAllowed(true);
	}else{
		SetTradingAllowed(false);
	}	
	
	// 读取帐号类型
	string  AccountTypeName = CppPyReadDictValueStr(response,"data/AccountTypeName");
	string  AccountTypeName_t = CppPyReadDictValueType(response,"data/AccountTypeName");
	if ( StringLen(AccountTypeName) ==0 ||AccountTypeName_t != "unicode" ){
		// 初始化失败 ... ... 
		Print("initial operation fail(4)");
		return;
	}
	SetAccountTypeName(AccountTypeName);
		
	// 读取头寸大小
	string  LotSize = CppPyReadDictValueStr(response,"data/LotSize");
	string  LotSize_t = CppPyReadDictValueType(response,"data/LotSize"); 
	if ( LotSize == "None" || ( LotSize_t != "float" && LotSize_t != "int" )){
		// 初始化失败 ... ... 
		Print("initial operation fail(5)");
		return;
	}
	SetLotSize(StrToDouble(LotSize));
	
	// 读取用于向服务器发送状态报告的令牌
	string  Token = CppPyReadDictValueStr(response,"data/Token");
	string  Token_t = CppPyReadDictValueType(response,"data/Token"); 
	if ( Token == "None" || Token_t != "unicode" ){
		// 初始化失败 ... ... 
		Print("initial operation fail(6)");
		return;
	}
	//Print("Token=",Token);
	
	SetToken(Token);		
	
	//*********************************************************************************//
	//                                                   读取配置文件存储在存储中                                                       *//
	//*********************************************************************************//
	string filename = TerminalPath( ) + "\\experts\\config\\pycfg\\" + MainExpertName + ".py";		
	string config = CppPyConfigReadFile(filename);		
	CppGlobalStringSet("config",config);
	
	// 初始化成功
	Initialized = true;	
}


// 近距离限价单过程
void ProcessLimitOrder() {
	int count = CppGetLimitOrderCount() ;
	for(int i = 0; i < count; i++) {
		int ticket = 0;
		if ( (Ask <= CppGetLimitOrderPrice() && CppGetLimitOrderType() == OP_BUY ) ||
		        (Bid >= CppGetLimitOrderPrice() && CppGetLimitOrderType() == OP_SELL )) {
			ticket = CreatePosition(CppGetLimitOrderSymbol(),CppGetLimitOrderType(),CppGetLimitOrderLots());
		}
		if ( ticket > 0  || TimeCurrent() > CppGetLimitOrderExpdate()) {
			// 创建成功或者已经超时
			CppRemoveLimitOrder();
		} else {
			// 创建失败将当前订单放至队尾，待下次重试
			CppTurnLimitOrder();
		}
	}
}

// 我们希望增加以下函数来为EA增加诸如导出数据的能力，但是如果是调用者是指标而不是EA要怎么处理?

void OnInitEnd() {

}


void OnStartBegin() {

}

void OnStartEnd() {
	ProcessLimitOrder();
}




void OnDeinitBegin() {

}

void OnDeinitEnd() {
	//  删除所有挂单
	int count = CppGetLimitOrderCount() ;
	for(int i = 0; i < count; i++) {
		CppRemoveLimitOrder();
	}		
	//  删除服务器上Expert实例
	Print("GetExecuteId()=",GetExecuteId());
	Print("GetToken()=",GetToken());
	string result = CppPyExpertUnregister(GetExecuteId(),GetToken());
	Print(result);
	
	//  删除调用标识
	ObjectDelete("ExecuteId");
}