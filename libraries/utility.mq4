#property library

#include <common.mqh>


string GetFileStamp() {
	string stamp =  "(" +
	                "ExecuteId=" + GetExecuteId()  +
	                ",Expert=" + GetMainExpertName()+
					",Symbol=" + Symbol()+
					",Period=" + Period()+											
	                ",Account=" + AccountNumber()  +
	                ",AccountServer=" + AccountServer() +					
	                // ",AccountName=" + AccountName()  +
	                // ",TerminalName=" + TerminalName() +
	                ")" ;
	return (stamp);
}

void WriteLog(string msg) {
	string timestamp = TimeToStr(TimeCurrent());
	string filename =  GetFileStamp() + ".log";
	int handle=FileOpen(filename,FILE_READ|FILE_WRITE," ");
	if(handle>0) {
		FileSeek(handle, 0, SEEK_END);
		FileWrite(handle,timestamp,":", msg);
		FileClose(handle );
	}
}

void WriteData(string dataname,string data) {
	string timestamp = TimeToStr(TimeCurrent());
	string filename =  dataname+ GetFileStamp() + ".csv";
	int handle=FileOpen(filename,FILE_READ|FILE_WRITE," ");
	if(handle>0) {
		FileSeek(handle, 0, SEEK_END);
		FileWrite(handle,data);
		FileClose(handle );
	}
}

int PositionCount(string symbol,int cmd,int magic) {
	int cnt=0;
	for( int i=0; i<OrdersTotal(); i++ ) {
		if ( OrderSelect(i,SELECT_BY_POS,MODE_TRADES) == false ) break;
		if ( OrderSymbol() != symbol ) continue;
		if ( magic != -1 && OrderMagicNumber() != magic ) continue;
		if ( OrderType() == cmd ) cnt++ ;
	}
	return(cnt);
}

double StandardPointSize() {
	return (0.0001);
}

double GetSlipPoints() {
	return (StandardPointSize()*3/Point);
	//return (0);
}

int CreatePosition(string symbol,int cmd,double lots,int magic) {
	int ticket;
	if (cmd==OP_BUY) {
		ticket = OrderSend(symbol,OP_BUY,lots,Ask,GetSlipPoints(),0,0,"",magic,0,Blue);
	}
	if (cmd==OP_SELL) {
		ticket = OrderSend(symbol,OP_SELL,lots,Bid,GetSlipPoints(),0,0,"",magic,0,Red);
	}
	return (ticket);
}


void ClosePosition(int ticket) {
	bool ret;
	int i=10;
	if (OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)==false) {
		return;
	}
	while (i>0) {
		if(OrderType()==OP_BUY) {
			ret = OrderClose(OrderTicket(),OrderLots(),Bid,GetSlipPoints(),Blue);
		}
		if(OrderType()==OP_SELL) {
			ret = OrderClose(OrderTicket(),OrderLots(),Ask,GetSlipPoints(),Red);
		}
		if (!ret) {
			Sleep(10000);
			RefreshRates();
		} else {
			return;
		}
		i--;
	}
}

// 判断是否是第1跳
bool IsFirstTick() {
	static string last_timestamp = "1970.01.01 00:00";
	string timestamp = TimeToStr(TimeCurrent());
	bool result=false;
	if(timestamp!=last_timestamp) {
		result = true;
	}
	last_timestamp = timestamp;
	return(result);
}


// 头寸关闭队列
static int TicketCloseQueue [1000];
static int TicketCloseQueue_Count = 0;

void PutTicketCloseQueue(int ticket) {
	int i = TicketCloseQueue_Count;
	TicketCloseQueue[i] = ticket;
	TicketCloseQueue_Count ++;
}

void ClearTicketCloseQueue() {
	for(int i=0; i<TicketCloseQueue_Count; i++) {
		int ticket = TicketCloseQueue[i];
		ClosePosition(ticket);
	}
	TicketCloseQueue_Count = 0;
}



