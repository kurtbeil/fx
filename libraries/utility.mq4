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


double StandardPointSize() {
	return (0.0001);
}

double GetSlipPoints() {
	return (StandardPointSize()*3/Point);
	//return (0);
}

double GetSymbolSlipPoints(string symbol) {
	double slip = StandardPointSize()*3/Point;
	if ( symbol == "EURCAD" ) {
		slip = StandardPointSize()*2/Point;
	}
	return(slip);
}


// magic 参数需要去掉了  顺带需要修改 scalping.mq4  GetSlipPoints 也需要修改
int PositionCount(string symbol,int cmd) {
	int magic = GetExecuteId();
	int cnt=0;
	for( int i=0; i<OrdersTotal(); i++ ) {
		if ( OrderSelect(i,SELECT_BY_POS,MODE_TRADES) == false ) break;
		if ( OrderSymbol() != symbol ) continue;
		if ( magic != -1 && OrderMagicNumber() != magic ) continue;
		if ( OrderType() == cmd ) cnt++ ;
	}
	return(cnt);
}


// magic 参数需要去掉了 顺带需要修改 scalping.mq4,  GetSlipPoints 也需要修改
int CreatePosition(string symbol,int cmd,double lots) {
	int magic = GetExecuteId();
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

string GetOrderTypeName(int ordertype) {
	string result;
	switch(ordertype) {
	case OP_BUY:
		result = "BUY";
		break;
	case OP_SELL :
		result = "SELL";
		break;
	case OP_BUYLIMIT :
		result = "BUYLIMIT";
		break;
	case OP_BUYSTOP :
		result = "BUYSTOP";
		break;
	case OP_SELLLIMIT :
		result = "SELLLIMIT";
		break;
	case OP_SELLSTOP :
		result = "SELLSTOP";
		break;
	default:
		result="NULL";
	}
	return (result);
}


int GetPositionColor(int ordertype) {
	int pcolor=Blue;
	if (ordertype==OP_BUY) {
		pcolor = Blue;
	}
	if (ordertype==OP_SELL) {
		pcolor = Red;
	}
	return(pcolor);
}

void CreateOpenArrow(string objectname,int ordertype,datetime  time,double price) {
	ObjectCreate(objectname, OBJ_ARROW, 0, time, price);
	ObjectSet(objectname, OBJPROP_ARROWCODE, 1);
	ObjectSet(objectname, OBJPROP_COLOR, GetPositionColor(ordertype));
}

void CreateCloseArrow(string objectname,int ordertype,datetime  time,double price) {
	ObjectCreate(objectname, OBJ_ARROW, 0, time, price);
	ObjectSet(objectname, OBJPROP_ARROWCODE, 3);
	ObjectSet(objectname, OBJPROP_COLOR, GetPositionColor(ordertype));
}

void CreatePositionLine(string objectname,int ordertype,datetime  t1,double p1,datetime  t2,double p2) {
	ObjectCreate(objectname, OBJ_TREND, 0,  t1, p1,t2, p2);
	ObjectSet(objectname, OBJPROP_STYLE, STYLE_DOT);
	ObjectSet(objectname, OBJPROP_RAY, False);
	ObjectSet(objectname, OBJPROP_COLOR, GetPositionColor(ordertype));
}

void DrawPosition(int orderticket,string symbol,int ordertype,double lots,datetime  t1,double p1,datetime  t2,double p2) {
	string openarrow = "#"+orderticket+" " + GetOrderTypeName(ordertype) + " " + DoubleToStr(lots,2)+  " "+symbol+" at " + DoubleToStr(p1,5);
	string closearrow = "#" + orderticket + " " +  GetOrderTypeName(ordertype)+" " + DoubleToStr(lots,2)+ " "+symbol+" at "+p1+" close at "+DoubleToStr(p2,5);
	string line = "#" + orderticket +" " + DoubleToStr(p1,5)+  " -> " + DoubleToStr(p2,5);
	CreateOpenArrow(openarrow,ordertype,t1,p1);
	CreateCloseArrow(closearrow,ordertype,t2,p2);
	CreatePositionLine(line,ordertype,t1,p1,t2,p2);	
}


