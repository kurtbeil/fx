


#import "utility.ex4"



bool IsFirstTick();



// 交易相关
int CreatePosition(string symbol,int cmd,double lots);
void ClosePosition(int ticket);
double StandardPointSize();
double GetSymbolStopLevelSize(string symbol);
int PositionCount(string symbol,int cmd);
datetime GetLastPositionOpenTime(string symbol,int cmd);


// 订单关闭队列功能
void PutTicketCloseQueue(int ticket);
void ClearTicketCloseQueue();

// 日志相关
void WriteLog(string msg) ;
void WriteData(string dataname,string data);

// 获取订单类型名称
string GetOrderTypeName(int ordertype);


// 头寸绘制
int GetPositionColor(int ordertype);
void CreateOpenArrow(string objectname,int ordertype,datetime  time,double price);
void CreateCloseArrow(string objectname,int ordertype,datetime  time,double price);
void CreatePositionLine(string objectname,int ordertype,datetime  t1,double p1,datetime  t2,double p2) ;
void DrawPosition(int orderticket,string symbol,int ordertype,double lots,datetime  t1,double p1,datetime  t2,double p2) ;



