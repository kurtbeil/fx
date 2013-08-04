#include <testcase/test_stdlib.mqh>

#property show_confirm


int init() {

	return(0);
}


int start() {
	//Print("hello"+StringReplace("123","2","!"));
	//log("1.log","123");

	//Print("hello world");
	Print("Hello world !");
	test_stdlib();
	Print("test_stdlib end");

	printAssertResul();
}