

#include <CppUtility.mqh>
#include <common.mqh>
#include <utility.mqh>

#property show_confirm


int init() {
	//OnInitBegin(WindowExpertName());
	return(0);
}

int deinit() {
	//OnDeinitEnd();
}



int start() {
	Print("--------------------- TradingHistory begin ---------------------");
	int cnt = OrdersHistoryTotal();
	for(int i=0; i<cnt; i++) {
		if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY )==false) break;
		if( OrderSymbol() == Symbol()  && OrderOpenTime() >= Time[Bars-1] ) {
			if ( OrderType() == OP_BUY || OrderType() == OP_SELL ) {
				DrawPosition( //
				    OrderTicket(),	OrderSymbol(), OrderType(),	OrderLots(),
				    OrderOpenTime(),OrderOpenPrice(),	OrderCloseTime(),OrderClosePrice()
				);
			}
		}
	}
	Print("--------------------- TradingHistory end ---------------------");
}