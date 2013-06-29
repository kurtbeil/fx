#property copyright ""
#property link      ""

#property indicator_separate_window
#property indicator_minimum -2
#property indicator_maximum 2
#property indicator_buffers 3
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Red


extern int EMA0_Period = 300;
extern int EMA1_Period = 49;
//---- indicator buffers
double EMA0Buffer[]; 
double EMA1Buffer[]; 
double EMADiffBuffer[]; 



//----
int ExtCountedBars=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   IndicatorBuffers(3);     
   
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,EMA0Buffer);  
   SetIndexDrawBegin(0,EMA0_Period+1);    
   
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,EMA1Buffer);  
   SetIndexDrawBegin(1,EMA1_Period+1);    
   
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer(2,EMADiffBuffer);  
   SetIndexDrawBegin(2,EMA1_Period+1);    
   
   return(0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
{ 
  static int n=1;
  Print("start=",n);
  n++;
  int i;
  for(i=0;i<Bars-EMA0_Period;i++){ 
    EMA0Buffer[i]=iMA(Symbol(),PERIOD_M1,EMA0_Period,0,MODE_EMA,PRICE_CLOSE,i);   
    EMA1Buffer[i]=iMA(Symbol(),PERIOD_M1,EMA1_Period,0,MODE_EMA,PRICE_CLOSE,i);  
    if ( EMA1Buffer[i]-EMA0Buffer[i]  >0 ) {
      EMADiffBuffer[i] =  1;
    }else{
      EMADiffBuffer[i] =  -1;
    }
    
  }     
  
  for(i=0;i<Bars-EMA1_Period;i++){ 
    EMA0Buffer[i]=0;
    EMA1Buffer[i]=0;
  }     
  
  
  return(0);
}

