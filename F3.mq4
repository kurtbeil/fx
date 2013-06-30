//+------------------------------------------------------------------+
//|                                               Moving Average.mq4 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+

/*
1¡¢Ò»´ÎÐÔÍ¶Èë10000ºÍ·Ö10´ÎÐÔÍ¶Èë1000ÓÐÊ²Ã´Çø±ð£¬¾¿¾¹ÊÇ³ÌÐòÎÊÌâ»¹ÊÇ×Ê½ð¹ÜÀíµÄ²îÒì
2¡¢¿¼ÂÇÈÕÏßµÄÆ½¾ù³¤¶ÈºÍÖ¹Ëð¼äµÄ¹ØÏµ
3¡¢Ê¹ÓÃrsi14¹ýÂËÔÚÍ¼±íÉÏ¿´Ð§¹û»¹ÊÇ²»´íµÄÎªºÎµ½ÁËÊµ¼Ê½»Ò×Ð§¹ûºÜ²î
*/

// add a text 
//add text 2



#define MAGICMA  20120729
#define TEND_UP  1
#define TEND_DOWN  -1
#define TEND_NULL  0
#define SIGNAL_BUY 1
#define SIGNAL_SELL -1
#define SIGNAL_NULL 0

double MovingPeriod       = 24;
double MovingShift         = 6;
double MaximumRisk       = 0.05;
double Lots = 1;

double DecreaseFactor     = 3;

int Signal = SIGNAL_NULL;
int Signal_TTL = 0;
//bool Signal_Used = false;
int Signal_Ticket = -1;

// get the tend 

int getTend(){
  int emaFast=12,emaSlow=26,sPeriod=9,tend=TEND_NULL;  
  double macd[3],signal[3],hist[3];  
  for(int i=1; i<=2; i++){
    macd[i]=iMACD(Symbol(),PERIOD_W1,emaFast,emaSlow,sPeriod,PRICE_CLOSE,MODE_MAIN,i);
    signal[i]=iMACD(Symbol(),PERIOD_W1,emaFast,emaSlow,sPeriod,PRICE_CLOSE,MODE_SIGNAL,i);
    hist[i]=macd[i]-signal[i];    
  }
  //Print("hist[1]=",hist[1]);
  //Print("hist[2]=",hist[2]);
  if(hist[1]>hist[2]) tend=TEND_UP;
  if(hist[1]<hist[2]) tend=TEND_DOWN;  
  //Print("macd[1]",macd[1]);
  //Print("macd[2]",macd[2]);
  return (tend); 
}



/*
int getTend(){
  int emaPeriod=13,emaShift=0,tend=TEND_NULL;
  double ema[3];  
  for(int i=1; i<=2; i++){
    ema[i]=iMA(Symbol(),PERIOD_D1,emaPeriod,emaShift,MODE_EMA,PRICE_CLOSE,i); 
  }
  if(ema[1]>ema[2]) tend=TEND_UP;
  if(ema[1]<ema[2]) tend=TEND_DOWN;  
  return (tend); 
}
*/


/*
int getSignalBy(int shift){
  int movingPeriod=12,movingShift=6,i=shift+1,signal=SIGNAL_NULL;
  double ma=iMA(Symbol(),PERIOD_D1,movingPeriod,movingShift,MODE_SMA,PRICE_CLOSE,i);    
  if(Open[i]>ma && Close[i]<ma) signal=SIGNAL_BUY;
  if(Open[i]<ma && Close[i]>ma) signal=SIGNAL_SELL;  
  return(signal);    
}
*/
int getSignalBy(int shift){
  int movingPeriod=1,i=shift+1,signal=SIGNAL_NULL;
  double f0=iForce(Symbol(),PERIOD_D1,movingPeriod,MODE_EMA,PRICE_CLOSE,i);    
  double f1=iForce(Symbol(),PERIOD_D1,movingPeriod,MODE_EMA,PRICE_CLOSE,i+1);    
  if(f1>0&&f0<0) signal=SIGNAL_BUY;
  if(f1<0&&f0>0) signal=SIGNAL_SELL;  
  //Print("f0",f0);
  //Print("f1",f1);
  return(signal);    
}



/*
int getSignal(){
  int rsiPeriod=14;
  double rsi,r_buy=40,r_sell=60;
  rsi = iRSI(Symbol(),PERIOD_D1,rsiPeriod,PRICE_CLOSE,0);    
  if (Signal== SIGNAL_BUY&& rsi >= r_buy ) return(SIGNAL_BUY);
  if (Signal== SIGNAL_SELL&& rsi <= r_sell ) return(SIGNAL_SELL);
  return (SIGNAL_NULL);
}
*/



int getSignal(){
  return (Signal);
}


/*
bool useSignal(){
  bool res = !Signal_Used;
  Signal_Used = true;
  return (res);
}
*/

void markSignal(int signal,int ttl){
  Signal = signal;
  Signal_TTL = ttl;
  //Signal_Used = false;
  Signal_Ticket = -1;
}

void weakenSignal(){
  int tend = getTend();
  // Èç¹ûÇ÷ÊÆ·¢Éú±ä»¯Ä¨µôµ±Ç°ÐÅºÅ
  if ( (tend==TEND_UP && Signal==SIGNAL_SELL) || 
       (tend==TEND_DOWN && Signal==SIGNAL_BUY) || 
        tend==TEND_NULL){
    Signal = SIGNAL_NULL;  
    Signal_TTL = 0;   
  }
  // ÐÅºÅË¥¼õ
  if ( Signal_TTL >= 0 ) {
    Signal_TTL--; 
    if ( Signal_TTL==0 ) Signal = SIGNAL_NULL; 
  } 
}

void maintainSignal(){
  int tend,signal,ttl=4;   
  weakenSignal();
  tend = getTend();  
  if ( tend != TEND_NULL && Signal==SIGNAL_NULL){    
    for(int i=0; i<=2; i++,ttl--){
      signal = getSignalBy(i);
      if (signal!=SIGNAL_NULL) break;        
    }   
    if ( (tend==TEND_UP && signal==SIGNAL_BUY) || 
         (tend==TEND_DOWN && signal==SIGNAL_SELL ) )
      markSignal(signal,ttl);       
  }
}

void cleanupPosition(){
  for(int i=0;i<OrdersTotal();i++){
    if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
    if(OrderSymbol()==Symbol() && OrderMagicNumber()!=MAGICMA) continue;
    if(OrderType() == OP_BUYSTOP || OrderType() == OP_SELLSTOP){
      OrderDelete(OrderTicket());
      if (OrderTicket()==Signal_Ticket) Signal_Ticket = -1;
    }
    if(( OrderType() == OP_BUY && getTend()== TEND_DOWN ) ||
        ( OrderType() == OP_SELL && getTend()== TEND_UP ))
      ClosePositionByTicket(OrderTicket());
  }
}
void setupPosition(){
  int signal = getSignal();
  double price,pi = 0.0042;
  //Print("getTend=",getTend());
  if (signal != SIGNAL_NULL){  
    if (Signal_Ticket==-1){ 
      if(signal==SIGNAL_BUY){
        price = iHigh(Symbol(),PERIOD_D1,1) + pi;
        Signal_Ticket=OrderSend(Symbol(),OP_BUYSTOP,getLots(),price,0,0,0,"",MAGICMA,0,Blue);
      }
      if(signal==SIGNAL_SELL){
        price = iLow(Symbol(),PERIOD_D1,1) - pi;
        Signal_Ticket=OrderSend(Symbol(),OP_SELLSTOP,getLots(),price,0,0,0,"",MAGICMA,0,Red);
      }
    }    
  }
}

void adjustStopLoss(){
  double stoploss,pi = 0.0073,minsl=0.0010;
  for(int i=0;i<OrdersTotal();i++){
    if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
    if(OrderSymbol()==Symbol() && OrderMagicNumber()!=MAGICMA) continue;    
    if(OrderType()==OP_BUYSTOP || OrderType()== OP_BUY ) {
      stoploss = iLow(Symbol(),PERIOD_D1,1) - pi;
      if(OrderType()==OP_BUYSTOP)
        if (stoploss>OrderOpenPrice()-minsl)stoploss=OrderOpenPrice()-minsl;        
      if(OrderType()==OP_BUY)
        if (stoploss>Bid-minsl)stoploss=Bid-minsl;            
      if(stoploss>OrderStopLoss()||OrderStopLoss()==0)//Âòµ¥µÄÖ¹ËðÏß²»ÄÜÏòÏÂµ÷
        OrderModify(OrderTicket(),OrderOpenPrice(),stoploss,OrderTakeProfit(),0,Blue);
    }    
    if(OrderType()==OP_SELLSTOP || OrderType()== OP_SELL){
      stoploss = iHigh(Symbol(),PERIOD_D1,1) + pi;
      if(OrderType()==OP_SELLSTOP)
        if (stoploss<OrderOpenPrice()+minsl)stoploss=OrderOpenPrice()+minsl;
      if(OrderType()==OP_SELL)
        if (stoploss<Ask+minsl)stoploss=Ask+minsl;
      if(stoploss<OrderStopLoss()||OrderStopLoss()==0){ // Âòµ¥µÄÖ¹ËðÏß²»ÄÜÏòÉÏµ÷
        OrderModify(OrderTicket(),OrderOpenPrice(),stoploss,OrderTakeProfit(),0,Red);              
      }
    }        
  }
}

void maintainPosition(){  
  cleanupPosition();
  setupPosition();
  adjustStopLoss();
}

void start()
{ 
  maintainSignal();
  maintainPosition();   
}  


void ClosePositionByTicket(int ticket){
  if (OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)==false) {
    Print("Order is not found");
    return;
  }
  if(OrderType()==OP_BUY){
    OrderClose(OrderTicket(),OrderLots(),Bid,3,Blue);
  }
    if(OrderType()==OP_SELL){
    OrderClose(OrderTicket(),OrderLots(),Ask,3,Red);
  }
}

double getLots(){
  double lots;     
  lots = AccountBalance()/AccountLeverage()/150;
  //Print("ptsRisk=",ptsRisk);      
  //Print("AccountBalance()=",AccountBalance());      
  //Print("AccountLeverage()=",AccountLeverage());      
  //Print("MaximumRisk=",MaximumRisk);  
  if(lots>1) lots=MathSqrt(lots);  
  lots = lots;
  if(lots<0.1) lots=0.1;  
  return (lots);  
}

/*

int OrderCount(int iOrderType){    
  int cnt=0;  
  for(int i=0;i<OrdersTotal();i++){
    if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
    if(OrderSymbol()==Symbol() && OrderMagicNumber()==MAGICMA){
      if(OrderType()==iOrderType)cnt++;
    }
  }
  return(cnt);
}

void ClosePosition(int iOrderType){
  for(int i=0;i<OrdersTotal();i++){
    if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false)break;
    if(OrderMagicNumber()!=MAGICMA || OrderSymbol()!=Symbol()) continue;
    if(OrderType()!=iOrderType) continue;
    ClosePositionByTicket(OrderTicket());
  }
}

void OpenPosition(int iOrderType){
  if (iOrderType == OP_BUY){
    OrderSend(Symbol(),iOrderType,getLots(),Ask,3,0,0,"",MAGICMA,0,Blue);
  }
  if (iOrderType == OP_SELL){
    OrderSend(Symbol(),iOrderType,getLots(),Bid,3,0,0,"",MAGICMA,0,Red);
  }
}

void MakeLong(){
  ClosePosition(OP_SELL);
  if(OrderCount(OP_BUY)==0){
    OpenPosition(OP_BUY);
  }
}

void MakeShort(){
  ClosePosition(OP_BUY);
  if(OrderCount(OP_SELL)==0){
    OpenPosition(OP_SELL);
  }
}

void CheckStopLoss(){
  int cnt=0;  
  double pts;
  for(int i=0;i<OrdersTotal();i++){
    if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
    if(OrderSymbol()==Symbol() && OrderMagicNumber()!=MAGICMA) continue;    
    pts = OrderProfit()/OrderLots()/AccountLeverage()/1000*10000;   
    if (pts<-StopLossPts){      
    //if ( OrderProfit() < -1000 ) {
      ClosePositionByTicket(OrderTicket());          
      //Print("OrderProfit()=",OrderProfit());      
      //Print("OrderLots()=",OrderLots());      
      //Print("AccountLeverage()=",AccountLeverage());      
      //Print("pts=",pts);      
    }
  }
  //AccountBalance();
  return(cnt);
}

*/  









