

#include <CppUtility.mqh>
#include <common.mqh>

#property show_confirm

int init() {
	OnInitBegin(WindowExpertName());
	//return(0);
}




void start(){
	//int ExecuteId = GetExecuteId();
	//Print("ExecuteId="+ExecuteId);
	//CppGlobalStringSet("hello","world");
	//CppGlobalStringSet("hello","world2");
	//CppGlobalStringSet("hello2","world");
	//CppGlobalStringSet("hello2","world");	
	//Print("CppGlobalStringGet1="+CppGlobalStringGet("hello"));	
	//Print("CppGlobalStringGet2="+CppGlobalStringGet("hello2"));	
	
	//int handle = WindowHandle(Symbol(),Period());
	//Print("handle=",handle);
	Print("ExecuteId=",GetExecuteId());

}