// CppUtility.cpp : Defines the entry point for the DLL application.
//


#include "stdafx.h"
#include "CppUtility.h"
#include <Python.h>


// ȫ���ַ���������������
CRITICAL_SECTION _StringParameter; 

// ����ExecuteId��������
CRITICAL_SECTION _GenerateExecuteId;

// �޼۵����е�������
CRITICAL_SECTION _LimitOrderQueue;

// python�������ݶ�ȡ
CRITICAL_SECTION _PyConfigRead;


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
			Py_Initialize();
			// ��ʼ���ٽ�������
			InitializeCriticalSection(&_StringParameter);
			InitializeCriticalSection(&_GenerateExecuteId);
			InitializeCriticalSection(&_LimitOrderQueue);
			InitializeCriticalSection(&_PyConfigRead);			
			
			//remove(logfile);
			break;
		case DLL_THREAD_ATTACH:
		case DLL_THREAD_DETACH:			
		case DLL_PROCESS_DETACH:
			// ����python���л���			
			Py_Finalize();	
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

int PyObjectToString(PyObject * pObj,char * buf,int bufsize){
	
	int i=0,res;
	PyObject *pMod,*pFun,*pArgs,*pRes,*pol[50];	
	char * pStr=NULL;
	
	// ����ģ��
	pMod = PyImport_ImportModule("__builtin__");
	if ( pMod == NULL ) {
		return (-1);		
	}
	pol[i++] = pMod;

	// ��λ����
	pFun = PyObject_GetAttrString(pMod,"str");
	if ( pFun == NULL ) {
		ClearPyRef(pol,i);
		return (-1);		
	}
    pol[i++] = pFun;
	
	// ׼������
	pArgs = Py_BuildValue("(O)",pObj);
	if ( pArgs == NULL ) {
		ClearPyRef(pol,i);
		return (-3);
	}
	pol[i++] = pArgs;
	
	// ���÷���
	pRes = PyEval_CallObject(pFun,pArgs);
	if ( pRes == NULL ) {
		ClearPyRef(pol,i);
		return(-1);
	}
	pol[i++] = pRes;

	// ��ȡ���ز���
	PyArg_Parse(pRes,"s",&pStr);
	if ( pStr == NULL ) {
		ClearPyRef(pol,i);
		return(-1);
	}
		
	if (strlen(pStr) == 0 || strlen(pStr) + 1 > bufsize){
		res = -1;
	}else{
		strcpy(buf,pStr);
		res = 0;
	}		
	
	Py_DECREF(pStr);		
	ClearPyRef(pol,i);		
	return(res);
}

// ע��:�ú�������ֱ�ӵ�����MT4�����е���
int PyObjectType(PyObject * pObj,char * buf,int bufsize){
	
	int i=0,j,res,len;
	PyObject *pMod,*pFun,*pArgs,*pRes,*pol[50];	
	char * pStr=NULL;

	// ����ģ��
	pMod = PyImport_ImportModule("__builtin__");
	if ( pMod == NULL ) {
		return (-1);		
	}
	pol[i++] = pMod;

	// ��λ����
	pFun = PyObject_GetAttrString(pMod,"type");
	if ( pFun == NULL ) {
		ClearPyRef(pol,i);
		return (-1);		
	}
    pol[i++] = pFun;
	
	// ׼������
	pArgs = Py_BuildValue("(O)",pObj);
	if ( pArgs == NULL ) {
		ClearPyRef(pol,i);
		return (-3);
	}
	pol[i++] = pArgs;
	
	// ���÷���
	pRes = PyEval_CallObject(pFun,pArgs);
	if ( pRes == NULL ) {
		ClearPyRef(pol,i);
		return(-1);
	}
	pol[i++] = pRes;
	
	// �����ز���ת��Ϊ�ַ���
	res = PyObjectToString(pRes,buf,bufsize);
	if (res){
		ClearPyRef(pol,i);
		return(-1);
	}
	
	// python ���͵��ַ�����ʾ <type '...'>
	// ȥ��<type '...'> �����������ƴ�
	len = strlen(buf);	
	for(j=0; j<len-9; j++){
		buf[j] = buf[j+7];
	}
	buf[j] = 0;
	
	ClearPyRef(pol,i);		
	return(0);

}


int PyConfigReadValue(char* file,char* var,char* bufValue,int bsValue,char * bufType,int bsType){
    
	int i=0,res;
	PyObject *pMod,*pFun,*pArgs,*pRes,*pol[50];	
	char * pStr=NULL;
	
	// ����ģ��
	pMod = PyImport_ImportModule("fxclient.mt4lib.config");
	if ( pMod == NULL ) {
		return (-1);		
	}
	pol[i++] = pMod;
	
	// ��λ����
	pFun = PyObject_GetAttrString(pMod,"ReadValue");
	if ( pFun == NULL ) {
		ClearPyRef(pol,i);
		return (-1);		
	}
    pol[i++] = pFun;

	// �����
	pArgs = Py_BuildValue("(s,s)",file,var);
	if ( pArgs == NULL ) {
		ClearPyRef(pol,i);
		return (-1);
	}
	pol[i++] = pArgs;

	// ���÷���
	pRes = PyEval_CallObject(pFun,pArgs);		
	if ( pRes == NULL ) {
		ClearPyRef(pol,i);
		return(-1);
	}
	pol[i++] = pRes;

	// �����ز���ת��Ϊ�ַ���
	res = PyObjectToString(pRes,bufValue,bsValue);
	if (res){
		ClearPyRef(pol,i);
		return(-1);
	}

	// ��ȡֵ����
	res = PyObjectType(pRes,bufType,bsType);
	if (res){
		ClearPyRef(pol,i);
		return(-1);
	}

	ClearPyRef(pol,i);   // �ͷ�python��������
	return(0);
}


__declspec( thread ) char bufPyConfigRead[1024];
char * PyConfigRead(char* file,char* var){
	int res;
	char bufValue[512],bufType[256];	
	
	LockCS(&_PyConfigRead); // ��������_PyConfigRead
	
	res = PyConfigReadValue(file,var,bufValue,sizeof(bufValue),bufType,sizeof(bufType));
	if (res != 0){
		strcpy(bufType,"NoneType");
		strcpy(bufValue,"None");
	}
	sprintf(bufPyConfigRead,"{'type':%s,'value':%s}",bufType,bufValue);
	
	UnlockCS(&_PyConfigRead); // �ͷű���_PyConfigRead
	return(bufPyConfigRead);
}





