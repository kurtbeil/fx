


#import "utility.ex4"


//void log(string filename,string msg);
int CreatePosition(string symbol,int cmd,double lots,int magic);
void ClosePosition(int ticket);
int PositionCount(string symbol,int cmd,int magic);
double StandardPointSize();
bool IsFirstTick();

void PutTicketCloseQueue(int ticket);
void ClearTicketCloseQueue();