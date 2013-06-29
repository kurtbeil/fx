
/*

1、同类型交易不重入(ok)
2、创建头寸的点不准确
3、需要设置20个点的跟踪止损
4、成交量要如何处理
5、是否从日线数据中可以找到过滤方法

*/
#import "user32.dll" int MessageBoxA(int hWnd,string szText,string szCaption,int ntype);
#include <stdlib.mqh>


#property copyright "Copyright 2012, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#define SIGNAL_NULL 0
#define SIGNAL_BUY 1
#define SIGNAL_SELL -1

#define MAGICMA  20120902

int length = 4;
int decay = 5;
int volumeFlag1 = 30;
int volumeFlag2 = 10000;
int rsiPeriod = 6;
int rsiUpLimit = 0;
int rsiDownLimit = 100;
double stoploss = 0.0045;


double HighBuffer[]; 
double LowBuffer[]; 



bool IsHigh(int i){
  int j,idx;
  for(j=1;j<=length;j++){
    idx = i + j;    
    if(idx>=Bars) return(false);    
    if(High[idx]>=High[i]) return (false);
  }
  for(j=1;j<=length;j++){
    idx = i - j;    
    if(idx<0) return(false);
    if(High[idx]>High[i]) return (false);
  }  
  return (true);
}

bool IsLow(int i){
  int j,idx;
  for(j=1;j<=length;j++){
    idx = i + j;    
    if(idx>=Bars) return(false);
    if(Low[idx]<=Low[i])return (false);    
  }
  for(j=1;j<=length;j++){
    idx = i - j;
    if(idx<0) return(false);
    if(Low[idx]<Low[i]) return (false);
  }  
  return (true);
}

void getExPoint(){
  int i,dt;
  int bars,maxBars = 300;
  if (Bars<maxBars) bars= Bars;
  else bars=maxBars;
  ArrayResize(HighBuffer,bars);
  ArrayResize(LowBuffer,bars);
  for(i=bars-1;i>=0;i--){ 
    if(IsHigh(i)) HighBuffer[i]=High[i]; else  HighBuffer[i] = EMPTY;
    if(IsLow(i)) LowBuffer[i]=Low[i]; else LowBuffer[i] = EMPTY;
  }    
  return(0);
}

int getHighPointIndex(int n){
  int i=0,j=-1;
  for(i=0;i<Bars;i++){
    if(HighBuffer[i]!=EMPTY) j++;
    if (j==n) return(i);
  }
  return(-1);
}

int getLowPointIndex(int n){
  int i=0,j=-1;
  for(i=0;i<Bars;i++){
    if(LowBuffer[i]!=EMPTY) j++;
    if (j==n) return(i);
  }
  return(-1);
}

double getHighPointValue(int n){
  int i = getHighPointIndex(n);
  if (i == -1) return(EMPTY);
  return(HighBuffer[i]);
}

double getLowPointValue(int n){
  int i = getLowPointIndex(n);
  if (i == -1) return(EMPTY);
  return(LowBuffer[i]);
}

double getLots(){
  double lots;     
  lots = AccountBalance()/AccountLeverage()/150;
  //Print("ptsRisk=",ptsRisk);      
  //Print("AccountBalance()=",AccountBalance());      
  //Print("AccountLeverage()=",AccountLeverage());      
  //Print("MaximumRisk=",MaximumRisk);  
  if(lots>1) lots=MathSqrt(lots);  
  lots = MathRound(lots*10)/10;  
  if(lots<0.1) lots=0.1;  
  
  //lots = 0.1;
  return (lots);  
}

int signal = 0;
datetime createTime=EMPTY;
void checkForOpen(){  
  double h0,l0;
  h0 = getHighPointValue(0); 
  l0 = getLowPointValue(0);
  int err;
  double rsi = iRSI(Symbol(),0,rsiPeriod,PRICE_CLOSE,1);
  double price,pi = 0.0001;  

  //Print("signal=",signal);  
  if (signal==0){    
    for(int i=1;i<=decay;i++){
      //Print("Open[i]=",Open[i],",h0=",h0);
      if( (Open[i]<=h0&&Close[i]>h0) || (Close[i+1]<=h0&& Close[i]>=h0) ){        
        //Print(TimeToStr(Time[0]));
      //if( Open[i]<=h0&&Close[i]>h0 ){        
        if (Volume[1]>volumeFlag1 && Volume[1]< volumeFlag2 && rsi >= rsiUpLimit && !existPosition() ){
          //price = iHigh(Symbol(),PERIOD_D1,1) + pi;
          OrderSend(Symbol(),OP_BUY,getLots(),Ask,3,0,0,"",MAGICMA,0,Blue);     
          createTime = Time[0];
          signal=decay;
        }
      }
      if( (Open[i]>l0&&Close[i]<l0) || (Close[i+1]>=l0&& Close[i]<l0) ){
        if (Volume[1]>volumeFlag1 && Volume[1]< volumeFlag2 && rsi <= rsiDownLimit && !existPosition()){
          //price = iLow(Symbol(),PERIOD_D1,1) - pi;
          OrderSend(Symbol(),OP_SELL,getLots(),Bid,3,0,0,"",MAGICMA,0,Red);   
          createTime = Time[0];       
          signal=decay;
        }
      }
    }
  }else{
    signal--;
  }  
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

void ClosePosition(int cmd){
  for(int i=0;i<OrdersTotal();i++){
    if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
    if(OrderSymbol()==Symbol() && OrderMagicNumber()!=MAGICMA) continue;    
    if (cmd==OP_BUY){
      if (OrderType()==OP_BUYSTOP || OrderType()==OP_BUYLIMIT) OrderDelete(OrderTicket()); 
      if (OrderType() == OP_BUY)ClosePositionByTicket(OrderTicket());    
    }
    if (cmd==OP_SELL){
      if (OrderType() == OP_SELLSTOP || OrderType()==OP_SELLLIMIT) OrderDelete(OrderTicket()); 
      if (OrderType() == OP_SELL)ClosePositionByTicket(OrderTicket());    
    }
  }
}

bool existPositionByCmd(int cmd){
  for(int i=0;i<OrdersTotal();i++){
    if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
    if(OrderSymbol()==Symbol() && OrderMagicNumber()!=MAGICMA) continue;    
    if (cmd==OP_BUY){
      if (OrderType()==OP_BUYSTOP || OrderType()==OP_BUYLIMIT || OrderType() == OP_BUY) 
        return(true);
    }
    if (cmd==OP_SELL){
      if (OrderType() == OP_SELLSTOP || OrderType()==OP_SELLLIMIT || OrderType() == OP_SELL)
        return(true); 
    }
  }
  return(false);
}

bool existPosition(){
  for(int i=0;i<OrdersTotal();i++){
    if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
    if(OrderSymbol()==Symbol() && OrderMagicNumber()!=MAGICMA) continue;    
    return(true);     
  }
  return(false);
}


void checkForClose(){
  double h0,l0,h1,l1;
  double pi=0.0005;
  h0 = getHighPointValue(0); 
  l0 = getLowPointValue(0);
  h1 = getHighPointValue(1); 
  l1 = getLowPointValue(1);  
  
  if (createTime<Time[getHighPointIndex(0)]){
    if (existPositionByCmd(OP_BUY) ){
      if( (h0<h1 && h1-h0>pi ) || Low[1]<l0) ClosePosition(OP_BUY);        
    }
    if (existPositionByCmd(OP_SELL) ){
      if( (l0>l1 && l0-l1>pi ) || High[1]>h0) ClosePosition(OP_SELL);              
    }
  }
  
  /*
          if(TimeToStr(Time[0])=="2011.09.01 02:35") {
          //Print("hello");
          Print("Close[1]=",Close[1],",h0=",h0);
        }
  
  */
  
  
  /* 
  if (existPosition()){
    if ( createTime<Time[getHighPointIndex(0)] ){
      if( h0<h1 && h1-h0>pi ){    
        ClosePosition(OP_BUY);        
      }
      if( l0>l1 && l0-l1>pi ){
        ClosePosition(OP_SELL); 
      }   
    }      
   if( Close[1]<l0 ){
     //Print("!!!!@@");
     ClosePosition(OP_BUY);        
   }
   if( Close[1]>h0 ){
     ClosePosition(OP_SELL);        
   }  
  }
  */
  
}


void setupStoploss(){
  double sl;
  for(int i=0;i<OrdersTotal();i++){
    if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
    if(OrderSymbol()==Symbol() && OrderMagicNumber()!=MAGICMA) continue;
    
    if( OrderType()== OP_BUY ) {    
      sl=Low[1]-stoploss;    
      if(sl>OrderStopLoss()||OrderStopLoss()==0)
        OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0,Blue);
    }    
    if( OrderType()== OP_SELL ) {    
      sl=High[1]+stoploss;    
      if(sl<OrderStopLoss()||OrderStopLoss()==0)
        OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0,Red);
    }   
  }
}


int init(){

  

}

int start()
{

  
  Print("call MessageBox");
  MessageBoxA(0,"a message","message",0);
   //if(TimeToStr(Time[0])=="2011.09.01 14:55") {
   //if(TimeToStr(Time[0])=="2011.09.01 22:50") {
   if( Bars < 100 ) return(0);
   getExPoint();
   checkForOpen();       
   checkForClose();
   
   setupStoploss();      
   //-------------------
   //if(getHighPointValue(0) == getHighPointValue(1)) Print("fuck!");
   //if(getHighPointIndex(0) == getHighPointIndex(1)) Print("fuck!");
   //Print("getHighPointIndex(0)=",getHighPointIndex(0));  
   //Print("getHighPointIndex(1)=",getHighPointIndex(1));  
     //Print("length=",length);
     //Print("IsLow(0)=",IsLow(4));
     //Print("IsHigh(0)=",IsHigh(4));
   //}
   ErrorDescription(00);
}





//+------------------------------------------------------------------+