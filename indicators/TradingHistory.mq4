#property copyright ""
#property link      ""

/*

1 只显示当前交易品种 (ok)
2 不能只执行一次(ok)
3 查找速度太慢了，算法需要进行优化 (ok)
(1) 建立open\close数组时就过滤,非当前交易品种 
(2) 调用find...History时记录上次调用的返回值,并作为下一次要调用的参数
*/


#property indicator_chart_window
//#property indicator_minimum 0
//#property indicator_maximum 300
#property indicator_buffers 4
#property indicator_color1 Blue
#property indicator_color2 Yellow
#property indicator_color3 Red
#property indicator_color4 Yellow


#define LOGGING  1
string logfile = "indicator.test.log";

int orderTotal;

/*
void log(string msg){
  if (LOGGING==1){
    int handle;
    string timestamp = TimeToStr(TimeCurrent());
    handle=FileOpen(logfile,FILE_READ|FILE_WRITE," ");  
    if(handle>0)
    {
       FileSeek(handle, 0, SEEK_END);
       FileWrite(handle,timestamp,":", msg);     
       FileClose(handle );
    }
  }
}
*/


int CloseType[],OpenType[];
double OpenPrice[],ClosePrice[];
string OpenTime[],CloseTime[];
string OpenSymbol[],CloseSymbol[];

double HisBuyOpenBuffer[],HisBuyCloseBuffer[],HisSellOpenBuffer[],HisSellCloseBuffer[];

void initOrderInfoBuf(){
  ArrayResize(OpenTime,orderTotal);
  ArrayResize(CloseTime,orderTotal);
  ArrayResize(OpenPrice,orderTotal);
  ArrayResize(OpenSymbol,orderTotal);
  ArrayResize(ClosePrice,orderTotal);
  ArrayResize(OpenType,orderTotal);
  ArrayResize(CloseType,orderTotal);
  ArrayResize(CloseSymbol,orderTotal);
}


int getOrderTotal(){
  int orderTotal = 0;
  for(int i=0;i<OrdersHistoryTotal();i++){
    if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY )==false) break;        
    if( OrderSymbol() == Symbol() )
      if ( OrderType() == OP_BUY || OrderType() == OP_SELL )
         orderTotal++;
  }
  return (orderTotal);
}


void getOrderInfo(int i){
   OpenTime[i] = TimeToStr(OrderOpenTime());    
   OpenType[i] = OrderType();
   OpenPrice[i] = OrderOpenPrice(); 
   OpenSymbol[i] = OrderSymbol();
   
   CloseTime[i]= TimeToStr(OrderCloseTime());
   CloseType[i] = OrderType();
   ClosePrice[i] = OrderClosePrice();    
   CloseSymbol[i] = OrderSymbol();
}

void swapOrderOpenInfo(int i, int j){
   int tOrderType;
   string tTime;
   double tPrice; 
   string tSymbol;
   //--
   tTime = OpenTime[j];
   OpenTime[j] = OpenTime[i];
   OpenTime[i] = tTime;
   //---
   tPrice = OpenPrice[j];
   OpenPrice[j]=OpenPrice[i];
   OpenPrice[i] = tPrice;
   //--
   tOrderType = OpenType[j];
   OpenType[j]=OpenType[i];
   OpenType[i] = tOrderType;
   //-- 
   tSymbol = OpenSymbol[j];
   OpenSymbol[j] = OpenSymbol[i];
   OpenSymbol[i] = tSymbol;
}

void swapOrderCloseInfo(int i, int j){
   int tOrderType;
   string tTime;
   double tPrice; 
   string tSymbol;
   //--
   tTime = CloseTime[j];
   CloseTime[j] = CloseTime[i];
   CloseTime[i] = tTime;
   //---
   tPrice = ClosePrice[j];
   ClosePrice[j]=ClosePrice[i];
   ClosePrice[i] = tPrice;
   //--
   tOrderType = CloseType[j];
   CloseType[j] = CloseType[i];
   CloseType[i] = tOrderType;
   //-- 
   tSymbol = CloseSymbol[j];
   CloseSymbol[j] = CloseSymbol[i];
   CloseSymbol[i] = tSymbol;
}

void readTradingHistory(){
  int orderIndex = 0;
  for(int i=0;i<OrdersHistoryTotal();i++){
    if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY )==false) break;    
    if( OrderSymbol() == Symbol() )
      if ( OrderType() == OP_BUY || OrderType() == OP_SELL ){    
         getOrderInfo(orderIndex);
         orderIndex++;
      }
  }
}

void sortTradingHistory(){
  int i,j;
  for(i=0; i<orderTotal-1; i++){
    for(j=0; j<=orderTotal-i-1; j++){
      if (OpenTime[j] < OpenTime[j+1]){
         swapOrderOpenInfo(j,j+1);
      }
      if (CloseTime[j] < CloseTime[j+1]){
         swapOrderCloseInfo(j,j+1);
      }         
    }
  }
}

int findOpenHistory(int bi,string time0,string time1){   
   for(int i=bi;i<orderTotal-1;i++){  
      if(OpenTime[i] < time0 && OpenTime[i] >= time1){      
         //log("Symbol()="+Symbol()+",OpenSymbol[i]=" + OpenSymbol[i]);
         if(OpenSymbol[i] == Symbol())
            return (i);
      }               
   }   
   return (EMPTY);
}

int findCloseHistory(int bi,string time0,string time1){
   for(int i=bi;i<orderTotal-1;i++){  
      if(CloseTime[i] < time0 && CloseTime[i] >= time1 ){
         //log("Symbol()="+Symbol()+",OpenSymbol[i]=" + OpenSymbol[i]);
         if(CloseSymbol[i] == Symbol())
            return (i);
      }
   }   
   return (EMPTY);
}

/*
void printOpenHistory(){
   for(int i=0;i<orderTotal-1;i++){  
      log(OpenTime[i]); 
   }
}
*/


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   // 获取当前品种的交易记录数量
   orderTotal = getOrderTotal();
   // 初始化数据
   initOrderInfoBuf();
   readTradingHistory();
   sortTradingHistory();
   
   // 初始化指标的属性
   IndicatorBuffers(4);          
   //-----------------------------
   SetIndexStyle(0,DRAW_ARROW,0,2);
   SetIndexArrow(0,236);
   SetIndexBuffer(0,HisBuyOpenBuffer);     
   //-----------------------------
   SetIndexStyle(1,DRAW_ARROW,0,2);
   SetIndexArrow(1,237);
   SetIndexBuffer(1,HisBuyCloseBuffer);     
   //-----------------------------
   SetIndexStyle(2,DRAW_ARROW,0,2);
   SetIndexArrow(2,238);
   SetIndexBuffer(2,HisSellOpenBuffer);     
   //-----------------------------
   SetIndexStyle(3,DRAW_ARROW,0,2);
   SetIndexArrow(3,235);
   SetIndexBuffer(3,HisSellCloseBuffer); 
   
   return(0);
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
{ 
   int limit;
   int counted_bars=IndicatorCounted();
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   
   //log("Bars="+Bars+",counted_bars="+counted_bars);   
   int i,j,oi=0,ci=0;
   string time0,time1;   
   double markPosition;
   for(i=0;i<limit;i++){ 
      HisBuyOpenBuffer[i]=EMPTY; 
      HisBuyCloseBuffer[i]=EMPTY; 
      HisSellOpenBuffer[i]=EMPTY; 
      HisSellCloseBuffer[i]=EMPTY; 
      time0 = TimeToStr(Time[i]);    
      time1 = TimeToStr(Time[i+1]);
      j = findOpenHistory(oi,time0,time1); 
      if(j != EMPTY ){
         oi = j;
         markPosition = OpenPrice[j];
         //markPosition = Open[i];          
         if(OpenType[j]==OP_BUY) {
            HisBuyOpenBuffer[i]=markPosition;
         }
         if(OpenType[j]==OP_SELL) {
            HisSellOpenBuffer[i]=markPosition;            
         }            
      }
      j = findCloseHistory(ci,time0,time1); 
      if (j != EMPTY ){
         ci = j;    
         markPosition = ClosePrice[j];  
         //markPosition = Close[i];  
         if(CloseType[j]==OP_BUY) 
            HisBuyCloseBuffer[i]=markPosition;
         if(CloseType[j]==OP_SELL) 
            HisSellCloseBuffer[i]=markPosition;
      }         
   }
}

