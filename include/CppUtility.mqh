#import "CppUtility.ex4"

// 获取ExecuteId
int CppGenerateExecuteId();

// 设置读取全局字符串变量
string CppGlobalStringGet(string name);
string CppGlobalStringSet(string name,string value);

// 近距离限价单功能的数据结构支持
void CppCreateLimitOrder(string symbol,int type,double price,double lots,int expdate);
int CppGetLimitOrderCount();
int CppGetLimitOrderId();
string CppGetLimitOrderSymbol();
int CppGetLimitOrderType();
double CppGetLimitOrderPrice();
double CppGetLimitOrderLots();
int CppGetLimitOrderExpdate();
void CppRemoveLimitOrder();
void CppTurnLimitOrder();
int CppGetLimitOrderCountBy(string symbol,int  cmd) ;
int CppGetLastLimitOrderCrtTimeBy(string symbol,int  cmd);


// 配置文件读取
string CppPyConfigRead(string file,string var);
string CppPyResultReadType(string PyResult);
string CppPyResultReadValue(string PyResult);
double CppPyConfigReadDouble(string file,string var,double df);
int CppPyConfigReadInt(string file,string var,int df);

