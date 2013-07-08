#property copyright ""
#property link      ""

#property indicator_chart_window
//#property indicator_minimum 0
//#property indicator_maximum 300
#property indicator_buffers 4
#property indicator_color1 Blue
#property indicator_color2 Yellow
#property indicator_color3 Red
#property indicator_color4 Yellow



double HisBuyOpenBuffer[]; 
double HisBuyCloseBuffer[]; 
double HisSellOpenBuffer[]; 
double HisSellCloseBuffer[]; 


string OpenTime[];
double OpenPrice[];
int OpenType[];

string CloseTime[];
double ClosePrice[];
int CloseType[];


int total;

void getHisTrading(){
  total = OrdersHistoryTotal();
  ArrayResize(OpenTime,total);
  ArrayResize(CloseTime,total);
  ArrayResize(OpenPrice,total);
  ArrayResize(ClosePrice,total);
  ArrayResize(OpenType,total);
  ArrayResize(CloseType,total);
  
  for(int i=0;i<OrdersHistoryTotal();i++){
    if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY )==false) break;        
    OpenTime[i]=TimeToStr(OrderOpenTime()); 
    CloseTime[i]=TimeToStr(OrderCloseTime()); 
    OpenPrice[i]=OrderOpenPrice(); 
    ClosePrice[i]=OrderClosePrice(); 
    OpenType[i] = OrderType();
    CloseType[i] = OrderType();
  }
}

void sortHisTrading(){
  int i,j,tOrderType;
  string tTime;
  double tPrice;  
  for(i=0; i<total-1; i++){
    for(j=0; j<=total-i-1; j++){
      if (OpenTime[j] < OpenTime[j+1]){
        tTime = OpenTime[j+1];
        OpenTime[j+1] = OpenTime[j];
        OpenTime[j] = tTime;
        //---
        tPrice = OpenPrice[j+1];
        OpenPrice[j+1]=OpenPrice[j];
        OpenPrice[j] = tPrice;
        //--
        tOrderType = OpenType[j+1];
        OpenType[j+1]=OpenType[j];
        OpenType[j] = tOrderType;
      }
    }
  }
  for(i=0; i<total-1; i++){
    for(j=0; j<=total-i-1; j++){
      if (CloseTime[j] < CloseTime[j+1]){
        tTime = CloseTime[j+1];
        CloseTime[j+1] = CloseTime[j];
        CloseTime[j] = tTime;
        //--
        tPrice = ClosePrice[j+1];
        ClosePrice[j+1]=ClosePrice[j];
        ClosePrice[j] = tPrice;
        //--
        tOrderType = CloseType[j+1];
        CloseType[j+1]=CloseType[j];
        CloseType[j] = tOrderType;
      }
    }
  }
}

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   IndicatorBuffers(4);          
   
   SetIndexStyle(0,DRAW_ARROW,0,2);
   SetIndexArrow(0,SYMBOL_ARROWUP);
   SetIndexBuffer(0,HisBuyOpenBuffer);     
   
   SetIndexStyle(1,DRAW_ARROW,0,2);
   SetIndexArrow(1,SYMBOL_ARROWDOWN);
   SetIndexBuffer(1,HisBuyCloseBuffer);     
   
   SetIndexStyle(2,DRAW_ARROW,0,2);
   SetIndexArrow(2,SYMBOL_ARROWDOWN);
   SetIndexBuffer(2,HisSellOpenBuffer);     
   
   SetIndexStyle(3,DRAW_ARROW,0,2);
   SetIndexArrow(3,SYMBOL_ARROWUP);
   SetIndexBuffer(3,HisSellCloseBuffer); 
   
   //----
   
   
   
   /*
   for(int i=0;i<OrdersHistoryTotal();i++){
     Print("CloseTime=",CloseTime[i]);
   } 
   */
        
   
   //Print("OpenTime[total]=",OpenTime[total-1]); 
   
   
   return(0);
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
{ 
  string time;
  int io=0,ic=0;   
  
  getHisTrading();   
  sortHisTrading();
  
  for(int i=0;i<Bars;i++){ 
    HisBuyOpenBuffer[i]=EMPTY; 
    HisBuyCloseBuffer[i]=EMPTY; 
    HisSellOpenBuffer[i]=EMPTY; 
    HisSellCloseBuffer[i]=EMPTY; 
    time = TimeToStr(Time[i]);    
    if(time == OpenTime[io]){
      if(OpenType[io]==OP_BUY) 
        HisBuyOpenBuffer[i]=OpenPrice[io];
      if(OpenType[io]==OP_SELL) 
        HisSellOpenBuffer[i]=OpenPrice[io];
    }
    if (time == CloseTime[ic]){      
      if(CloseType[io]==OP_BUY) 
        HisBuyCloseBuffer[i]=ClosePrice[io];
      if(CloseType[io]==OP_SELL) 
        HisSellCloseBuffer[i]=ClosePrice[io];
    }
    while(time<OpenTime[io]&&io<total)io++;
    while(time<CloseTime[ic]&&ic<total)ic++;
  } 
    
  return(0);
}

