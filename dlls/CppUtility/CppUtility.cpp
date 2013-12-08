// CppUtility.cpp : Defines the entry point for the DLL application.
//


#include "stdafx.h"
#include "CppUtility.h"
#include <Python.h>


// 全局字符串变量的事务锁
CRITICAL_SECTION _StringParameter; 

// 生成ExecuteId的事务锁
CRITICAL_SECTION _GenerateExecuteId;

// 限价单队列的事务锁
CRITICAL_SECTION _LimitOrderQueue;

// python配置数据读取
CRITICAL_SECTION _PyConfigRead;


/*----------------------------------------------
--                输出日志过程                --
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
--                dll初始化过程               --
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
			// 初始化python运行环境
			Py_Initialize();
			// 初始化临界区变量
			InitializeCriticalSection(&_StringParameter);
			InitializeCriticalSection(&_GenerateExecuteId);
			InitializeCriticalSection(&_LimitOrderQueue);
			InitializeCriticalSection(&_PyConfigRead);			
			
			//remove(logfile);
			break;
		case DLL_THREAD_ATTACH:
		case DLL_THREAD_DETACH:			
		case DLL_PROCESS_DETACH:
			// 清理python运行环境			
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
--             自定义的关键区进出过程         --
-----------------------------------------------*/

void LockCS(CRITICAL_SECTION * cs){
	char logMsg[1204];	
	
	/*
	static i = 0;	
	if (i<100){
		sprintf(logMsg,"查看数据(befere enter):LockCount=%d,OwningThread=%d,CurThread=%d",cs->LockCount,cs->OwningThread,GetCurrentThreadId());
		WriteLog(logMsg);		
	}
	*/

	if(!TryEnterCriticalSection(cs)){
		// 执行到这里显然还是会将当前进程锁死
		// 我们只是希望在此之前记录下一些信息确定死锁确实发生在此处
		sprintf(logMsg,"发生死锁! LockCount=%d,OwningThread=%d,CurThread=%d,cs%0d",cs->LockCount,cs->OwningThread,GetCurrentThreadId());		
		WriteLog(logMsg);
		EnterCriticalSection(cs);
	}
	
	/*
	if (i<100){
		sprintf(logMsg,"查看数据(befere enter):LockCount=%d,OwningThread=%d,CurThread=%d",cs->LockCount,cs->OwningThread,GetCurrentThreadId());
		WriteLog(logMsg);
	}
	i++;	
	*/
}

void UnlockCS(CRITICAL_SECTION * cs){
	LeaveCriticalSection(cs);
}
 
/*----------------------------------------------
--              生成ExecuteId功能             --
-----------------------------------------------*/

MT4_EXPFUNC int __stdcall GenerateExecuteId(){	
	time_t t;
	LockCS(&_GenerateExecuteId); // 锁定函数GenerateExecuteId函数
	try{
		t = time(NULL);
		Sleep(1000);    // 保证下一个线程读取ExecuteId的时间是下一秒，这样不会发生重复
	}catch(...){}
	UnlockCS(&_GenerateExecuteId); // 释放函数GenerateExecuteId函数
	return (t);	
}


/*----------------------------------------------
--             全局字符串变量功能             --
-----------------------------------------------*/
// 保存全局字符串变量的map
map<int,map<string,string> > StringParameter;


MT4_EXPFUNC void __stdcall GlobalStringSet(int ExecuteId,char * name,char * value){
	LockCS(&_StringParameter); // 锁定变量StringParameter
	try{
		// 对应的ExecuteId是否已经建立起全局变量集
		if ( StringParameter.count(ExecuteId) <= 0){
			map<string,string> p;	
			StringParameter[ExecuteId] = p;	       //   注意这里是拷贝
		}
		StringParameter[ExecuteId][name] = value;  //   这里赋值实际上是通过value先创造出一个string
	}catch(...){}
	UnlockCS(&_StringParameter); // 释放变量StringParameter	 
}


MT4_EXPFUNC char* __stdcall GlobalStringGet(int ExecuteId,char * name){
	//static char buf[512];
	char * result = NULL;
	LockCS(&_StringParameter); // 锁定变量StringParameter
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
	UnlockCS(&_StringParameter); // 释放变量StringParameter 	
	return result;
}



/*----------------------------------------------
--        限价单功能辅助数据结构实现          --
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

// 存储限价单
map<int,queue<LimitOrder> > LimitOrderQueue;


MT4_EXPFUNC int CreateLimitOrder(int ExecuteId,char * symbol,int type,double price,double lots,int expdate,int createtime){
	LockCS(&_LimitOrderQueue);   // 锁定变量LimitOrderQueue
    LimitOrder order;
	try{
		if ( LimitOrderQueue.count(ExecuteId) <= 0){
			queue<LimitOrder> queue;	
			LimitOrderQueue[ExecuteId] = queue;	       //   注意这里是拷贝
		}		
		order.id = LimitOrderIdSeq++;
		order.symbol = symbol;
		order.type = type;
		order.price = price;
		order.lots = lots;
		order.expdate = expdate;
		order.createtime = createtime;
		LimitOrderQueue[ExecuteId].push(order);        //   注意这里是变量拷贝
	}catch(...){}
	UnlockCS(&_LimitOrderQueue); // 释放变量LimitOrderQueue 
	return(order.id);
}

MT4_EXPFUNC int GetLimitOrderCount(int ExecuteId){
	int result;
	LockCS(&_LimitOrderQueue);  // 锁定变量LimitOrderQueue
	try{	
		if ( LimitOrderQueue.count(ExecuteId) > 0){ 
			result = LimitOrderQueue[ExecuteId].size();
		}else{
			result = 0;
		}	
	}catch(...){}
	UnlockCS(&_LimitOrderQueue);  // 释放变量LimitOrderQueue 
	return(result);
}

MT4_EXPFUNC int GetLimitOrderId(int ExecuteId){
	int result;
	LockCS(&_LimitOrderQueue);  // 锁定变量LimitOrderQueue
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
	UnlockCS(&_LimitOrderQueue);  // 释放变量LimitOrderQueue 
	return(result);
}


MT4_EXPFUNC char * GetLimitOrderSymbol(int ExecuteId){
	char * result = NULL;
	LockCS(&_LimitOrderQueue);  // 锁定变量LimitOrderQueue
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
	UnlockCS(&_LimitOrderQueue);  // 释放变量LimitOrderQueue 
	return(result);
}

MT4_EXPFUNC int GetLimitOrderType(int ExecuteId){
	int result;
	LockCS(&_LimitOrderQueue);  // 锁定变量LimitOrderQueue
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
	UnlockCS(&_LimitOrderQueue);  // 释放变量LimitOrderQueue 
	return(result);
}

MT4_EXPFUNC double GetLimitOrderPrice(int ExecuteId){
	double result;
	LockCS(&_LimitOrderQueue);  // 锁定变量LimitOrderQueue
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
	UnlockCS(&_LimitOrderQueue);  // 释放变量LimitOrderQueue 
	return(result);
}

MT4_EXPFUNC double GetLimitOrderLots(int ExecuteId){
	double result;
	LockCS(&_LimitOrderQueue);  // 锁定变量LimitOrderQueue
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
	UnlockCS(&_LimitOrderQueue);  // 释放变量LimitOrderQueue 
	return(result);
}



MT4_EXPFUNC int GetLimitOrderExpdate(int ExecuteId){
	int result;
	LockCS(&_LimitOrderQueue);  // 锁定变量LimitOrderQueue
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
	UnlockCS(&_LimitOrderQueue);  // 释放变量LimitOrderQueue 
	return(result);
}


MT4_EXPFUNC int GetLimitOrderCreateTime(int ExecuteId){
	int result;
	LockCS(&_LimitOrderQueue);  // 锁定变量LimitOrderQueue
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
	UnlockCS(&_LimitOrderQueue);  // 释放变量LimitOrderQueue 
	return(result);
}


MT4_EXPFUNC void RemoveLimitOrder(int ExecuteId){
	LockCS(&_LimitOrderQueue);  // 锁定变量LimitOrderQueue
	try{	
		if ( LimitOrderQueue.count(ExecuteId) > 0){ 
			if(LimitOrderQueue[ExecuteId].size() > 0){
				LimitOrderQueue[ExecuteId].pop();  // 删除第1个数据
			}
		}
	}catch(...){}	
	UnlockCS(&_LimitOrderQueue);  // 释放变量LimitOrderQueue     
}

MT4_EXPFUNC void TurnLimitOrder(int ExecuteId){
	LockCS(&_LimitOrderQueue);  // 锁定变量LimitOrderQueue
	try{	
		if ( LimitOrderQueue.count(ExecuteId) > 0){ 
			if(LimitOrderQueue[ExecuteId].size() > 0){
				LimitOrderQueue[ExecuteId].push(LimitOrderQueue[ExecuteId].front());  // 将队列第1数据拷贝至队列最后
				LimitOrderQueue[ExecuteId].pop();         // 删除第1个数据
			}
		}
	}catch(...){}
	UnlockCS(&_LimitOrderQueue);  // 释放变量LimitOrderQueue 
}


/*----------------------------------------------
--        访问python配置文件相关功能          --
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
	
	// 导入模块
	pMod = PyImport_ImportModule("__builtin__");
	if ( pMod == NULL ) {
		return (-1);		
	}
	pol[i++] = pMod;

	// 定位方法
	pFun = PyObject_GetAttrString(pMod,"str");
	if ( pFun == NULL ) {
		ClearPyRef(pol,i);
		return (-1);		
	}
    pol[i++] = pFun;
	
	// 准备参数
	pArgs = Py_BuildValue("(O)",pObj);
	if ( pArgs == NULL ) {
		ClearPyRef(pol,i);
		return (-3);
	}
	pol[i++] = pArgs;
	
	// 调用方法
	pRes = PyEval_CallObject(pFun,pArgs);
	if ( pRes == NULL ) {
		ClearPyRef(pol,i);
		return(-1);
	}
	pol[i++] = pRes;

	// 获取返回参数
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

// 注意:该函数不能直接调用在MT4过程中调用
int PyObjectType(PyObject * pObj,char * buf,int bufsize){
	
	int i=0,j,res,len;
	PyObject *pMod,*pFun,*pArgs,*pRes,*pol[50];	
	char * pStr=NULL;

	// 导入模块
	pMod = PyImport_ImportModule("__builtin__");
	if ( pMod == NULL ) {
		return (-1);		
	}
	pol[i++] = pMod;

	// 定位方法
	pFun = PyObject_GetAttrString(pMod,"type");
	if ( pFun == NULL ) {
		ClearPyRef(pol,i);
		return (-1);		
	}
    pol[i++] = pFun;
	
	// 准备参数
	pArgs = Py_BuildValue("(O)",pObj);
	if ( pArgs == NULL ) {
		ClearPyRef(pol,i);
		return (-3);
	}
	pol[i++] = pArgs;
	
	// 调用方法
	pRes = PyEval_CallObject(pFun,pArgs);
	if ( pRes == NULL ) {
		ClearPyRef(pol,i);
		return(-1);
	}
	pol[i++] = pRes;
	
	// 将返回参数转化为字符串
	res = PyObjectToString(pRes,buf,bufsize);
	if (res){
		ClearPyRef(pol,i);
		return(-1);
	}
	
	// python 类型的字符串表示 <type '...'>
	// 去掉<type '...'> 保留类型名称串
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
	
	// 导入模块
	pMod = PyImport_ImportModule("fxclient.mt4lib.config");
	if ( pMod == NULL ) {
		return (-1);		
	}
	pol[i++] = pMod;
	
	// 定位方法
	pFun = PyObject_GetAttrString(pMod,"ReadValue");
	if ( pFun == NULL ) {
		ClearPyRef(pol,i);
		return (-1);		
	}
    pol[i++] = pFun;

	// 邦定参数
	pArgs = Py_BuildValue("(s,s)",file,var);
	if ( pArgs == NULL ) {
		ClearPyRef(pol,i);
		return (-1);
	}
	pol[i++] = pArgs;

	// 调用方法
	pRes = PyEval_CallObject(pFun,pArgs);		
	if ( pRes == NULL ) {
		ClearPyRef(pol,i);
		return(-1);
	}
	pol[i++] = pRes;

	// 将返回参数转化为字符串
	res = PyObjectToString(pRes,bufValue,bsValue);
	if (res){
		ClearPyRef(pol,i);
		return(-1);
	}

	// 读取值类型
	res = PyObjectType(pRes,bufType,bsType);
	if (res){
		ClearPyRef(pol,i);
		return(-1);
	}

	ClearPyRef(pol,i);   // 释放python变量引用
	return(0);
}


__declspec( thread ) char bufPyConfigRead[1024];
char * PyConfigRead(char* file,char* var){
	int res;
	char bufValue[512],bufType[256];	
	
	LockCS(&_PyConfigRead); // 锁定变量_PyConfigRead
	
	res = PyConfigReadValue(file,var,bufValue,sizeof(bufValue),bufType,sizeof(bufType));
	if (res != 0){
		strcpy(bufType,"NoneType");
		strcpy(bufValue,"None");
	}
	sprintf(bufPyConfigRead,"{'type':%s,'value':%s}",bufType,bufValue);
	
	UnlockCS(&_PyConfigRead); // 释放变量_PyConfigRead
	return(bufPyConfigRead);
}





