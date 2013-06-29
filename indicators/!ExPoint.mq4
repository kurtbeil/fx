#property copyright ""
#property link      ""

#property indicator_chart_window
//#property indicator_minimum 0
//#property indicator_maximum 300
#property indicator_buffers 4
#property indicator_color1 Red
#property indicator_color2 Blue

extern int length = 5;

double HighBuffer[]; 
double LowBuffer[]; 


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   IndicatorBuffers(2);             
   SetIndexStyle(0,DRAW_LINE,0,1);
   //SetIndexArrow(0,234);
   SetIndexBuffer(0,HighBuffer);        
   SetIndexStyle(1,DRAW_LINE,0,1);
   //SetIndexArrow(1,233);
   SetIndexBuffer(1,LowBuffer);     
   return(0);
}

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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
{ 
  int i,dt;
  
  //for(i=Bars-1;i>=0;i--){ 
  for(i=10000;i>=0;i--){ 
    dt = i+length;
    if(IsHigh(dt)) HighBuffer[i]=High[dt];
    else HighBuffer[i]=EMPTY;    
    if(IsLow(dt)) LowBuffer[i]=Low[dt];  
    else LowBuffer[i]=EMPTY;
  }      
  for(i=Bars-1;i>=0;i--){
    if( HighBuffer[i] == EMPTY ) HighBuffer[i] = HighBuffer[i+1];
    if( LowBuffer[i] == EMPTY ) LowBuffer[i] = LowBuffer[i+1];
  }  
  return(0);
}

