

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



int start() {	
	ObjectsDeleteAll();
	//ObjectCreate("text_object", OBJ_ARROW, 0, Time[1], Ask);
	//ObjectSet("MyFibo", OBJPROP_ARROWCODE, );
	//int ticket = CreatePosition(Symbol(),OP_SELL,0.01);
	//ClosePosition(ticket);
	
	//CreateOpenArrow("open",OP_SELL,Time[10],Bid);
	//CreateCloseArrow("close",OP_SELL,Time[0],Ask);	
	//CreatePositionLine("line",OP_SELL,Time[10],Bid,Time[0],Ask);
	
	
	DrawPosition(123,Symbol(),0.05,OP_SELL,Time[10],Bid,Time[0],Ask);
	
}