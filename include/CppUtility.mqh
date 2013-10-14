#import "CppUtility.ex4"

// 获取ExecuteId
int CppGenerateExecuteId();

// 设置读取全局字符串变量
string CppGlobalStringGet(string name);
string CppGlobalStringSet(string name,string value);

// 近距离限价单功能的数据结构支持
void CppCreateLimitOrder(int type,double price,int expdate);
int CppGetLimitOrderCount();
int CppGetLimitOrderType();
double CppGetLimitOrderPrice();
int CppGetLimitOrderExpdate();
void CppRemoveLimitOrder();
void CppTurnLimitOrder();
