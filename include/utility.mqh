


#import "utility.ex4"



bool IsFirstTick();



// 交易相关
int CreatePosition(string symbol,int cmd,double lots);
void ClosePosition(int ticket);
int PositionCount(string symbol,int cmd);


double StandardPointSize();



// 订单关闭队列功能
void PutTicketCloseQueue(int ticket);
void ClearTicketCloseQueue();

// 日志相关
void WriteLog(string msg) ;
void WriteData(string dataname,string data);

// 获取订单类型名称
string GetOrderTypeName(int ordertype);

