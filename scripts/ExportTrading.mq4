#property show_confirm
#include <utility.mqh>
#include <common.mqh>


int init() {
	OnInitBegin(WindowExpertName());
}



int start() {
	string head = "Ticket,Symbol,OpenTime,Type,Lots,OpenPrice,StopLoss,TakeProfit,CloseTime,ClosePrice,Commission,Swap,Profit,OrderComment,MagicNumber,Expiration";
	WriteData("trading",head);
	int total=OrdersHistoryTotal();
	for(int i=0; i<total; i++) {
		if( OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)==false ) continue;
		string  msg = ""+OrderTicket()+","+OrderSymbol()+","+TimeToStr(OrderOpenTime())+","+GetOrderTypeName(OrderType())+","+ OrderLots()+","+OrderOpenPrice()+","+OrderStopLoss()+","+OrderTakeProfit()+"," +
		              TimeToStr(OrderCloseTime()) +"," +OrderClosePrice()+"," +OrderCommission()+"," + OrderSwap()+"," +OrderProfit()+"," +OrderComment()+"," +OrderMagicNumber()+"," +
		              TimeToStr(OrderExpiration( ) );					  
	    WriteData("trading",msg);
	}	
	
}