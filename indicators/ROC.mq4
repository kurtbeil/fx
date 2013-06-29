#property copyright ""
#property link      ""

#property indicator_separate_window
#property indicator_minimum -0.15
#property indicator_maximum 0.15
#property indicator_buffers 8
//#property indicator_color1 Red
#property indicator_color2 LightSeaGreen
#property indicator_color3 LightSeaGreen
#property indicator_color4 LightSeaGreen
#property indicator_color5 Silver
#property indicator_color6 Silver
#property indicator_color7 Silver
#property indicator_color8 Yellow

extern int ROC_Period = 25;
extern int BandsPeriod = 50;
extern int BandsDeviations = 2;
extern int BandsShift = 0;
extern int RocMaSign_Period = 5;
extern int RocMaSign_Period2 = 10;
//---- indicator buffers
double RocBuffer[]; 
double RocMaBuffer[]; 
double RocUpBuffer[]; 
double RocDownBuffer[]; 
double SignUp[]; 
double SignDown[]; 
double RocMaSignBuffer[]; 
double RocMaSignBuffer2[]; 


//----
int ExtCountedBars=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   IndicatorBuffers(8);
     
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,RocBuffer);  
   SetIndexDrawBegin(0,ROC_Period+1); 
   
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,RocUpBuffer);  
   SetIndexDrawBegin(1,ROC_Period+1); 
   
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,RocDownBuffer);  
   SetIndexDrawBegin(2,ROC_Period+1); 
   
   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,RocMaBuffer);  
   SetIndexDrawBegin(3,ROC_Period+1); 
   
   SetIndexStyle(4,DRAW_LINE,STYLE_DASH);
   SetIndexBuffer(4,SignUp);  
   SetIndexDrawBegin(4,0); 
   
   SetIndexStyle(5,DRAW_LINE,STYLE_DASH);
   SetIndexBuffer(5,SignDown);  
   SetIndexDrawBegin(5,0); 
   
   SetIndexStyle(6,DRAW_LINE);
   SetIndexBuffer(6,RocMaSignBuffer);  
   SetIndexDrawBegin(6,ROC_Period+RocMaSign_Period+1); 
   
   SetIndexStyle(7,DRAW_LINE);
   SetIndexBuffer(7,RocMaSignBuffer2);  
   SetIndexDrawBegin(7,ROC_Period+RocMaSign_Period2+1); 
   
   return(0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
{
  //ROC:(CLOSE-REF(CLOSE,N))/REF(CLOSE,N)*100;ROCMA:MA(ROC,M) 
  int i,n;
  for(i=0;i<Bars-ROC_Period;i++){ 
    n = i + ROC_Period;  
    RocBuffer[i]=(Close[i]-Close[n])/Close[n]*100;    
    SignUp[i] = 0.1;
    SignDown[i] = -0.1;
  }   
  
  /*
  for(i=0;i<Bars-ROC_Period;i++){ 
     RocBuffer[i]=iMAOnArray(RocBuffer,0,7,0,MODE_EMA,i);  
  }
  */
  
  for(i=0;i<Bars-ROC_Period;i++){ 
    RocUpBuffer[i]=iBandsOnArray(RocBuffer,Bars,BandsPeriod,BandsDeviations,BandsShift,MODE_UPPER,i);
    RocDownBuffer[i]=iBandsOnArray(RocBuffer,Bars,BandsPeriod,BandsDeviations,BandsShift,MODE_LOWER,i);
    RocMaBuffer[i]=(RocUpBuffer[i]+RocDownBuffer[i])/2;    
  }  
  
  for(i=0;i<Bars-ROC_Period-RocMaSign_Period;i++){ 
    RocMaSignBuffer[i]=iMAOnArray(RocBuffer,0,RocMaSign_Period,0,MODE_EMA,i);    
  }  
   for(i=0;i<Bars-ROC_Period-RocMaSign_Period2;i++){ 
    RocMaSignBuffer2[i]=iMAOnArray(RocBuffer,0,RocMaSign_Period2,0,MODE_EMA,i);    
  }  
  return(0);
}

