

#include <CppUtility.mqh>
#include <common.mqh>
#include <utility.mqh>
#property show_confirm


int init() {
	//OnInitBegin(WindowExpertName());
	return(0);
}

int deinit(){	
	//OnDeinitEnd();
}

void test(int a=0){
	Print("a=",a);	
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
	test(1);
		

}