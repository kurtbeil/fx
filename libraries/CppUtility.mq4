#property library

#include <common.mqh>

#import "CppUtility.dll"
string GlobalStringGet(int ExecuteId,string name);
void GlobalStringSet(int ExecuteId,string name,string value);
int GenerateExecuteId();

string CppGlobalStringGet(string name){
	return (GlobalStringGet(GetExecuteId(),name));	
}

void CppGlobalStringSet(string name,string value) {
	GlobalStringSet(GetExecuteId(),name,value);
}

int CppGenerateExecuteId(){
	return(GenerateExecuteId());
}


