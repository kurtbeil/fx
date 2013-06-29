//+------------------------------------------------------------------+
//|                                                  Custom MACD.mq4 |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property  copyright "Copyright © 2004, MetaQuotes Software Corp."
#property  link      "http://www.metaquotes.net/"
//---- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 2
#property  indicator_color1  Blue
#property  indicator_color2  Red
#property  indicator_width3  2
//---- indicator parameters
int FastMaPeriod=5;
int SlowMaPeriod=22;

//---- indicator buffers
double     BlueBuffer[];
double     RedBuffer[];


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
//---- drawing settings DRAW_LINE
   //SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexDrawBegin(0,SlowMaPeriod);
   //SetIndexStyle(1,DRAW_HISTOGRAM);      
   SetIndexStyle(1,DRAW_LINE);
   SetIndexDrawBegin(1,SlowMaPeriod);

   SetIndexBuffer(0,BlueBuffer);
   SetIndexBuffer(1,RedBuffer);


   return(0);
}
//+------------------------------------------------------------------+
//| Moving Averages Convergence/Divergence                           |
//+------------------------------------------------------------------+
int start()
{
   // Ö¸±ê½öÔÚ1¡¢5¡¢15·ÖÖÓÍ¼±íÉÏÏÔÊ¾
   if (Period()!= PERIOD_M1 && Period() != PERIOD_M5 && Period() != PERIOD_M15) return (0);
   
   int counted_bars=IndicatorCounted();
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   if (limit > 10000) limit = 10000; 
   int j=1;
   string tj = TimeToStr(iTime(Symbol(),PERIOD_M15,j));
   for(int i=1; i<limit; i++){
     string ti = TimeToStr(iTime(Symbol(),Period(),i));
     if(tj>ti){
       j = j + 1;
       tj = TimeToStr(iTime(Symbol(),PERIOD_M15,j));
     }
     double fastMa = iMA(Symbol(),PERIOD_M15,FastMaPeriod,0,MODE_EMA,PRICE_CLOSE,j);
     double slowMa = iMA(Symbol(),PERIOD_M15,SlowMaPeriod,0,MODE_EMA,PRICE_CLOSE,j);
     
     BlueBuffer[i] = slowMa;
     RedBuffer[i] = fastMa;
     /*
     if(fastMa>slowMa){ 
       BlueBuffer[i] = 1;
       RedBuffer[i] = 0;
     }  
     if (slowMa>fastMa){ 
       RedBuffer[i] = 1;  
       BlueBuffer[i] = 0;
     }
     */
   }
   return(0);
}
//+------------------------------------------------------------------+