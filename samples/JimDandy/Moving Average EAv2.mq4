//+------------------------------------------------------------------+
//|                                            Moving Average EA.mq4 |
//|                        Copyright 2013, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

extern int TakeProfit=50;
extern int StopLoss=25;
extern int FastMA=5;
extern int FastMaShift=0;
extern int FastMaMethod=0;
extern int FastMaAppliedTo=0;
extern int SlowMA=21;
extern int SlowMaShift=0;
extern int SlowMaMethod=0;
extern int SlowMaAppliedTo=0;
extern double LotSize = 0.01;
extern int  MagicNumber = 1234;
double pips;

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
   	double ticksize = MarketInfo(Symbol(), MODE_TICKSIZE);
   	if (ticksize == 0.00001 || ticksize == 0.001)
	   pips = ticksize*10;
	   else pips =ticksize;
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
//----
   if(IsNewCandle())CheckForMaTrade();
//----
   return(0);
  }
//+------------------------------------------------------------------+

bool IsNewCandle()
{
   static int BarsOnChart=0;
	if (Bars == BarsOnChart)
	return (false);
	BarsOnChart = Bars;
	return(true);
}
void CheckForMaTrade()
{
double PreviousFast = iMA(NULL,0,FastMA,FastMaShift,FastMaMethod,FastMaAppliedTo,2); 
double CurrentFast = iMA(NULL,0,FastMA,FastMaShift,FastMaMethod,FastMaAppliedTo,1); 
double PreviousSlow= iMA(NULL,0,SlowMA,SlowMaShift,SlowMaMethod,SlowMaAppliedTo,2); 
double CurrentSlow = iMA(NULL,0,SlowMA,SlowMaShift,SlowMaMethod,SlowMaAppliedTo,1); 
if(PreviousFast<PreviousSlow && CurrentFast>CurrentSlow)OrderEntry(0);
if(PreviousFast>PreviousSlow && CurrentFast<CurrentSlow)OrderEntry(1);
}


void OrderEntry(int direction)
{
   if(direction==0)
      if(OrdersTotal()==0)
         OrderSend(Symbol(),OP_BUY,LotSize,Ask,3,Ask-(StopLoss*pips),Ask+(TakeProfit*pips),NULL,MagicNumber,0,Green);
   if(direction==1)
      if(OrdersTotal()==0)
         OrderSend(Symbol(),OP_SELL,LotSize,Bid,3,Bid+(StopLoss*pips),Bid-(TakeProfit*pips),NULL,MagicNumber,0,Red);
}

