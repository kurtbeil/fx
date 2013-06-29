#property copyright ""
#property link      ""

#property indicator_chart_window
//#property indicator_minimum 0
//#property indicator_maximum 300
#property indicator_buffers 4
#property indicator_color1 Red
#property indicator_color2 Blue



double HighBuffer[]; 
double LowBuffer[]; 
int length = 5;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   IndicatorBuffers(2);             
   SetIndexStyle(0,DRAW_ARROW,0,1);
   SetIndexArrow(0,234);
   SetIndexBuffer(0,HighBuffer);        
   SetIndexStyle(1,DRAW_ARROW,0,1);
   SetIndexArrow(1,233);
   SetIndexBuffer(1,LowBuffer);     
   return(0);
}

bool IsHigh(int i){
  int j,idx;
  for(j=1;j<length;j++){
    idx = i + j;
    if(idx>=Bars) break;
    if(High[idx]>=High[i]) return (false);
  }
  for(j=1;j<length;j++){
    idx = i - j;
    if(idx<0) break;
    if(High[idx]>High[i]) return (false);
  }  
  return (true);
}

bool IsLow(int i){
  int j,idx;
  for(j=1;j<length;j++){
    idx = i + j;
    if(idx>=Bars) break;
    if(High[idx]<=High[i]) return (false);
  }
  for(j=1;j<length;j++){
    idx = i - j;
    if(idx<0) break;
    if(High[idx]<High[i]) return (false);
  }  
  return (true);
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
{ 
  int i,dt;
  //double pi = 0.0002;
  double pi = 0;
  
  for(i=Bars-1;i>=0;i--){ 
    dt = i+length;
    if(IsHigh(dt)) HighBuffer[i]=High[dt]+pi;
    if(IsLow(dt)) LowBuffer[i]=Low[dt]-pi;  
  }    
  for(i=0;i<=length;i++){
     HighBuffer[i]=EMPTY;
     LowBuffer[i]=EMPTY;
  }  
  return(0);
}

