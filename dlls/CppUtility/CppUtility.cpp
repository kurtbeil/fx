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
	::EnterCriticalSection(&_GenerateExecuteId); // ��������GenerateExecuteId����
	try{
		t = time(NULL);
		Sleep(1000);    // ��֤��һ���̶߳�ȡExecuteId��ʱ������һ�룬�������ᷢ���ظ�
	}catch(...){}
	::LeaveCriticalSection(&_GenerateExecuteId); // �ͷź���GenerateExecuteId����
	return (t);	
}


MT4_EXPFUNC void __stdcall GlobalStringSet(int ExecuteId,char * name,char * value){
	::EnterCriticalSection(&_StringParameter); // ��������StringParameter
	try{
		// ��Ӧ��ExecuteId�Ƿ��Ѿ�������ȫ�ֱ�����
		if ( StringParameter.count(ExecuteId) <= 0){
			map<string,string> * p  = new map<string,string>;	
			StringParameter[ExecuteId] = *p;	//   ������ôд�Ƕ��󿽱��������ã��������������û���κ����⣬����ǿ�����ʵ�ʲ���Ҫʹ��new�ֲ���������		
		}
		StringParameter[ExecuteId][name] = value;  //   ������ôд�Ƕ��󿽱���������,name,value�����������ǲ��Ǻ����������ʱ��ʧ
	}catch(...){}
	::LeaveCriticalSection(&_StringParameter); // �ͷű���StringParameter	 
}


MT4_EXPFUNC char* __stdcall GlobalStringGet(int ExecuteId,char * name){
	static char buf[512];
	char * result = NULL;
	::EnterCriticalSection(&_StringParameter); // ��������StringParameter
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
	::LeaveCriticalSection(&_StringParameter); // �ͷű���StringParameter 	
	return result;
}

