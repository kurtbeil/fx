#property library


void WriteLog(int magic,string msg) {
	string timestamp = TimeToStr(TimeCurrent());
	string filename = "[magic=" + magic + "[symbol=" + Symbol()+ "].log";
	int handle=FileOpen(filename,FILE_READ|FILE_WRITE," ");
	if(handle>0) {
		FileSeek(handle, 0, SEEK_END);
		FileWrite(handle,timestamp,":", msg);
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


