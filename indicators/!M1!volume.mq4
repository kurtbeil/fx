#property copyright ""
#property link      ""

#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 30
#property indicator_buffers 7
#property indicator_color1 Red
#property indicator_color2 Green
#property indicator_color3 Silver
#property indicator_color4 Silver
#property indicator_color5 Silver
#property indicator_color6 Silver
#property indicator_color7 Silver



double VolumeBuffer1[]; 
double VolumeBuffer2[];


double SignalBuffer1[];
double SignalBuffer2[];
double SignalBuffer3[];
double SignalBuffer4[];
double SignalBuffer5[];


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   IndicatorBuffers(7);          
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,VolumeBuffer1);     
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(1,VolumeBuffer2);  
   //----
   SetIndexStyle(2,DRAW_LINE,STYLE_DOT);
   SetIndexBuffer(2,SignalBuffer1);  
   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,SignalBuffer2);  
   SetIndexStyle(4,DRAW_LINE,STYLE_DOT);
   SetIndexBuffer(4,SignalBuffer3);  
   SetIndexStyle(5,DRAW_LINE);
   SetIndexBuffer(5,SignalBuffer4);  
   SetIndexStyle(6,DRAW_LINE,STYLE_DOT);
   SetIndexBuffer(6,SignalBuffer5);  
   return(0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
{ 
  for(int i=0;i<Bars;i++){ 
    if(Close[i]>Open[i]){
      VolumeBuffer1[i]=Volume[i];  
      VolumeBuffer2[i]=0;   
    }else{    
      VolumeBuffer2[i]=Volume[i];   
      VolumeBuffer1[i]=0;
    }    
    SignalBuffer1[i]= 5; 
    SignalBuffer2[i]= 10; 
    SignalBuffer3[i]= 15; 
    SignalBuffer4[i]= 20; 
    SignalBuffer5[i]= 25; 
  }   
  return(0);
}

