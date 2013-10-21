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
	double s1=0.001,s2=0.0001,s3=0.00001;
	
	CppCreateLimitOrder(symbol1,ot1,p1,l1,s1,time1);	
	CppCreateLimitOrder(symbol2,ot2,p2,l2,s2,time2);
	CppCreateLimitOrder(symbol3,ot3,p3,l3,s3,time3);
	assertIntEqual("test_LimitOrder",CppGetLimitOrderCount(),3);	
	assertStringEqual("test_LimitOrder",CppGetLimitOrderSymbol(),symbol1);
	assertIntEqual("test_LimitOrder",CppGetLimitOrderType(),ot1);		
	assertDoubleEqual("test_LimitOrder",CppGetLimitOrderPrice(),p1);	
	assertDoubleEqual("test_LimitOrder",CppGetLimitOrderLots(),l1);	
	assertDoubleEqual("test_LimitOrder",CppGetLimitOrderSlip(),s1);	
	assertIntEqual("test_LimitOrder",CppGetLimitOrderExpdate(),time1);			
	CppTurnLimitOrder();
	assertIntEqual("test_LimitOrder",CppGetLimitOrderCount(),3);	
	assertStringEqual("test_LimitOrder",CppGetLimitOrderSymbol(),symbol2);
	assertIntEqual("test_LimitOrder",CppGetLimitOrderType(),ot2);		
	assertDoubleEqual("test_LimitOrder",CppGetLimitOrderPrice(),p2);	
	assertDoubleEqual("test_LimitOrder",CppGetLimitOrderLots(),l2);	
	assertDoubleEqual("test_LimitOrder",CppGetLimitOrderSlip(),s2);	
	assertIntEqual("test_LimitOrder",CppGetLimitOrderExpdate(),time2);			
	CppRemoveLimitOrder();
	assertIntEqual("test_LimitOrder",CppGetLimitOrderCount(),2);	
	assertStringEqual("test_LimitOrder",CppGetLimitOrderSymbol(),symbol3);
	assertIntEqual("test_LimitOrder",CppGetLimitOrderType(),ot3);	
	assertDoubleEqual("test_LimitOrder",CppGetLimitOrderPrice(),p3);	
	assertDoubleEqual("test_LimitOrder",CppGetLimitOrderLots(),l3);	
	assertDoubleEqual("test_LimitOrder",CppGetLimitOrderSlip(),s3);	
	assertIntEqual("test_LimitOrder",CppGetLimitOrderExpdate(),time3);			
	CppRemoveLimitOrder();
	assertIntEqual("test_LimitOrder",CppGetLimitOrderCount(),1);	
	assertStringEqual("test_LimitOrder",CppGetLimitOrderSymbol(),symbol1);
	assertIntEqual("test_LimitOrder",CppGetLimitOrderType(),ot1);	
	assertDoubleEqual("test_LimitOrder",CppGetLimitOrderPrice(),p1);	
	assertDoubleEqual("test_LimitOrder",CppGetLimitOrderLots(),l1);	
	assertDoubleEqual("test_LimitOrder",CppGetLimitOrderSlip(),s1);	
	assertIntEqual("test_LimitOrder",CppGetLimitOrderExpdate(),time1);			
	CppRemoveLimitOrder();
	assertIntEqual("test_LimitOrder",CppGetLimitOrderCount(),0);	
	assertStringEqual("test_LimitOrder",CppGetLimitOrderSymbol(),"");
	assertIntEqual("test_LimitOrder",CppGetLimitOrderType(),-1);	
	assertDoubleEqual("test_LimitOrder",CppGetLimitOrderPrice(),-1);	
	assertDoubleEqual("test_LimitOrder",CppGetLimitOrderLots(),-1);	
	assertDoubleEqual("test_LimitOrder",CppGetLimitOrderSlip(),-1);	
	assertIntEqual("test_LimitOrder",CppGetLimitOrderExpdate(),-1);	
	CppRemoveLimitOrder();
	assertIntEqual("test_LimitOrder",CppGetLimitOrderCount(),0);	
	assertStringEqual("test_LimitOrder",CppGetLimitOrderSymbol(),"");
	assertIntEqual("test_LimitOrder",CppGetLimitOrderType(),-1);	
	assertDoubleEqual("test_LimitOrder",CppGetLimitOrderPrice(),-1);	
	assertDoubleEqual("test_LimitOrder",CppGetLimitOrderLots(),-1);	
	assertDoubleEqual("test_LimitOrder",CppGetLimitOrderSlip(),-1);	
	assertIntEqual("test_LimitOrder",CppGetLimitOrderExpdate(),-1);		
	CppTurnLimitOrder();
	assertIntEqual("test_LimitOrder",CppGetLimitOrderCount(),0);	
	assertStringEqual("test_LimitOrder",CppGetLimitOrderSymbol(),"");
	assertIntEqual("test_LimitOrder",CppGetLimitOrderType(),-1);	
	assertDoubleEqual("test_LimitOrder",CppGetLimitOrderPrice(),-1);	
	assertDoubleEqual("test_LimitOrder",CppGetLimitOrderLots(),-1);	
	assertDoubleEqual("test_LimitOrder",CppGetLimitOrderSlip(),-1);	
	assertIntEqual("test_LimitOrder",CppGetLimitOrderExpdate(),-1);	
}



int test_CppUtility() {
	Print("-----------test_CppUtility begin-----------");
	test_LimitOrder();
	printAssertResul();
	Print("-----------test_CppUtility end------------");
}


