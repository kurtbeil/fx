#property copyright ""
#property link      ""

/*

1 只显示当前交易品种
2 不能只执行一次


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

int total;

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


int CloseType[],OpenType[];
double OpenPrice[],ClosePrice[];
string OpenTime[],CloseTime[];

double HisBuyOpenBuffer[],HisBuyCloseBuffer[],HisSellOpenBuffer[],HisSellCloseBuffer[];

void initOrderInfoBuf(){
  ArrayResize(OpenTime,total);
  ArrayResize(CloseTime,total);
  ArrayResize(OpenPrice,total);
  ArrayResize(ClosePrice,total);
  ArrayResize(OpenType,total);
  ArrayResize(CloseType,total);
}

void getOrderInfo(int i){
   OpenTime[i]=TimeToStr(OrderOpenTime()); 
   CloseTime[i]=TimeToStr(OrderCloseTime()); 
   OpenPrice[i]=OrderOpenPrice(); 
   ClosePrice[i]=OrderClosePrice(); 
   OpenType[i] = OrderType();
   CloseType[i] = OrderType();
}

void swapOrderOpenInfo(int i, int j){
   int tOrderType;
   string tTime;
   double tPrice; 
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
}

void swapOrderCloseInfo(int i, int j){
   int tOrderType;
   string tTime;
   double tPrice; 
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
}

void readTradingHistory(){
  for(int i=0;i<OrdersHistoryTotal();i++){
    if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY )==false) break;        
      getOrderInfo(i);
  }
}

void sortTradingHistory(){
  int i,j;
  for(i=0; i<total-1; i++){
    for(j=0; j<=total-i-1; j++){
      if (OpenTime[j] < OpenTime[j+1]){
         swapOrderOpenInfo(j,j+1);
      }
      if (CloseTime[j] < CloseTime[j+1]){
         swapOrderCloseInfo(j,j+1);
      }         
    }
  }
}

int findOpenHistory(string time0,string time1){
   for(int i=0;i<total-1;i++){  
      if(OpenTime[i] < time0 && OpenTime[i] >= time1){
         return (i);         
      }
   }   
   return (EMPTY);
}

int findCloseHistory(string time0,string time1){
   for(int i=0;i<total-1;i++){  
      if(CloseTime[i] < time0 && CloseTime[i] >= time1)
         return (i);
   }   
   return (EMPTY);
}

void printOpenHistory(){
   for(int i=0;i<total-1;i++){  
      log(OpenTime[i]); 
   }
}


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   total = OrdersHistoryTotal();
   // 初始化数据
   initOrderInfoBuf();
   readTradingHistory();
   sortTradingHistory();
   
   // 初始化指标的属性
   IndicatorBuffers(4);          
   //-----------------------------
   SetIndexStyle(0,DRAW_ARROW,0,0.5);
   SetIndexArrow(0,SYMBOL_ARROWUP);
   SetIndexBuffer(0,HisBuyOpenBuffer);     
   //-----------------------------
   SetIndexStyle(1,DRAW_ARROW,0,0.5);
   SetIndexArrow(1,SYMBOL_ARROWDOWN);
   SetIndexBuffer(1,HisBuyCloseBuffer);     
   //-----------------------------
   SetIndexStyle(2,DRAW_ARROW,0,0.5);
   SetIndexArrow(2,SYMBOL_ARROWDOWN);
   SetIndexBuffer(2,HisSellOpenBuffer);     
   //-----------------------------
   SetIndexStyle(3,DRAW_ARROW,0,0.5);
   SetIndexArrow(3,SYMBOL_ARROWUP);
   SetIndexBuffer(3,HisSellCloseBuffer); 
   
   return(0);
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
{ 
   static int run = 0;  
   // 由于程序目前只是显示历史执行情况只需要执行一次就可以了
   if ( run == 0 ) {
      log(" OrdersHistoryTotal()="+ OrdersHistoryTotal());
      string time0,time1;
      int j;
      for(int i=0;i<Bars-1;i++){ 
         HisBuyOpenBuffer[i]=EMPTY; 
         HisBuyCloseBuffer[i]=EMPTY; 
         HisSellOpenBuffer[i]=EMPTY; 
         HisSellCloseBuffer[i]=EMPTY; 
         time0 = TimeToStr(Time[i]);    
         time1 = TimeToStr(Time[i+1]);
         j = findOpenHistory(time0,time1); 
         if(j != EMPTY ){
            
            if(OpenType[j]==OP_BUY) {
               HisBuyOpenBuffer[i]=OpenPrice[j];
            }
            if(OpenType[j]==OP_SELL) {
               HisSellOpenBuffer[i]=OpenPrice[j];            
            }            
         }
         j = findCloseHistory(time0,time1); 
         if (j != EMPTY ){      
            if(CloseType[j]==OP_BUY) 
               HisBuyCloseBuffer[i]=ClosePrice[j];
            if(CloseType[j]==OP_SELL) 
               HisSellCloseBuffer[i]=ClosePrice[j];
         }         
      } 
      printOpenHistory();
      run++;
   }
}

