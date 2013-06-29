
/*

*/


#property copyright "DuHan"
#property link      ""

#define SIGNAL_NULL 0
#define SIGNAL_BUY 1
#define SIGNAL_SELL -1

#define MAGICMA  20120902

int length = 7;
int maPeriod = 15;
int maxPosition = 1;
double stoploss = 0.0035;



void log(string msg){
  //if (LOGGING==1){
    int handle;
    string timestamp = TimeToStr(TimeCurrent());
    handle=FileOpen(Symbol()+"["+MAGICMA+"][TRADING].log",FILE_READ|FILE_WRITE," ");  
    if(handle>0)
    {
       FileSeek(handle, 0, SEEK_END);
       FileWrite(handle,timestamp,":", msg);     
       FileClose(handle );
    }
  //}
}

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
    if(idx<=0) return(false);
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
    if(idx<=0) return(false);
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

/*
double getLots(){
  return (0.1);
}
*/

void ClosePositionByTicket(int ticket){
  if (OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)==false) {
    Print("Order is not found");
    return;
  }
  if(OrderType()==OP_BUY){
    //OrderClose(OrderTicket(),OrderLots(),Bid,3,Blue);
    OrderClose(OrderTicket(),OrderLots(),Bid,0,Blue);
  }
    if(OrderType()==OP_SELL){
    //OrderClose(OrderTicket(),OrderLots(),Ask,3,Red);
    OrderClose(OrderTicket(),OrderLots(),Ask,0,Red);
  }
}

void ClosePosition(int cmd){
  for(int i=0;i<OrdersTotal();i++){    
    if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
    if(OrderSymbol()==Symbol() && OrderMagicNumber()!=MAGICMA) continue;        
    if (cmd== OrderType()){
      ClosePositionByTicket(OrderTicket());    
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

int PositionCountByCmd(int cmd){
  int cnt=0;
  for(int i=0;i<OrdersTotal();i++){
    if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
    if(OrderSymbol()==Symbol() && OrderMagicNumber()!=MAGICMA) continue;    
    if (cmd==OrderType()) cnt++;
  }
  return(cnt);
}

bool existPosition(){
  for(int i=0;i<OrdersTotal();i++){
    if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
    if(OrderSymbol()==Symbol() && OrderMagicNumber()!=MAGICMA) continue;    
    return(true);     
  }
  return(false);
}

void CreatePosition(int cmd){
  
  if (cmd==OP_BUY)
    //OrderSend(Symbol(),OP_BUY,getLots(),Ask,3,Ask-stoploss,0,"",MAGICMA,0,Blue);    
    OrderSend(Symbol(),OP_BUY,getLots(),Ask,0,Ask-stoploss,0,"",MAGICMA,0,Blue);    
  if (cmd==OP_SELL)
    //OrderSend(Symbol(),OP_SELL,getLots(),Bid,3,Bid+stoploss,0,"",MAGICMA,0,Red); 
    OrderSend(Symbol(),OP_SELL,getLots(),Bid,0,Bid+stoploss,0,"",MAGICMA,0,Red); 
}

void setupStoploss(){
  double sl;
  string timestamp = TimeToStr(TimeCurrent());
  
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

double VolumePct(int n){
  double volume=0;
  int i;
  for(i=n;i<Bars&&i<n+1000;i++){
    volume = volume +Volume[i];  
  }
  volume = volume/(i+1);
  return(Volume[n]/volume*100);
}

int start()
{  
  string timestamp = TimeToStr(TimeCurrent());
  if(Volume[0]>1) return(0);
  getExPoint();
  double ma1=iMA(Symbol(),0,maPeriod,0,MODE_EMA,PRICE_CLOSE,1);
  double ma2=iMA(Symbol(),0,maPeriod,0,MODE_EMA,PRICE_CLOSE,2);
  double high0 = getHighPointValue(0);
  double low0 = getLowPointValue(0);
  
  if (timestamp=="2009.04.08 05:55") {
    log("ma1="+ma1+",ma2="+ma2+",high0="+high0+",low0="+low0);
    //log("getLowPointIndex(0)="+getLowPointIndex(0)); 
    //log("time(low)="+TimeToStr(Time[getLowPointIndex(0)]));    
    //int i;
    //for(i=0;i<100;i++){
    //  log("HighBuffer["+i+"]="+HighBuffer[i]);      
    //}
    //log("High[5]="+High[5]);      
  }
  
  double dayMa10=iMA(Symbol(),PERIOD_D1,7,0,MODE_EMA,PRICE_CLOSE,1);
  double dayMa20=iMA(Symbol(),PERIOD_D1,22,0,MODE_EMA,PRICE_CLOSE,1);
  
  //if (timestamp=="2009.04.15 02:50") {
  //   log("getLowPointIndex(0)="+getLowPointIndex(0));  
  //   log("time(low)="+TimeToStr(Time[getLowPointIndex(0)]));       
  //}
    
  if( ma2<=high0 && ma1>high0 ){
    // ×ö¶à      
    while(existPositionByCmd(OP_SELL))ClosePosition(OP_SELL);
    if(PositionCountByCmd(OP_BUY)<maxPosition) CreatePosition(OP_BUY);    
  }
  
  if( ma2>=low0 && ma1<low0 ){
    // ×ö¿Õ      
    while(existPositionByCmd(OP_BUY))ClosePosition(OP_BUY);
    if(PositionCountByCmd(OP_SELL)<maxPosition) CreatePosition(OP_SELL);    
  }
  setupStoploss();
}





//+------------------------------------------------------------------+