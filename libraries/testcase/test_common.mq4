#property library

#include <CppUtility.mqh>
#include <testlib.mqh>
#include <common.mqh>


void test_ExecuteId(){
	//Print("GetExecuteId=",GetExecuteId());
	assertIntNotEqual("test_ExpertName",0,GetExecuteId());		
}


void test_ExpertName(){		
	assertStringNotEqual("test_ExpertName",GetMainExpertName(),"");	
}



int test_common() {
	Print("-----------test_common begin-----------");
	test_ExpertName();
	test_ExecuteId();
	printAssertResul();
	Print("-----------test_common end------------");
}


