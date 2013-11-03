#include <testcase/test_stdlib.mqh>

#property show_confirm


int init() {
	return(0);
}


int start() {
	Print("Hello world !");
	test_stdlib();
	Print("test_stdlib end");
	printAssertResul();
}