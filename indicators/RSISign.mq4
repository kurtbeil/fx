#property copyright ""
#property link      ""

#property indicator_separate_window
//#property indicator_minimum -0.15
//#property indicator_maximum 0.15
#property indicator_buffers 7
#property indicator_color1 Blue
#property indicator_color2 LightSeaGreen
#property indicator_color3 Silver
#property indicator_color4 Red
#property indicator_color5 Yellow
#property indicator_color6 Yellow
#property indicator_color7 Yellow


extern int Rsi_Period = 12;
extern int EMA1_Period = 12;
extern int EMA2_Period = 12;
//---- indicator buffers
double RsiBuffer[]; 
double RsiMaABuffer[]; 
double RsiMaBBuffer[]; 
double CBuffer[]; 
double SignBuffer1[]; 
double SignBuffer2[]; 
double SignBuffer3[]; 
//----
int ExtCountedBars=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   IndicatorBuffers(7);     
   
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,RsiBuffer);  
   SetIndexDrawBegin(0,Rsi_Period+1);    
   
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,RsiMaABuffer);  
   SetIndexDrawBegin(1,EMA1_Period+Rsi_Period+1);    
   
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,RsiMaBBuffer);  
   SetIndexDrawBegin(2,EMA2_Period+EMA1_Period+Rsi_Period+1);    
   
   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,CBuffer);  
   SetIndexDrawBegin(3,EMA2_Period+EMA1_Period+Rsi_Period+1);   
   
   SetIndexStyle(4,DRAW_LINE,STYLE_DOT);
   SetIndexBuffer(4,SignBuffer1);  
   SetIndexDrawBegin(4,0);     
   
   SetIndexStyle(5,DRAW_LINE,STYLE_DOT);
   SetIndexBuffer(5,SignBuffer2);  
   SetIndexDrawBegin(5,0);        
   
   SetIndexStyle(6,DRAW_LINE,STYLE_DOT);
   SetIndexBuffer(6,SignBuffer3);  
   SetIndexDrawBegin(6,0);     
   
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
  for(i=0;i<Bars-Rsi_Period;i++){ 
    RsiBuffer[i]=iRSI(Symbol(),PERIOD_M1,Rsi_Period,PRICE_CLOSE,i);   
  }       
  for(i=0;i<Bars-EMA1_Period-Rsi_Period;i++){ 
    RsiMaABuffer[i]=iMAOnArray(RsiBuffer,0,EMA1_Period,0,MODE_EMA,i);      
  }       
  for(i=0;i<Bars-EMA2_Period-EMA1_Period-Rsi_Period;i++){ 
    RsiMaBBuffer[i]=iMAOnArray(RsiMaABuffer,0,EMA2_Period,0,MODE_EMA,i);      
  }    
  for(i=0;i<Bars-EMA2_Period-EMA1_Period-Rsi_Period;i++){ 
    CBuffer[i]=RsiMaABuffer[i]/RsiMaBBuffer[i]*100;
    //CBuffer[i]=50;
  }
  for(i=0;i<Bars-EMA2_Period-EMA1_Period-Rsi_Period;i++){ 
    SignBuffer1[i] = 20;
    SignBuffer2[i] = 80;
    SignBuffer3[i] = 100;
  }
  return(0);
}

