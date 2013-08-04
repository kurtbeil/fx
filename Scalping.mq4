
#include <utility.mqh>
#include <stdlib.mqh>

#define MAGIC  102

/*

---------------------------------------------------------------------------------------------------------
2013-08-04  一个初步可用把头皮交易方法
commit id : 267345753012947d87d7b07789c8d6582efd44cd
程序在HotForex市场中的数据（时间2013-05-23至2013-07-30），且使用点差10点（10万分点）或以下，
可以勉强获利，但是在我们所设定的交易时间范围内点差通常在30点左右。
疑问：在交易测试中，交易记录的开仓价和平仓价间的价差，要比系统计算获利值高出20点左右，目前尚
不知原因是什么，但观察“落雨”的交易记录也有发现类似情况，但其差别量小得多。
---------------------------------------------------------------------------------------------------------



*/


datetime lastBuyCreated =EMPTY;
datetime lastSellCreated =EMPTY;

double takeprofit = 5;
double stoploss = 15;


bool isTradingHour(){
   int hh24 = TimeHour(TimeCurrent());
   if ( hh24 == 23 || hh24 == 0 || hh24 == 1 || hh24 == 2 ) {      
   //if (  hh24 == 0 ) {      
      return (true);
   }else {
      return (false);
   }
}

void checkForClose(){
  bool ret;
  int ticket;
  for(int i=0;i<OrdersTotal();i++){    
    if( OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false ) continue;
    if( OrderMagicNumber()!=MAGIC ) continue;    
    if( OrderSymbol()!=Symbol() ) continue;        
    if(OrderType() == OP_BUY){
      if ( Bid-OrderOpenPrice() > takeprofit  * PointSize() || 
           OrderOpenPrice()-Bid > stoploss * PointSize() || 
           MinutesBetween(TimeCurrent(),lastBuyCreated) > 60 ) 
      {
         ClosePosition(OrderTicket());
         //writeOpenLog(OrderType()+","+TimeToStr(OrderOpenTime())+","+OrderOpenPrice()+","+TimeToStr(TimeCurrent())+","+Bid);
      }  
     
    }
    if(OrderType() == OP_SELL){
      if ( OrderOpenPrice() - Ask > takeprofit * PointSize() ||
           Ask-OrderOpenPrice() > stoploss * PointSize() ||
           MinutesBetween(TimeCurrent(),lastSellCreated) > 60 ) 
      {
         ClosePosition(OrderTicket());
         //writeOpenLog(OrderType()+","+TimeToStr(OrderOpenTime())+","+OrderOpenPrice()+","+TimeToStr(TimeCurrent())+","+Ask);
      }  
    }  
      
  }
}


double getLots() {
	return (0.1);
}


bool isSameHour(datetime dt1,datetime dt2) {
	string dt1str = StringSubstr(TimeToStr(dt1),0,13);
	string dt2str = StringSubstr(TimeToStr(dt2),0,13);
	if ( dt1str == dt2str ) {
		return (true);
	} else {
		return (false);
	}
}


/*
void writeOpenLog(string msg){
   int handle;
   string filename = "PositionLog.csv";
   string timestamp = TimeToStr(TimeCurrent());
   handle=FileOpen(filename,FILE_READ|FILE_WRITE," ");  
   if(handle>0)
   {
      FileSeek(handle, 0, SEEK_END);
      FileWrite(handle,timestamp,",", msg);     
      FileClose(handle );
   }
}
int init(){
   string filename = "PositionLog.csv";
   FileDelete(filename);
   int handle=FileOpen(filename,FILE_READ|FILE_WRITE|FILE_CSV ," "); 
   if(handle>0){
      FileSeek(handle, 0, SEEK_END);
      FileWrite(handle,"time,order_type,open_time,open_price,close_time,close_price");
      FileClose(handle );    
   } 
}
*/


void checkForOpen() {
	double rsi = iRSI(Symbol(),Period(),7,PRICE_CLOSE,0);
	int hh24 = TimeHour(TimeCurrent());
	if ( isTradingHour() ) {
		if ( lastBuyCreated == EMPTY || !isSameHour(TimeCurrent(),lastBuyCreated) ) {
			if ( rsi < 35 ) {
				// open a buy opsition
				lastBuyCreated = TimeCurrent();
				CreatePosition(Symbol(),OP_BUY,getLots(),MAGIC);
			}
		}
		if ( lastSellCreated == EMPTY || !isSameHour(TimeCurrent(),lastSellCreated) ) {
			if ( rsi > 65 ) {
				// open a sell opsition
				lastSellCreated = TimeCurrent();
				CreatePosition(Symbol(),OP_SELL,getLots(),MAGIC);
			}
		}

	}
}

bool isFirstTick() {
	static double LastVolume= -1 ;
	if (Volume[0] >= LastVolume && LastVolume != -1 ) {
		LastVolume = Volume[0];
		return(false);
	}
	LastVolume = Volume[0];
	return(true);
}



int start(){     
   if (isFirstTick()){
      checkForOpen();
   }
   checkForClose();  
}



