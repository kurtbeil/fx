// CppUtility.cpp : Defines the entry point for the DLL application.
//


#include "stdafx.h"
#include "CppUtility.h"


struct MQLSTR
{
   int               len;
   char             *string;
};

map<int,map<string,string> > StringParameter;
CRITICAL_SECTION _StringParameter; 

CRITICAL_SECTION _GenerateExecuteId;

BOOL APIENTRY DllMain( HANDLE hModule, 
                       DWORD  ul_reason_for_call, 
                       LPVOID lpReserved
					 )
{
	::InitializeCriticalSection(&_StringParameter);
	::InitializeCriticalSection(&_GenerateExecuteId);
	switch (ul_reason_for_call)
	{
		case DLL_PROCESS_ATTACH:
		case DLL_THREAD_ATTACH:
		case DLL_THREAD_DETACH:
		case DLL_PROCESS_DETACH:
			break;
    }
    return TRUE;
}
 


MT4_EXPFUNC int __stdcall GenerateExecuteId(){	
	time_t t;
	::EnterCriticalSection(&_GenerateExecuteId); // 锁定函数GenerateExecuteId函数
	try{
		t = time(NULL);
		Sleep(1000);    // 保证下一个线程读取ExecuteId的时间是下一秒，这样不会发生重复
	}catch(...){}
	::LeaveCriticalSection(&_GenerateExecuteId); // 释放函数GenerateExecuteId函数
	return (t);	
}


MT4_EXPFUNC void __stdcall GlobalStringSet(int ExecuteId,char * name,char * value){
	::EnterCriticalSection(&_StringParameter); // 锁定变量StringParameter
	try{
		// 对应的ExecuteId是否已经建立起全局变量集
		if ( StringParameter.count(ExecuteId) <= 0){
			map<string,string> * p  = new map<string,string>;	
			StringParameter[ExecuteId] = *p;	//   这里这么写是对象拷贝还是引用，如果是引用这样没有任何问题，如果是拷贝则实际不需要使用new局部变量即可		
		}
		StringParameter[ExecuteId][name] = value;  //   这里这么写是对象拷贝还是引用,name,value的作用域我们不是很清楚可能随时消失
	}catch(...){}
	::LeaveCriticalSection(&_StringParameter); // 释放变量StringParameter	 
}


MT4_EXPFUNC char* __stdcall GlobalStringGet(int ExecuteId,char * name){
	static char buf[512];
	char * result = NULL;
	::EnterCriticalSection(&_StringParameter); // 锁定变量StringParameter
	try{
		if ( StringParameter.count(ExecuteId) > 0){
			map<string,string> p = StringParameter[ExecuteId];			
			if (p.count(name) > 0 ) {
				string value = p[name];
				result = (char*) value.c_str();
			}else{
				result = "";
			}			
		}else{
			result = "";
		}
	}catch(...){}
	::LeaveCriticalSection(&_StringParameter); // 释放变量StringParameter 	
	return result;
}

