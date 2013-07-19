
#include <utility.mqh>

/*
1、不是所有的市场都支持多空双向开仓的


*/




#define MAGIC  102

int lastBuyCreated =EMPTY;
int lastSellCreated =EMPTY;


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
      if ( Bid-OrderOpenPrice() > 5 * PointSize() || Bid-OrderOpenPrice() < -15 * PointSize() ) {
         ClosePosition(OrderTicket());
      }  
    }
    if(OrderType() == OP_SELL){
      if ( OrderOpenPrice() - Ask > 5 * PointSize() || OrderOpenPrice() - Ask < -15 * PointSize() ) {
         ClosePosition(OrderTicket());
      }  
    }    
  }
}

double getLots(){
   return (0.1);
}

void checkForOpen(){
   double rsi = iRSI(Symbol(),Period(),7,PRICE_CLOSE,0);
   int hh24 = TimeHour(TimeCurrent());
   if ( isTradingHour() ) {
      if ( lastBuyCreated == EMPTY && lastBuyCreated != hh24) {
         if ( rsi < 30 ) {
            // open a buy opsition  
            lastBuyCreated = hh24;
            CreatePosition(Symbol(),OP_BUY,getLots(),MAGIC);
         }      
      }
      if ( lastSellCreated == EMPTY && lastSellCreated != hh24) {
         if ( rsi > 70 ) {
            // open a sell opsition
            lastSellCreated = hh24;
            CreatePosition(Symbol(),OP_SELL,getLots(),MAGIC);
         } 
      }
   }   
}

int start(){     
   checkForOpen();
   checkForClose();
}

