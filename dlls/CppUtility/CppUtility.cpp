// CppUtility.cpp : Defines the entry point for the DLL application.
//


#include "stdafx.h"
#include "CppUtility.h"

// 全局字符串变量的事务锁
CRITICAL_SECTION _StringParameter; 

// 生成ExecuteId的事务锁
CRITICAL_SECTION _GenerateExecuteId;

// 限价单队列的事务锁
CRITICAL_SECTION _LimitOrderQueen;


BOOL APIENTRY DllMain( HANDLE hModule, 
                       DWORD  ul_reason_for_call, 
                       LPVOID lpReserved
					 )
{
	::InitializeCriticalSection(&_StringParameter);
	::InitializeCriticalSection(&_GenerateExecuteId);
	::InitializeCriticalSection(&_LimitOrderQueen);
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
 
/*----------------------------------------------
--              生成ExecuteId功能             --
-----------------------------------------------*/

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


/*----------------------------------------------
--             全局字符串变量功能             --
-----------------------------------------------*/
// 保存全局字符串变量的map
map<int,map<string,string> > StringParameter;


MT4_EXPFUNC void __stdcall GlobalStringSet(int ExecuteId,char * name,char * value){
	::EnterCriticalSection(&_StringParameter); // 锁定变量StringParameter
	try{
		// 对应的ExecuteId是否已经建立起全局变量集
		if ( StringParameter.count(ExecuteId) <= 0){
			map<string,string> p;	
			StringParameter[ExecuteId] = p;	       //   注意这里是拷贝
		}
		StringParameter[ExecuteId][name] = value;  //   这里赋值实际上是通过value先创造出一个string
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


/*----------------------------------------------
--        限价单功能辅助数据结构实现          --
-----------------------------------------------*/


struct LimitOrder{
	int type;
	double price;
	int expdate;
};

// 存储限价单
map<int,queue<LimitOrder> > LimitOrderQueen;


void CreateLitmitOrder(int ExecuteId,int type,double price,int expdate){
	::EnterCriticalSection(&_LimitOrderQueen);   // 锁定变量LimitOrderQueen
    try{
		if ( LimitOrderQueen.count(ExecuteId) <= 0){
			queue<LimitOrder> queue;	
			LimitOrderQueen[ExecuteId] = queue;	       //   注意这里是拷贝
		}
		LimitOrder order;
		order.type = type;
		order.price = price;
		order.expdate = expdate;
		LimitOrderQueen[ExecuteId].push(order);        //   注意这里是变量拷贝
	}catch(...){}
	::LeaveCriticalSection(&_LimitOrderQueen); // 释放变量LimitOrderQueen 
}

int GetLitmitOrderCount(int ExecuteId){
	int result;
	::EnterCriticalSection(&_LimitOrderQueen);  // 锁定变量LimitOrderQueen
	try{	
		if ( LimitOrderQueen.count(ExecuteId) > 0){ 
			result = LimitOrderQueen[ExecuteId].size();
		}else{
			result = 0;
		}	
	}catch(...){}
	::LeaveCriticalSection(&_LimitOrderQueen);  // 释放变量LimitOrderQueen 
	return(result);
}

int GetLitmitOrderType(int ExecuteId){
	int result;
	::EnterCriticalSection(&_LimitOrderQueen);  // 锁定变量LimitOrderQueen
	try{	
		if ( LimitOrderQueen.count(ExecuteId) > 0){ 
			if(LimitOrderQueen[ExecuteId].size() > 0){
				result = LimitOrderQueen[ExecuteId].front().type;
			}else{
				result = -1;
			}
		}else{
			result = -1;
		}
	}catch(...){}
	::LeaveCriticalSection(&_LimitOrderQueen);  // 释放变量LimitOrderQueen 
	return(result);
}

double GetLitmitOrderPrice(int ExecuteId){
	double result;
	::EnterCriticalSection(&_LimitOrderQueen);  // 锁定变量LimitOrderQueen
	try{	
		if ( LimitOrderQueen.count(ExecuteId) > 0){ 
			if(LimitOrderQueen[ExecuteId].size() > 0 ){
				result = LimitOrderQueen[ExecuteId].front().price;
			}else{
				result = -1;
			}
		}else{
			result = -1;
		}
	}catch(...){}
	::LeaveCriticalSection(&_LimitOrderQueen);  // 释放变量LimitOrderQueen 
	return(result);
}


double GetLitmitOrderExpdate(int ExecuteId){
	int result;
	::EnterCriticalSection(&_LimitOrderQueen);  // 锁定变量LimitOrderQueen
	try{	
		if ( LimitOrderQueen.count(ExecuteId) > 0){ 
			if(LimitOrderQueen[ExecuteId].size() > 0){
				result = LimitOrderQueen[ExecuteId].front().expdate;
			}else{
				result = -1;
			}
		}else{
			result = -1;
		}
	}catch(...){}
	::LeaveCriticalSection(&_LimitOrderQueen);  // 释放变量LimitOrderQueen 
	return(result);
}


void RemoveLitmitOrder(int ExecuteId){
	::EnterCriticalSection(&_LimitOrderQueen);  // 锁定变量LimitOrderQueen
	try{	
		if ( LimitOrderQueen.count(ExecuteId) > 0){ 
			if(LimitOrderQueen[ExecuteId].size() > 0){
				LimitOrderQueen[ExecuteId].pop();  // 删除第1个数据
			}
		}
	}catch(...){}	
	::LeaveCriticalSection(&_LimitOrderQueen);  // 释放变量LimitOrderQueen     
}

void TurnLitmitOrder(int ExecuteId){
	::EnterCriticalSection(&_LimitOrderQueen);  // 锁定变量LimitOrderQueen
	try{	
		if ( LimitOrderQueen.count(ExecuteId) > 0){ 
			if(LimitOrderQueen[ExecuteId].size() > 0){
				LimitOrderQueen[ExecuteId].push(LimitOrderQueen[ExecuteId].front());  // 将队列第1数据拷贝至队列最后
				LimitOrderQueen[ExecuteId].pop();         // 删除第1个数据
			}
		}
	}catch(...){}
	::LeaveCriticalSection(&_LimitOrderQueen);  // 释放变量LimitOrderQueen 
}


