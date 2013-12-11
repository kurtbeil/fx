#property library

#include <CppUtility.mqh>
#include <testlib.mqh>
#include <common.mqh>


void test_GlobalString(){
	
	
}


void test_LimitOrder(){	
	string symbol1 = "Symbol1",symbol2 = "Symbol2",symbol3 = "Symbol3";
	double p1=1.40101,p2=2.40101,p3=3.40101;
	datetime time1 = TimeCurrent(),time2 = TimeCurrent(),time3 = TimeCurrent();
	int ot1 = OP_BUY,ot2=OP_BUY,ot3 = OP_SELL;
	double l1=1,l2=0.1,l3=0.01;	
	
	CppCreateLimitOrder(symbol1,ot1,p1,l1,time1);	
	CppCreateLimitOrder(symbol2,ot2,p2,l2,time2);
	CppCreateLimitOrder(symbol3,ot3,p3,l3,time3);
	assertIntEqual("test_LimitOrder",CppGetLimitOrderCount(),3);	
	assertStringEqual("test_LimitOrder",CppGetLimitOrderSymbol(),symbol1);
	assertIntEqual("test_LimitOrder",CppGetLimitOrderType(),ot1);		
	assertDoubleEqual("test_LimitOrder",CppGetLimitOrderPrice(),p1);	
	assertDoubleEqual("test_LimitOrder",CppGetLimitOrderLots(),l1);		
	assertIntEqual("test_LimitOrder",CppGetLimitOrderExpdate(),time1);			
	CppTurnLimitOrder();
	assertIntEqual("test_LimitOrder",CppGetLimitOrderCount(),3);	
	assertStringEqual("test_LimitOrder",CppGetLimitOrderSymbol(),symbol2);
	assertIntEqual("test_LimitOrder",CppGetLimitOrderType(),ot2);		
	assertDoubleEqual("test_LimitOrder",CppGetLimitOrderPrice(),p2);	
	assertDoubleEqual("test_LimitOrder",CppGetLimitOrderLots(),l2);		
	assertIntEqual("test_LimitOrder",CppGetLimitOrderExpdate(),time2);			
	CppRemoveLimitOrder();
	assertIntEqual("test_LimitOrder",CppGetLimitOrderCount(),2);	
	assertStringEqual("test_LimitOrder",CppGetLimitOrderSymbol(),symbol3);
	assertIntEqual("test_LimitOrder",CppGetLimitOrderType(),ot3);	
	assertDoubleEqual("test_LimitOrder",CppGetLimitOrderPrice(),p3);	
	assertDoubleEqual("test_LimitOrder",CppGetLimitOrderLots(),l3);		
	assertIntEqual("test_LimitOrder",CppGetLimitOrderExpdate(),time3);			
	CppRemoveLimitOrder();
	assertIntEqual("test_LimitOrder",CppGetLimitOrderCount(),1);	
	assertStringEqual("test_LimitOrder",CppGetLimitOrderSymbol(),symbol1);
	assertIntEqual("test_LimitOrder",CppGetLimitOrderType(),ot1);	
	assertDoubleEqual("test_LimitOrder",CppGetLimitOrderPrice(),p1);	
	assertDoubleEqual("test_LimitOrder",CppGetLimitOrderLots(),l1);		
	assertIntEqual("test_LimitOrder",CppGetLimitOrderExpdate(),time1);			
	CppRemoveLimitOrder();
	assertIntEqual("test_LimitOrder",CppGetLimitOrderCount(),0);	
	assertStringEqual("test_LimitOrder",CppGetLimitOrderSymbol(),"");
	assertIntEqual("test_LimitOrder",CppGetLimitOrderType(),-1);	
	assertDoubleEqual("test_LimitOrder",CppGetLimitOrderPrice(),-1);	
	assertDoubleEqual("test_LimitOrder",CppGetLimitOrderLots(),-1);	
	assertIntEqual("test_LimitOrder",CppGetLimitOrderExpdate(),-1);	
	CppRemoveLimitOrder();
	assertIntEqual("test_LimitOrder",CppGetLimitOrderCount(),0);	
	assertStringEqual("test_LimitOrder",CppGetLimitOrderSymbol(),"");
	assertIntEqual("test_LimitOrder",CppGetLimitOrderType(),-1);	
	assertDoubleEqual("test_LimitOrder",CppGetLimitOrderPrice(),-1);	
	assertDoubleEqual("test_LimitOrder",CppGetLimitOrderLots(),-1);	
	assertIntEqual("test_LimitOrder",CppGetLimitOrderExpdate(),-1);		
	CppTurnLimitOrder();
	assertIntEqual("test_LimitOrder",CppGetLimitOrderCount(),0);	
	assertStringEqual("test_LimitOrder",CppGetLimitOrderSymbol(),"");
	assertIntEqual("test_LimitOrder",CppGetLimitOrderType(),-1);	
	assertDoubleEqual("test_LimitOrder",CppGetLimitOrderPrice(),-1);	
	assertDoubleEqual("test_LimitOrder",CppGetLimitOrderLots(),-1);	
	assertIntEqual("test_LimitOrder",CppGetLimitOrderExpdate(),-1);	
	
}


//   测试读取配置
int test_PyCconfigRead(){
	string file = TerminalPath( ) + "\\experts\\config\\pycfg\\test.py";		
	
	string config = CppPyConfigReadFile(file);
	//Print("config=",config);
	
	string bands_period = CppPyReadDictValueStr(config,"HF Markets Ltd/Micro/EURCAD/M1/bands_period");
	//Print("bands_period=",bands_period);
	assertIntEqual("test_PyCconfigRead(1)",StrToInteger(bands_period),20);	
	
	string bands_period_type = CppPyReadDictValueType(config,"HF Markets Ltd/Micro/EURCAD/M1/bands_period");
	//Print("bands_period_type=",bands_period_type);
	assertStringEqual("test_PyCconfigRead(2)",bands_period_type,"int");	
	
	string bands_deviation = CppPyReadDictValueStr(config,"HF Markets Ltd/Micro/EURCAD/M1/bands_deviation");
	//Print("bands_deviation=",bands_deviation);
	assertIntEqual("test_PyCconfigRead(3)",StrToInteger(bands_deviation),2);	
	
	string long_trading_hours_type = CppPyReadDictValueType(config,"HF Markets Ltd/Micro/EURCAD/M1/long_trading_hours");
	//Print("long_trading_hours=",long_trading_hours);
	assertStringEqual("test_PyCconfigRead(4)",long_trading_hours_type,"dict");	
	
	string long_trading_hours_10 = CppPyReadDictValueStr(config,"HF Markets Ltd/Micro/EURCAD/M1/long_trading_hours/10");
	//Print("long_trading_hours_10=",long_trading_hours_10);
	assertIntEqual("test_PyCconfigRead(5)",StrToInteger(long_trading_hours_10),0);	
	
	string long_trading_hours_23 = CppPyReadDictValueStr(config,"HF Markets Ltd/Micro/EURCAD/M1/long_trading_hours/23");
	//Print("long_trading_hours_23=",long_trading_hours_23);
	assertIntEqual("test_PyCconfigRead(6)",StrToInteger(long_trading_hours_23),1);	
}


//   Python 的服务器访问
int test_PyCallService(){
	
	// 这时个一定存在的帐户
	string response = CppPyExpertRegister("Scalping","100646","HF Markets Ltd","HFMarkets-Live Server");
	//Print("response=",response);
		
	string errcode = CppPyReadDictValueType(response,"errcode");
	//Print("errcode=",errcode);
	assertStringEqual("test_PyServiceAcesss(1)",StrToInteger(errcode),0);	
	
	string errmsg_type = CppPyReadDictValueType(response,"errmsg");
	//Print("errmsg=",errmsg);
	assertStringEqual("test_PyServiceAcesss(2)",errmsg_type,"unicode");	
	
	string ExpertInstanceId_type = CppPyReadDictValueType(response,"data/ExpertInstanceId");
	//Print("ExpertInstanceId=",ExpertInstanceId);
	assertStringEqual("test_PyServiceAcesss(3)",ExpertInstanceId_type,"int");	
	
	string TradingAllowed_type = CppPyReadDictValueType(response,"data/TradingAllowed");
	//Print("TradingAllowed=",TradingAllowed);
	assertStringEqual("test_PyServiceAcesss(4)",TradingAllowed_type,"bool");		
	
	string Token_type = CppPyReadDictValueType(response,"data/Token");
	//Print("Token=",Token);
	assertStringEqual("test_PyServiceAcesss(5)",Token_type,"unicode");	
	
	string AccountTypeName_type = CppPyReadDictValueType(response,"data/AccountTypeName");
	//Print("AccountTypeName=",AccountTypeName);
	assertStringEqual("test_PyServiceAcesss(6)",AccountTypeName_type,"unicode");	
		
	string LotSize_type = CppPyReadDictValueType(response,"data/LotSize");
	//Print("LotSize=",LotSize);
	assertStringEqual("test_PyServiceAcesss(7)",LotSize_type,"float");	
}


int test_CppUtility() {
	Print("-----------test_CppUtility begin-----------");
	test_LimitOrder();
	test_PyCconfigRead();
	test_PyCallService();
	printAssertResul();
	Print("-----------test_CppUtility end------------");
}


