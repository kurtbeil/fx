#property copyright ""
#property link      ""

#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 300
#property indicator_buffers 6
#property indicator_color1 Red
#property indicator_color2 Green
#property indicator_color3 Silver
#property indicator_color4 Silver
#property indicator_color5 Silver
#property indicator_color6 Silver




double K_LengthBuffer1[]; 
double K_LengthBuffer2[];

double SignalBuffer1[];
double SignalBuffer2[];
double SignalBuffer3[];
double SignalBuffer4[];


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   IndicatorBuffers(6);          
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,K_LengthBuffer1);     
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(1,K_LengthBuffer2);   
   
   //---------------------
   SetIndexStyle(2,DRAW_LINE,STYLE_DOT);
   SetIndexBuffer(2,SignalBuffer1);  
   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,SignalBuffer2);  
   SetIndexStyle(4,DRAW_LINE,STYLE_DOT);
   SetIndexBuffer(4,SignalBuffer3);  
   SetIndexStyle(5,DRAW_LINE);
   SetIndexBuffer(5,SignalBuffer4);  

   return(0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
{ 
  for(int i=0;i<Bars;i++){ 
    if(Close[i]>Open[i]){
      K_LengthBuffer1[i]=(High[i]-Low[i])*10000;  
      K_LengthBuffer2[i]=0;   
    }else{    
      K_LengthBuffer2[i]=(High[i]-Low[i])*10000;   
      K_LengthBuffer1[i]=0;
    }    
    SignalBuffer1[i]= 100; 
    SignalBuffer2[i]= 150; 
    SignalBuffer3[i]= 200;     
    SignalBuffer4[i]= 250;     
  }   
  return(0);
}

