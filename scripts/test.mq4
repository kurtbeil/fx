

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
	string file = "I:\\Program Files\\HotForex MetaTrader\\experts\\config\\pycfg\\Scalping.py";
	string var = "HF Markets Ltd/Micro/EURCAD/M1/bands_period";
	
	//   测试读取配置
	string config = CppPyConfigReadFile(file);
	Print("config=",config);
	
	string bands_period = CppPyReadDictValueStr(config,"HF Markets Ltd/Micro/EURCAD/M1/bands_period");
	Print("bands_period=",bands_period);
	
	string bands_period_type = CppPyReadDictValueType(config,"HF Markets Ltd/Micro/EURCAD/M1/bands_period");
	Print("bands_period_type=",bands_period_type);
	
	string bands_deviation = CppPyReadDictValueStr(config,"HF Markets Ltd/Micro/EURCAD/M1/bands_deviation");
	Print("bands_deviation=",bands_deviation);
	
	string long_trading_hours = CppPyReadDictValueStr(config,"HF Markets Ltd/Micro/EURCAD/M1/long_trading_hours");
	Print("long_trading_hours=",long_trading_hours);
	
	string long_trading_hours_10 = CppPyReadDictValueStr(config,"HF Markets Ltd/Micro/EURCAD/M1/long_trading_hours/10");
	Print("long_trading_hours_10=",long_trading_hours_10);
	
	string long_trading_hours_23 = CppPyReadDictValueStr(config,"HF Markets Ltd/Micro/EURCAD/M1/long_trading_hours/23");
	Print("long_trading_hours_23=",long_trading_hours_23);
	
	
	// 测试在服务器上注册
	string response = CppPyExpertRegistr("Scalping(rb3)","100646","HF Markets Ltd","HFMarkets-Live Server");
	Print("response=",response);
		
	string errcode = CppPyReadDictValueStr(response,"errcode");
	Print("errcode=",errcode);
	
	string errmsg = CppPyReadDictValueStr(response,"errmsg");
	Print("errmsg=",errmsg);
	
	string ExpertInstanceId = CppPyReadDictValueStr(response,"data/ExpertInstanceId");
	Print("ExpertInstanceId=",ExpertInstanceId);
	
	string TradingAllowed = CppPyReadDictValueStr(response,"data/TradingAllowed");
	Print("TradingAllowed=",TradingAllowed);
	
	string TradingAllowedType = CppPyReadDictValueType(response,"data/TradingAllowed");
	Print("TradingAllowedType=",TradingAllowedType);
	
	string Token = CppPyReadDictValueStr(response,"data/Token");
	Print("Token=",Token);
	
	string AccountTypeName = CppPyReadDictValueStr(response,"data/AccountTypeName");
	Print("AccountTypeName=",AccountTypeName);
		
	string LotSize = CppPyReadDictValueStr(response,"data/LotSize");
	Print("LotSize=",LotSize);
	
	
	
	
	
	
	
		
}