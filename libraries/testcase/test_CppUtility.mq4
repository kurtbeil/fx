#property library

#include <CppUtility.mqh>
#include <testlib.mqh>



void test_LimitOrder(){	
	double p1=1.40101,p2=2.40101,p3=3.40101;
	datetime time1 = TimeCurrent(),time2 = TimeCurrent(),time3 = TimeCurrent();
	int ot1 = OP_BUY,ot2=OP_BUY,ot3 = OP_SELL;
	CppCreateLimitOrder(ot1,p1,time1);
	CppCreateLimitOrder(ot2,p2,time2);
	CppCreateLimitOrder(ot3,p3,time3);
	assertIntEqual("test_LimitOrder",CppGetLimitOrderCount(),3);	
	assertIntEqual("test_LimitOrder",CppGetLimitOrderType(),ot1);	
	assertDoubleEqual("test_LimitOrder",CppGetLimitOrderPrice(),p1);	
	assertIntEqual("test_LimitOrder",CppGetLimitOrderExpdate(),time1);			
	CppTurnLimitOrder();
	assertIntEqual("test_LimitOrder",CppGetLimitOrderCount(),3);	
	assertIntEqual("test_LimitOrder",CppGetLimitOrderType(),ot2);	
	assertDoubleEqual("test_LimitOrder",CppGetLimitOrderPrice(),p2);	
	assertIntEqual("test_LimitOrder",CppGetLimitOrderExpdate(),time2);			
	CppRemoveLimitOrder();
	assertIntEqual("test_LimitOrder",CppGetLimitOrderCount(),2);	
	assertIntEqual("test_LimitOrder",CppGetLimitOrderType(),ot3);	
	assertDoubleEqual("test_LimitOrder",CppGetLimitOrderPrice(),p3);	
	assertIntEqual("test_LimitOrder",CppGetLimitOrderExpdate(),time3);			
	CppRemoveLimitOrder();
	assertIntEqual("test_LimitOrder",CppGetLimitOrderCount(),1);	
	assertIntEqual("test_LimitOrder",CppGetLimitOrderType(),ot1);	
	assertDoubleEqual("test_LimitOrder",CppGetLimitOrderPrice(),p1);	
	assertIntEqual("test_LimitOrder",CppGetLimitOrderExpdate(),time1);			
	CppRemoveLimitOrder();
	assertIntEqual("test_LimitOrder",CppGetLimitOrderCount(),0);	
	assertIntEqual("test_LimitOrder",CppGetLimitOrderType(),-1);	
	assertDoubleEqual("test_LimitOrder",CppGetLimitOrderPrice(),-1);	
	assertIntEqual("test_LimitOrder",CppGetLimitOrderExpdate(),-1);	
	CppRemoveLimitOrder();
	assertIntEqual("test_LimitOrder",CppGetLimitOrderCount(),0);	
	assertIntEqual("test_LimitOrder",CppGetLimitOrderType(),-1);	
	assertDoubleEqual("test_LimitOrder",CppGetLimitOrderPrice(),-1);	
	assertIntEqual("test_LimitOrder",CppGetLimitOrderExpdate(),-1);		
	CppTurnLimitOrder();
	assertIntEqual("test_LimitOrder",CppGetLimitOrderCount(),0);	
	assertIntEqual("test_LimitOrder",CppGetLimitOrderType(),-1);	
	assertDoubleEqual("test_LimitOrder",CppGetLimitOrderPrice(),-1);	
	assertIntEqual("test_LimitOrder",CppGetLimitOrderExpdate(),-1);		
}



int test_CppUtility() {
	Print("-----------test_CppUtility begin-----------");
	test_LimitOrder();
	printAssertResul();
	Print("-----------test_CppUtility end------------");
}


