// CppUtility.cpp : Defines the entry point for the DLL application.
//


#include "stdafx.h"
#include "CppUtility.h"
#include <Python.h>
#include <windows.h>


// ȫ���ַ���������������
CRITICAL_SECTION _StringParameter; 

// ����ExecuteId��������
CRITICAL_SECTION _GenerateExecuteId;

// �޼۵����е�������
CRITICAL_SECTION _LimitOrderQueue;

// python�������ݶ�ȡ
CRITICAL_SECTION _PythonCall;


/*----------------------------------------------
--                �����־����                --
-----------------------------------------------*/

char * logfile = "c:\\CppUtility.log";

void FormatTime(time_t t, char *strTime)
{
	struct tm tm1;
	tm1 = *localtime(&t);
    sprintf(
		strTime,"%4.4d-%2.2d-%2.2d %2.2d:%2.2d:%2.2d",
        tm1.tm_year+1900, tm1.tm_mon+1, tm1.tm_mday,
        tm1.tm_hour, tm1.tm_min,tm1.tm_sec
	);
}

void WriteLog(char * msg){
	FILE *fp;
	char strTime[1024];
	time_t t = time(NULL);
	FormatTime(t,strTime);
    if (fp=fopen(logfile,"a+")){
		fprintf(fp,"%s:%s\n",strTime,msg);
		fclose(fp);
	}
}

/*----------------------------------------------
--                dll��ʼ������               --
-----------------------------------------------*/


BOOL APIENTRY DllMain( HANDLE hModule, 
                       DWORD  ul_reason_for_call, 
                       LPVOID lpReserved
					 )
{
	//char logMsg[1204];	
	
	
	switch (ul_reason_for_call)
	{
		case DLL_PROCESS_ATTACH:
			// ��ʼ��python���л���
			//Py_Initialize();
		    //PyEval_InitThreads();			


			// ��ʼ���ٽ�������
			InitializeCriticalSection(&_StringParameter);
			InitializeCriticalSection(&_GenerateExecuteId);
			InitializeCriticalSection(&_LimitOrderQueue);
			InitializeCriticalSection(&_PythonCall);			
			
			//remove(logfile);
			break;
		case DLL_THREAD_ATTACH:
		case DLL_THREAD_DETACH:			
		case DLL_PROCESS_DETACH:
			// ����python���л���	
			//PyGILState_Ensure();
			//Py_Finalize();	
			break;
    }
	/*
	sprintf(
		logMsg,"_StringParameter=%0x,_GenerateExecuteId=%0x,_LimitOrderQueue=%0x,CurThreadId=%d",
		&_StringParameter,&_GenerateExecuteId,&_LimitOrderQueue,GetCurrentThreadId()
	);
	WriteLog(logMsg);
	*/
    return TRUE;
}


/*----------------------------------------------
--             �Զ���Ĺؼ�����������         --
-----------------------------------------------*/

void LockCS(CRITICAL_SECTION * cs){
	char logMsg[1204];	
	
	/*
	static i = 0;	
	if (i<100){
		sprintf(logMsg,"�鿴����(befere enter):LockCount=%d,OwningThread=%d,CurThread=%d",cs->LockCount,cs->OwningThread,GetCurrentThreadId());
		WriteLog(logMsg);		
	}
	*/

	if(!TryEnterCriticalSection(cs)){
		// ִ�е�������Ȼ���ǻὫ��ǰ��������
		// ����ֻ��ϣ���ڴ�֮ǰ��¼��һЩ��Ϣȷ������ȷʵ�����ڴ˴�
		sprintf(logMsg,"��������! LockCount=%d,OwningThread=%d,CurThread=%d,cs%0d",cs->LockCount,cs->OwningThread,GetCurrentThreadId());		
		WriteLog(logMsg);
		EnterCriticalSection(cs);
	}
	
	/*
	if (i<100){
		sprintf(logMsg,"�鿴����(befere enter):LockCount=%d,OwningThread=%d,CurThread=%d",cs->LockCount,cs->OwningThread,GetCurrentThreadId());
		WriteLog(logMsg);
	}
	i++;	
	*/
}

void UnlockCS(CRITICAL_SECTION * cs){
	LeaveCriticalSection(cs);
}
 
/*----------------------------------------------
--              ����ExecuteId����             --
-----------------------------------------------*/

MT4_EXPFUNC int __stdcall GenerateExecuteId(){	
	time_t t;
	LockCS(&_GenerateExecuteId); // ��������GenerateExecuteId����
	try{
		t = time(NULL);
		Sleep(1000);    // ��֤��һ���̶߳�ȡExecuteId��ʱ������һ�룬�������ᷢ���ظ�
	}catch(...){}
	UnlockCS(&_GenerateExecuteId); // �ͷź���GenerateExecuteId����
	return (t);	
}


/*----------------------------------------------
--             ȫ���ַ�����������             --
-----------------------------------------------*/
// ����ȫ���ַ���������map
map<int,map<string,string> > StringParameter;


MT4_EXPFUNC void __stdcall GlobalStringSet(int ExecuteId,char * name,char * value){
	LockCS(&_StringParameter); // ��������StringParameter
	try{
		// ��Ӧ��ExecuteId�Ƿ��Ѿ�������ȫ�ֱ�����
		if ( StringParameter.count(ExecuteId) <= 0){
			map<string,string> p;	
			StringParameter[ExecuteId] = p;	       //   ע�������ǿ���
		}
		StringParameter[ExecuteId][name] = value;  //   ���︳ֵʵ������ͨ��value�ȴ����һ��string
	}catch(...){}
	UnlockCS(&_StringParameter); // �ͷű���StringParameter	 
}


MT4_EXPFUNC char* __stdcall GlobalStringGet(int ExecuteId,char * name){
	//static char buf[512];
	char * result = NULL;
	LockCS(&_StringParameter); // ��������StringParameter
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
	UnlockCS(&_StringParameter); // �ͷű���StringParameter 	
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
	int createtime;
};

int LimitOrderIdSeq = 1;

// �洢�޼۵�
map<int,queue<LimitOrder> > LimitOrderQueue;


MT4_EXPFUNC int CreateLimitOrder(int ExecuteId,char * symbol,int type,double price,double lots,int expdate,int createtime){
	LockCS(&_LimitOrderQueue);   // ��������LimitOrderQueue
    LimitOrder order;
	try{
		if ( LimitOrderQueue.count(ExecuteId) <= 0){
			queue<LimitOrder> queue;	
			LimitOrderQueue[ExecuteId] = queue;	       //   ע�������ǿ���
		}		
		order.id = LimitOrderIdSeq++;
		order.symbol = symbol;
		order.type = type;
		order.price = price;
		order.lots = lots;
		order.expdate = expdate;
		order.createtime = createtime;
		LimitOrderQueue[ExecuteId].push(order);        //   ע�������Ǳ�������
	}catch(...){}
	UnlockCS(&_LimitOrderQueue); // �ͷű���LimitOrderQueue 
	return(order.id);
}

MT4_EXPFUNC int GetLimitOrderCount(int ExecuteId){
	int result;
	LockCS(&_LimitOrderQueue);  // ��������LimitOrderQueue
	try{	
		if ( LimitOrderQueue.count(ExecuteId) > 0){ 
			result = LimitOrderQueue[ExecuteId].size();
		}else{
			result = 0;
		}	
	}catch(...){}
	UnlockCS(&_LimitOrderQueue);  // �ͷű���LimitOrderQueue 
	return(result);
}

MT4_EXPFUNC int GetLimitOrderId(int ExecuteId){
	int result;
	LockCS(&_LimitOrderQueue);  // ��������LimitOrderQueue
	try{	
		if ( LimitOrderQueue.count(ExecuteId) > 0){ 
			if(LimitOrderQueue[ExecuteId].size() > 0){
				result = LimitOrderQueue[ExecuteId].front().id;
			}else{
				result = -1;
			}
		}else{
			result = -1;
		}
	}catch(...){}
	UnlockCS(&_LimitOrderQueue);  // �ͷű���LimitOrderQueue 
	return(result);
}


MT4_EXPFUNC char * GetLimitOrderSymbol(int ExecuteId){
	char * result = NULL;
	LockCS(&_LimitOrderQueue);  // ��������LimitOrderQueue
	try{	
		if ( LimitOrderQueue.count(ExecuteId) > 0){ 
			if(LimitOrderQueue[ExecuteId].size() > 0){
				result = (char*)LimitOrderQueue[ExecuteId].front().symbol.c_str();
			}else{
				result = NULL;
			}
		}else{
			result = NULL;
		}
	}catch(...){}
	UnlockCS(&_LimitOrderQueue);  // �ͷű���LimitOrderQueue 
	return(result);
}

MT4_EXPFUNC int GetLimitOrderType(int ExecuteId){
	int result;
	LockCS(&_LimitOrderQueue);  // ��������LimitOrderQueue
	try{	
		if ( LimitOrderQueue.count(ExecuteId) > 0){ 
			if(LimitOrderQueue[ExecuteId].size() > 0){
				result = LimitOrderQueue[ExecuteId].front().type;
			}else{
				result = -1;
			}
		}else{
			result = -1;
		}
	}catch(...){}
	UnlockCS(&_LimitOrderQueue);  // �ͷű���LimitOrderQueue 
	return(result);
}

MT4_EXPFUNC double GetLimitOrderPrice(int ExecuteId){
	double result;
	LockCS(&_LimitOrderQueue);  // ��������LimitOrderQueue
	try{	
		if ( LimitOrderQueue.count(ExecuteId) > 0){ 
			if(LimitOrderQueue[ExecuteId].size() > 0 ){
				result = LimitOrderQueue[ExecuteId].front().price;
			}else{
				result = -1;
			}
		}else{
			result = -1;
		}
	}catch(...){}
	UnlockCS(&_LimitOrderQueue);  // �ͷű���LimitOrderQueue 
	return(result);
}

MT4_EXPFUNC double GetLimitOrderLots(int ExecuteId){
	double result;
	LockCS(&_LimitOrderQueue);  // ��������LimitOrderQueue
	try{	
		if ( LimitOrderQueue.count(ExecuteId) > 0){ 
			if(LimitOrderQueue[ExecuteId].size() > 0 ){
				result = LimitOrderQueue[ExecuteId].front().lots;
			}else{
				result = -1;
			}
		}else{
			result = -1;
		}
	}catch(...){}
	UnlockCS(&_LimitOrderQueue);  // �ͷű���LimitOrderQueue 
	return(result);
}



MT4_EXPFUNC int GetLimitOrderExpdate(int ExecuteId){
	int result;
	LockCS(&_LimitOrderQueue);  // ��������LimitOrderQueue
	try{	
		if ( LimitOrderQueue.count(ExecuteId) > 0){ 
			if(LimitOrderQueue[ExecuteId].size() > 0){
				result = LimitOrderQueue[ExecuteId].front().expdate;
			}else{
				result = -1;
			}
		}else{
			result = -1;
		}
	}catch(...){}
	UnlockCS(&_LimitOrderQueue);  // �ͷű���LimitOrderQueue 
	return(result);
}


MT4_EXPFUNC int GetLimitOrderCreateTime(int ExecuteId){
	int result;
	LockCS(&_LimitOrderQueue);  // ��������LimitOrderQueue
	try{	
		if ( LimitOrderQueue.count(ExecuteId) > 0){ 
			if(LimitOrderQueue[ExecuteId].size() > 0){
				result = LimitOrderQueue[ExecuteId].front().createtime;
			}else{
				result = -1;
			}
		}else{
			result = -1;
		}
	}catch(...){}
	UnlockCS(&_LimitOrderQueue);  // �ͷű���LimitOrderQueue 
	return(result);
}


MT4_EXPFUNC void RemoveLimitOrder(int ExecuteId){
	LockCS(&_LimitOrderQueue);  // ��������LimitOrderQueue
	try{	
		if ( LimitOrderQueue.count(ExecuteId) > 0){ 
			if(LimitOrderQueue[ExecuteId].size() > 0){
				LimitOrderQueue[ExecuteId].pop();  // ɾ����1������
			}
		}
	}catch(...){}	
	UnlockCS(&_LimitOrderQueue);  // �ͷű���LimitOrderQueue     
}

MT4_EXPFUNC void TurnLimitOrder(int ExecuteId){
	LockCS(&_LimitOrderQueue);  // ��������LimitOrderQueue
	try{	
		if ( LimitOrderQueue.count(ExecuteId) > 0){ 
			if(LimitOrderQueue[ExecuteId].size() > 0){
				LimitOrderQueue[ExecuteId].push(LimitOrderQueue[ExecuteId].front());  // �����е�1���ݿ������������
				LimitOrderQueue[ExecuteId].pop();         // ɾ����1������
			}
		}
	}catch(...){}
	UnlockCS(&_LimitOrderQueue);  // �ͷű���LimitOrderQueue 
}


/*----------------------------------------------
--        ����python�����ļ���ع���          --
-----------------------------------------------*/

void ClearPyRef(PyObject * pol[],int size){
	for(int i=0; i<size; i++){
	   Py_DECREF(pol[i]);
	}
}


char * PyConfigReadFile(char* file){
    __declspec( thread ) static char * buf=NULL;
	
	LockCS(&_PythonCall);  // ����python������
	Py_Initialize();
	//PyGILState_STATE gstate = PyGILState_Ensure();    // ��� GIL
	__try{
		int i=0;
		PyObject *pMod,*pFun,*pArgs,*pRes,*pol[50];	
		char * pStr=NULL;
	
		// �����һ��ʹ�õĻ�������δ�ͷţ����Ƚ����ͷţ���ֹ�ڴ�й¶
		if(buf){
			free(buf);
			buf=NULL;
		}

		// ����ģ��
		pMod = PyImport_ImportModule("fxclient.mt4lib.config");
		if ( pMod == NULL ) {
			return (NULL);		
		}
		pol[i++] = pMod;
	
		// ��λ����
		pFun = PyObject_GetAttrString(pMod,"readFile");
		if ( pFun == NULL ) {
			ClearPyRef(pol,i);
			return (NULL);		
		}
		pol[i++] = pFun;

		// �����
		pArgs = Py_BuildValue("(s)",file);
		if ( pArgs == NULL ) {
			ClearPyRef(pol,i);
			return (NULL);
		}
		pol[i++] = pArgs;

		// ���÷���
		pRes = PyEval_CallObject(pFun,pArgs);		
		if ( pRes == NULL ) {
			ClearPyRef(pol,i);
			return(NULL);
		}
		pol[i++] = pRes;

		// ��ȡ���ز���
		PyArg_Parse(pRes,"s",&pStr);
		if ( pStr == NULL ) {
			ClearPyRef(pol,i);
			return(NULL);
		}
    
		// ���Է��仺������ʧ�ܷ���ֵΪNULL
		buf = (char*) malloc(strlen(pStr)+1);
		if (buf){
			strcpy(buf,pStr);
		}
		// �ͷ�python��������	
		ClearPyRef(pol,i);
	
	}__finally{
		//PyGILState_Release(gstate);   // �ͷ�GIL
		Py_Finalize();
		UnlockCS(&_PythonCall);       // �⿪python������
	}
	return(buf);
}

	
char * PyReadDictValueStr(char * dictStr,char * path){
    __declspec( thread ) static char * buf = NULL;

	LockCS(&_PythonCall);  // ����python������
	Py_Initialize();
	//PyGILState_STATE gstate = PyGILState_Ensure();    // ��� GIL
	__try{
		int i=0;
		PyObject *pMod,*pFun,*pArgs,*pRes,*pol[50];	
		char * pStr=NULL;

		if(buf) {
			free(buf);
			buf = NULL;
		}
	
		// ����ģ��
		pMod = PyImport_ImportModule("fxclient.mt4lib.config");
		if ( pMod == NULL ) {
			return (NULL);		
		}
		pol[i++] = pMod;
	
		// ��λ����
		pFun = PyObject_GetAttrString(pMod,"readDictValueStr");
		if ( pFun == NULL ) {
			ClearPyRef(pol,i);
			return (NULL);		
		}
		pol[i++] = pFun;

		// �����
		pArgs = Py_BuildValue("(s,s)",dictStr,path);
		if ( pArgs == NULL ) {
			ClearPyRef(pol,i);
			return (NULL);
		}
		pol[i++] = pArgs;

		// ���÷���
		pRes = PyEval_CallObject(pFun,pArgs);		
		if ( pRes == NULL ) {
			ClearPyRef(pol,i);
			return(NULL);
		}
		pol[i++] = pRes;
	
		// ��ȡ���ز���
		PyArg_Parse(pRes,"s",&pStr);
		if ( pStr == NULL ) {
			ClearPyRef(pol,i);
			return(NULL);
		}

		// ���Է��仺������ʧ�ܷ���ֵΪNULL
		buf = (char*) malloc(strlen(pStr)+1);
		if (buf){
			strcpy(buf,pStr);
		}

		ClearPyRef(pol,i);	
	
	}__finally{
		//PyGILState_Release(gstate);   // �ͷ�GIL
		Py_Finalize();
		UnlockCS(&_PythonCall);       // �⿪python������
	}
	return(buf);
}



char * PyReadDictValueType(char * dictStr,char * path){
	__declspec( thread ) static char * buf = NULL;	
    
	LockCS(&_PythonCall);  // ����python������
	Py_Initialize();
	//PyGILState_STATE gstate = PyGILState_Ensure();    // ��� GIL
	__try{

		int i=0,j,len;
		PyObject *pMod,*pFun,*pArgs,*pRes,*pol[50];	
		char * pStr=NULL;

		if(buf) {
			free(buf);
			buf = NULL;
		}
	
		// ����ģ��
		pMod = PyImport_ImportModule("fxclient.mt4lib.config");
		if ( pMod == NULL ) {
			return (NULL);		
		}
		pol[i++] = pMod;
	
		// ��λ����
		pFun = PyObject_GetAttrString(pMod,"readDictValueType");
		if ( pFun == NULL ) {
			ClearPyRef(pol,i);
			return (NULL);		
		}
		pol[i++] = pFun;

		// �����
		pArgs = Py_BuildValue("(s,s)",dictStr,path);
		if ( pArgs == NULL ) {
			ClearPyRef(pol,i);
			return (NULL);
		}
		pol[i++] = pArgs;

		// ���÷���
		pRes = PyEval_CallObject(pFun,pArgs);		
		if ( pRes == NULL ) {
			ClearPyRef(pol,i);
			return(NULL);
		}
		pol[i++] = pRes;
	
		// ��ȡ���ز���
		PyArg_Parse(pRes,"s",&pStr);
		if ( pStr == NULL ) {
			ClearPyRef(pol,i);
			return(NULL);
		}

		// ���Է��仺������ʧ�ܷ���ֵΪNULL
		buf = (char*) malloc(strlen(pStr)+1);
		if (buf){
			strcpy(buf,pStr);
			// python ���͵��ַ�����ʾ <type '...'>
			// ȥ��<type '...'> �����������ƴ�
			len = strlen(buf);	
			for(j=0; j<len-9; j++){
				buf[j] = buf[j+7];
			}
			buf[j] = 0;
		}
		
		ClearPyRef(pol,i);		

	}__finally{
		//PyGILState_Release(gstate);   // �ͷ�GIL
		Py_Finalize();
		UnlockCS(&_PythonCall);       // �⿪python������
	}
	return(buf);
}

/*----------------------------------------------
--       python���ʷ���������ع���           --
-----------------------------------------------*/

char * PyExpertRegister(char * ExpertCode,char * AccountLoginId,char * AccountCompanyName,char * AccountServerName){
	__declspec( thread ) static char * buf = NULL;    

	LockCS(&_PythonCall);  // ����python������	
	Py_Initialize();
	//PyGILState_STATE gstate = PyGILState_Ensure();    // ��� GIL	
	__try{		
		int i=0;
		PyObject *pMod,*pFun,*pArgs,*pRes,*pol[50];	
		char * pStr=NULL;

		if(buf){
			free(buf);
			buf = NULL;
		}
	
		// ����ģ��
		pMod = PyImport_ImportModule("fxclient.mt4lib.service");
		if ( pMod == NULL ) {
			return (NULL);		
		}
		pol[i++] = pMod;
	
		// ��λ����
		pFun = PyObject_GetAttrString(pMod,"expertRegister");
		if ( pFun == NULL ) {
			ClearPyRef(pol,i);
			return (NULL);		
		}
		pol[i++] = pFun;

		// �����
		pArgs = Py_BuildValue("(s,s,s,s)",ExpertCode,AccountLoginId,AccountCompanyName,AccountServerName);
		if ( pArgs == NULL ) {
			ClearPyRef(pol,i);
			return (NULL);
		}
		pol[i++] = pArgs;

		// ���÷���
		pRes = PyEval_CallObject(pFun,pArgs);		
		if ( pRes == NULL ) {
			ClearPyRef(pol,i);
			return(NULL);
		}
		pol[i++] = pRes;

		// ��ȡ���ز���
		PyArg_Parse(pRes,"s",&pStr);
		if ( pStr == NULL ) {
			ClearPyRef(pol,i);
			return(NULL);
		}
    
		// ���Է��仺������ʧ�ܷ���ֵΪNULL
		buf = (char*) malloc(strlen(pStr)+1);
		if (buf){
			strcpy(buf,pStr);
		}

		ClearPyRef(pol,i);	

	}__finally{
		//PyGILState_Release(gstate);   // �ͷ�GIL
		Py_Finalize();
		UnlockCS(&_PythonCall);       // �⿪python������ 
	}
	return(buf);	
	

}


char * PyExpertUnregister(char * ExpertInstanceId,char * Token){
	__declspec( thread ) static char * buf = NULL;    

	LockCS(&_PythonCall);  // ����python������	
	Py_Initialize();
	//PyGILState_STATE gstate = PyGILState_Ensure();    // ��� GIL	
	__try{		
		int i=0;
		PyObject *pMod,*pFun,*pArgs,*pRes,*pol[50];	
		char * pStr=NULL;

		if(buf){
			free(buf);
			buf = NULL;
		}
	
		// ����ģ��
		pMod = PyImport_ImportModule("fxclient.mt4lib.service");
		if ( pMod == NULL ) {
			return (NULL);		
		}
		pol[i++] = pMod;
	
		// ��λ����
		pFun = PyObject_GetAttrString(pMod,"expertUnregister");
		if ( pFun == NULL ) {
			ClearPyRef(pol,i);
			return (NULL);		
		}
		pol[i++] = pFun;

		// �����
		pArgs = Py_BuildValue("(s,s)",ExpertInstanceId,Token);
		if ( pArgs == NULL ) {
			ClearPyRef(pol,i);
			return (NULL);
		}
		pol[i++] = pArgs;

		// ���÷���
		pRes = PyEval_CallObject(pFun,pArgs);		
		if ( pRes == NULL ) {
			ClearPyRef(pol,i);
			return(NULL);
		}
		pol[i++] = pRes;

		// ��ȡ���ز���
		PyArg_Parse(pRes,"s",&pStr);
		if ( pStr == NULL ) {
			ClearPyRef(pol,i);
			return(NULL);
		}
    
		// ���Է��仺������ʧ�ܷ���ֵΪNULL
		buf = (char*) malloc(strlen(pStr)+1);
		if (buf){
			strcpy(buf,pStr);
		}

		ClearPyRef(pol,i);	

	}__finally{
		//PyGILState_Release(gstate);   // �ͷ�GIL
		Py_Finalize();
		UnlockCS(&_PythonCall);       // �⿪python������ 
	}
	return(buf);	

}


/*----------------------------------------------
--                 ���Թ���                   --
-----------------------------------------------*/
int TestSleep(int n){
	Sleep(n);
	return(n);
}








