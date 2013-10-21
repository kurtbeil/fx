#include <common.mqh>
#include <utility.mqh>
#include <testcase/test_stdlib.mqh>
#include <testcase/test_CppUtility.mqh>
#include <testcase/test_common.mqh>

#property show_confirm


int init() {
	OnInitBegin(WindowExpertName());
	return(0);
}

int deinit(){	
	OnDeinitEnd();
}

int start() {	
	OnStartBegin();
	Print("-------------tester begin-----------------");
	test_stdlib();
	test_CppUtility();		
	test_common();		
	Print("-------------tester end-------------------");
	OnStartEnd();
}