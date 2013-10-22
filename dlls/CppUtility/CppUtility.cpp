// CppUtility.cpp : Defines the entry point for the DLL application.
//


#include "stdafx.h"
#include "CppUtility.h"

// ȫ���ַ���������������
CRITICAL_SECTION _StringParameter; 

// ����ExecuteId��������
CRITICAL_SECTION _GenerateExecuteId;

// �޼۵����е�������
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
--              ����ExecuteId����             --
-----------------------------------------------*/

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


/*----------------------------------------------
--             ȫ���ַ�����������             --
-----------------------------------------------*/
// ����ȫ���ַ���������map
map<int,map<string,string> > StringParameter;


MT4_EXPFUNC void __stdcall GlobalStringSet(int ExecuteId,char * name,char * value){
	::EnterCriticalSection(&_StringParameter); // ��������StringParameter
	try{
		// ��Ӧ��ExecuteId�Ƿ��Ѿ�������ȫ�ֱ�����
		if ( StringParameter.count(ExecuteId) <= 0){
			map<string,string> p;	
			StringParameter[ExecuteId] = p;	       //   ע�������ǿ���
		}
		StringParameter[ExecuteId][name] = value;  //   ���︳ֵʵ������ͨ��value�ȴ����һ��string
	}catch(...){}
	::LeaveCriticalSection(&_StringParameter); // �ͷű���StringParameter	 
}


MT4_EXPFUNC char* __stdcall GlobalStringGet(int ExecuteId,char * name){
	//static char buf[512];
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



/*----------------------------------------------
--        �޼۵����ܸ������ݽṹʵ��          --
-----------------------------------------------*/


struct LimitOrder{
	int id;
	string symbol;
	int type;
	double price;
	double lots;
	int expdate;
};

int LimitOrderIdSeq = 1;

// �洢�޼۵�
map<int,queue<LimitOrder> > LimitOrderQueen;


MT4_EXPFUNC int CreateLimitOrder(int ExecuteId,char * symbol,int type,double price,double lots,int expdate){
	::EnterCriticalSection(&_LimitOrderQueen);   // ��������LimitOrderQueen
    LimitOrder order;
	try{
		if ( LimitOrderQueen.count(ExecuteId) <= 0){
			queue<LimitOrder> queue;	
			LimitOrderQueen[ExecuteId] = queue;	       //   ע�������ǿ���
		}		
		order.id = LimitOrderIdSeq++;
		order.symbol = symbol;
		order.type = type;
		order.price = price;
		order.lots = lots;
		order.expdate = expdate;
		LimitOrderQueen[ExecuteId].push(order);        //   ע�������Ǳ�������
	}catch(...){}
	::LeaveCriticalSection(&_LimitOrderQueen); // �ͷű���LimitOrderQueen 
	return(order.id);
}

MT4_EXPFUNC int GetLimitOrderCount(int ExecuteId){
	int result;
	::EnterCriticalSection(&_LimitOrderQueen);  // ��������LimitOrderQueen
	try{	
		if ( LimitOrderQueen.count(ExecuteId) > 0){ 
			result = LimitOrderQueen[ExecuteId].size();
		}else{
			result = 0;
		}	
	}catch(...){}
	::LeaveCriticalSection(&_LimitOrderQueen);  // �ͷű���LimitOrderQueen 
	return(result);
}

MT4_EXPFUNC int GetLimitOrderId(int ExecuteId){
	int result;
	::EnterCriticalSection(&_LimitOrderQueen);  // ��������LimitOrderQueen
	try{	
		if ( LimitOrderQueen.count(ExecuteId) > 0){ 
			if(LimitOrderQueen[ExecuteId].size() > 0){
				result = LimitOrderQueen[ExecuteId].front().id;
			}else{
				result = -1;
			}
		}else{
			result = -1;
		}
	}catch(...){}
	::LeaveCriticalSection(&_LimitOrderQueen);  // �ͷű���LimitOrderQueen 
	return(result);
}


MT4_EXPFUNC char * GetLimitOrderSymbol(int ExecuteId){
	char * result = NULL;
	::EnterCriticalSection(&_LimitOrderQueen);  // ��������LimitOrderQueen
	try{	
		if ( LimitOrderQueen.count(ExecuteId) > 0){ 
			if(LimitOrderQueen[ExecuteId].size() > 0){
				result = (char*)LimitOrderQueen[ExecuteId].front().symbol.c_str();
			}else{
				result = NULL;
			}
		}else{
			result = NULL;
		}
	}catch(...){}
	::LeaveCriticalSection(&_LimitOrderQueen);  // �ͷű���LimitOrderQueen 
	return(result);
}

MT4_EXPFUNC int GetLimitOrderType(int ExecuteId){
	int result;
	::EnterCriticalSection(&_LimitOrderQueen);  // ��������LimitOrderQueen
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
	::LeaveCriticalSection(&_LimitOrderQueen);  // �ͷű���LimitOrderQueen 
	return(result);
}

MT4_EXPFUNC double GetLimitOrderPrice(int ExecuteId){
	double result;
	::EnterCriticalSection(&_LimitOrderQueen);  // ��������LimitOrderQueen
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
	::LeaveCriticalSection(&_LimitOrderQueen);  // �ͷű���LimitOrderQueen 
	return(result);
}

MT4_EXPFUNC double GetLimitOrderLots(int ExecuteId){
	double result;
	::EnterCriticalSection(&_LimitOrderQueen);  // ��������LimitOrderQueen
	try{	
		if ( LimitOrderQueen.count(ExecuteId) > 0){ 
			if(LimitOrderQueen[ExecuteId].size() > 0 ){
				result = LimitOrderQueen[ExecuteId].front().lots;
			}else{
				result = -1;
			}
		}else{
			result = -1;
		}
	}catch(...){}
	::LeaveCriticalSection(&_LimitOrderQueen);  // �ͷű���LimitOrderQueen 
	return(result);
}



MT4_EXPFUNC int GetLimitOrderExpdate(int ExecuteId){
	int result;
	::EnterCriticalSection(&_LimitOrderQueen);  // ��������LimitOrderQueen
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
	::LeaveCriticalSection(&_LimitOrderQueen);  // �ͷű���LimitOrderQueen 
	return(result);
}


MT4_EXPFUNC void RemoveLimitOrder(int ExecuteId){
	::EnterCriticalSection(&_LimitOrderQueen);  // ��������LimitOrderQueen
	try{	
		if ( LimitOrderQueen.count(ExecuteId) > 0){ 
			if(LimitOrderQueen[ExecuteId].size() > 0){
				LimitOrderQueen[ExecuteId].pop();  // ɾ����1������
			}
		}
	}catch(...){}	
	::LeaveCriticalSection(&_LimitOrderQueen);  // �ͷű���LimitOrderQueen     
}

MT4_EXPFUNC void TurnLimitOrder(int ExecuteId){
	::EnterCriticalSection(&_LimitOrderQueen);  // ��������LimitOrderQueen
	try{	
		if ( LimitOrderQueen.count(ExecuteId) > 0){ 
			if(LimitOrderQueen[ExecuteId].size() > 0){
				LimitOrderQueen[ExecuteId].push(LimitOrderQueen[ExecuteId].front());  // �����е�1���ݿ������������
				LimitOrderQueen[ExecuteId].pop();         // ɾ����1������
			}
		}
	}catch(...){}
	::LeaveCriticalSection(&_LimitOrderQueen);  // �ͷű���LimitOrderQueen 
}


