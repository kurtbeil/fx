

#include <CppUtility.mqh>
#include <common.mqh>
#include <utility.mqh>
#include <stdlib.mqh>
#property show_confirm


int init() {
	//OnInitBegin(WindowExpertName());
	return(0);
}

int deinit(){	
	//OnDeinitEnd();
}


double GetSlipPoints() {
	return (StandardPointSize()*3/Point);
}

// magic 参数需要去掉了 顺带需要修改 scalping.mq4,  GetSlipPoints 也需要修改
int CreateLimitOrder(string symbol,int cmd,double price,double lots, double stoploss, double takeprofit,datetime expiration) {
	int magic = GetExecuteId();
	int ticket=-1;
	if (cmd==OP_BUYLIMIT) {
		ticket = OrderSend(symbol,OP_BUYLIMIT,lots,price,GetSlipPoints(),stoploss,takeprofit,"",magic,expiration,Blue);
	}
	if (cmd==OP_SELLLIMIT) {
		ticket = OrderSend(symbol,OP_SELLLIMIT,lots,price,GetSlipPoints(),stoploss,takeprofit,"",magic,expiration,Red);
	}
	return (ticket);
}

int start() {	
	//Print("WindowExpertName=",WindowExpertName());
	//Print("StopOut level = ", AccountStopoutLevel());
	//Print("STOPLEVEL= ", MarketInfo(Symbol(),MODE_STOPLEVEL));
	//Print("Point="+Point);
	//Print("GetSymbolStopLevelSize="+GetSymbolStopLevelSize(Symbol()));


      /*
	int total=OrdersTotal();
	for(int i=0; i<total; i++) {		
		if( OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false ) continue;
		Print("OrderTicket="+OrderTicket());	
		Print("OrderStopLoss="+OrderStopLoss());	
		OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-StandardPointSize()*40,OrderTakeProfit(),0);
	}
	*/
	//test(1);
	//int ticket=CreateLimitOrder(Symbol(),OP_BUYLIMIT,Bid-StandardPointSize()*10,0.01,0,0,TimeCurrent()+10);
	
	double price = Bid-StandardPointSize()*2;
	double stoploss = price - StandardPointSize() * 10;
	double takeprofit = price + StandardPointSize() * 4;
	int ticket=CreateLimitOrder(Symbol(),OP_BUYLIMIT,price,0.01,stoploss,takeprofit,TimeCurrent()+60*11);
	Print("ticket=",ticket);
	Print("OrderSend failed with error #",GetLastError());

	Print("OP_BUY="+MinutesBetween(TimeCurrent(),GetLastPositionOpenTime(Symbol(),OP_BUY)));	
	Print("OP_BUYLIMIT="+MinutesBetween(TimeCurrent(),GetLastPositionOpenTime(Symbol(),OP_BUYLIMIT)));	
	
	
	
	Print("GetExecuteId()=",GetExecuteId());
	

}