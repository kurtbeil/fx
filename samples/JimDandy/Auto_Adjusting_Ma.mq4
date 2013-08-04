//+------------------------------------------------------------------+
//|                                            Auto_Adjusting_Ma.mq4 |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, JimDandy1958."
#property link      "http://www.jimdandyforex.com"

#property indicator_chart_window //shows on chart window.
#property indicator_color1 Red //default color chosen when you load it
#property indicator_width1 1 //must be one if you want to make a dashed line
#property indicator_style1 0 //solid line 1 for dashed
extern string  Ma_Settings = "SETTINGS FOR MA";
extern string  info = "Enter what you want your MA";
extern string  info2 ="to be on the 1Hour Timeframe.";
extern int     MyMaPeriod = 21;
extern int     MaShift =    0;
extern int     MaMethod =   1;
extern int     MaAppliedTo =0;
double         MyMaMultiplier;
int AdjustedMa;
double Ma_Array[];

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int init()
  {
//---- IndicatorShortName   
   int period = Period();//get the timeframe minutes
   MaAdjuster(period);//call function and send along timeframe
   AdjustedMa =MyMaPeriod*MyMaMultiplier;//Adjust Moving average accordingly
   SetIndexBuffer(0,Ma_Array);//tie Ma_Array to Index Zero
   SetIndexStyle (0,DRAW_LINE,STYLE_SOLID,1,Red);//set Index 0 to draw a solid line
   SetIndexDrawBegin(0,AdjustedMa);//set it to start drawing the appropriate number of candles from the left.
   SetIndexLabel(0,"Auto_Adjusting_Ma");//set what the user sees when he mouses over the MA
//----
   return(0);
   }   


//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }


//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int counted_bars=IndicatorCounted();
   if(counted_bars<0)return(-1);
   if(counted_bars>0) counted_bars--;
   int uncountedbars=Bars-counted_bars;
   
//---      
for(int i=0;i<uncountedbars;i++)
{
   Ma_Array[i]=iMA(NULL,0,AdjustedMa,MaShift,MaMethod,MaAppliedTo,i); 
}

//----
   return(0);
  }



//+------------------------------------------------------------------+
//| Custom indicator multiplier function                              |
//+------------------------------------------------------------------+

void MaAdjuster(int number)
{
   switch(number)
   {
   case 1:MyMaMultiplier=60;break;//added 1m timeframe
   case 5:MyMaMultiplier=12;break;
   case 15:MyMaMultiplier=4;break;
   case 30:MyMaMultiplier=2;break;
   case 60:MyMaMultiplier=1;break;
   case 240:MyMaMultiplier=0.25;break;
   }
}

