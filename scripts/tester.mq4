#include <testcase/test_stdlib.mqh>
#include <testcase/test_CppUtility.mqh>

#property show_confirm


int init() {
	return(0);
}

int start() {
	Print("-------------tester begin-----------------");
	test_stdlib();
	test_CppUtility();		
	Print("-------------tester end-------------------");
}