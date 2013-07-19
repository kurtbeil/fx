
#include <utility.mqh>
#include <stdlib.mqh>

#define MAGIC  102

datetime lastBuyCreated =EMPTY;
datetime lastSellCreated =EMPTY;

double takeprofit = 5;
double stoploss = 15;

bool isTradingHour(){
   int hh24 = TimeHour(TimeCurrent());
   if ( hh24 == 23 || hh24 == 0 || hh24 == 1 || hh24 == 2 ) {      
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
      }  
     
    }
    if(OrderType() == OP_SELL){
      if ( OrderOpenPrice() - Ask > takeprofit * PointSize() ||
           Ask-OrderOpenPrice() > stoploss * PointSize() ||
           MinutesBetween(TimeCurrent(),lastSellCreated) > 60 ) 
      {
         ClosePosition(OrderTicket());
      }  
    }  
      
  }
}

double getLots(){
   return (0.1);
}

bool isSameHour(datetime dt1,datetime dt2){
   string dt1str = StringSubstr(TimeToStr(dt1),0,13);
   string dt2str = StringSubstr(TimeToStr(dt2),0,13);
   if ( dt1str == dt2str ) {
      return (true);
   }else{
      return (false);
   }
}


void checkForOpen(){
   double rsi = iRSI(Symbol(),Period(),7,PRICE_CLOSE,0);
   int hh24 = TimeHour(TimeCurrent());
   if ( isTradingHour() ) {
      if ( lastBuyCreated == EMPTY || !isSameHour(TimeCurrent(),lastBuyCreated) ) {
         if ( rsi < 30 ) {
            // open a buy opsition  
            lastBuyCreated = TimeCurrent();
            CreatePosition(Symbol(),OP_BUY,getLots(),MAGIC);
         }      
      }
      if ( lastSellCreated == EMPTY || !isSameHour(TimeCurrent(),lastSellCreated) ) {
         if ( rsi > 70 ) {
            // open a sell opsition
            lastSellCreated = TimeCurrent();
            //CreatePosition(Symbol(),OP_SELL,getLots(),MAGIC);
         } 
      }
       
   }   
}

bool isFirstTick(){
   static double LastVolume= -1 ;  
   if (Volume[0] >= LastVolume && LastVolume != -1 ){
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

