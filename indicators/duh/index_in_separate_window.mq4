#property copyright ""
#property link      ""

#property indicator_separate_window
//#property indicator_minimum -1
//#property indicator_maximum 1
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Blue

extern int ROC_Period=25;

//---- indicator buffers
double ExtMapBuffer0[]; 
double ExtMapBuffer1[];

//----
int ExtCountedBars=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   IndicatorBuffers(2);
     
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtMapBuffer0);  
   SetIndexDrawBegin(0,ROC_Period+1); 
   
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,ExtMapBuffer1);  
   SetIndexDrawBegin(1,ROC_Period+1); 
   
   return(0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
{
  //ROC:(CLOSE-REF(CLOSE,N))/REF(CLOSE,N)*100;ROCMA:MA(ROC,M) 
  int n;
  for(int i=0;i<Bars-ROC_Period;i++){ 
    n = i + ROC_Period;  
    ExtMapBuffer0[i]=(Close[i]-Close[n])/Close[n]*100.0;        
    ExtMapBuffer1[i]=(Close[i]-Close[n])/Close[n]*100.0;     
    //Print("ExtMapBuffer0=",ExtMapBuffer0[i]);
  }    
  return(0);
}

