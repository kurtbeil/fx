//+------------------------------------------------------------------+
//|                                            Moving Average EA.mq4 |
//|                        Copyright 2013, JimDandy1958
//|                                        http://www.jimdandyforex.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, JimDandy1958"
#property link      "http://www.jimdandyforex.com"

extern int TakeProfit=500;
extern int StopLoss=150;
extern double LotSize = 0.01;

extern bool UseMoveToBreakeven=true;
extern int 	WhenToMoveToBE=100;
extern int  PipsToLockIn=5;

extern bool UseTrailingStop = true;
extern int  WhenToTrail=200;
extern int  TrailAmount=200;

extern int FastMA=5;
extern int FastMaShift=0;
extern int FastMaMethod=0;
extern int FastMaAppliedTo=0;

extern int SlowMA=21;
extern int SlowMaShift=0;
extern int SlowMaMethod=0;
extern int SlowMaAppliedTo=0;

extern int  MagicNumber = 1234;
double pips;

//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
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
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
  if(OpenOrdersThisPair(Symbol())>=1)
   {
      if(UseMoveToBreakeven)MoveToBreakeven();
      if(UseTrailingStop)AdjustTrail();
   }
   if(IsNewCandle())CheckForMaTrade();
//----
   return(0);
  }
//+------------------------------------------------------------------+
//Move to breakeven function
//+------------------------------------------------------------------+
void MoveToBreakeven()
{
   for(int b=OrdersTotal()-1; b >= 0; b--)
	{
	if(OrderSelect(b,SELECT_BY_POS,MODE_TRADES))
      if(OrderMagicNumber()== MagicNumber)
         if(OrderSymbol()==Symbol())
            if(OrderType()==OP_BUY)
               if(Bid-OrderOpenPrice()>WhenToMoveToBE*pips)
                  if(OrderOpenPrice()>OrderStopLoss())
                     OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+(PipsToLockIn*pips),OrderTakeProfit(),0,CLR_NONE);
   }
   for (int s=OrdersTotal()-1; s >= 0; s--)
	     {
         if(OrderSelect(s,SELECT_BY_POS,MODE_TRADES))
	        if(OrderMagicNumber()== MagicNumber)
	           if(OrderSymbol()==Symbol())
	              if(OrderType()==OP_SELL)
                  if(OrderOpenPrice()-Ask>WhenToMoveToBE*pips)
                     if(OrderOpenPrice()<OrderStopLoss())    
                        OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-(PipsToLockIn*pips),OrderTakeProfit(),0,CLR_NONE);
        }
}
//+------------------------------------------------------------------+
//trailing stop function
//+------------------------------------------------------------------+
void AdjustTrail()
{

//buy order section
      for(int b=OrdersTotal()-1;b>=0;b--)
	      {
         if(OrderSelect(b,SELECT_BY_POS,MODE_TRADES))
           if(OrderMagicNumber()==MagicNumber)
              if(OrderSymbol()==Symbol())
                  if(OrderType()==OP_BUY)
                     if(Bid-OrderOpenPrice()>WhenToTrail*pips) 
                        if(OrderStopLoss()<Bid-pips*TrailAmount)
                           OrderModify(OrderTicket(),OrderOpenPrice(),Bid-(pips*TrailAmount),OrderTakeProfit(),0,CLR_NONE);
         }
//sell order section
      for(int s=OrdersTotal()-1;s>=0;s--)
	      {
         if(OrderSelect(s,SELECT_BY_POS,MODE_TRADES))
            if(OrderMagicNumber()== MagicNumber)
               if(OrderSymbol()==Symbol())
                  if(OrderType()==OP_SELL)
                     if(OrderOpenPrice()-Ask>WhenToTrail*pips)
                        if(OrderStopLoss()>Ask+TrailAmount*pips)
                           OrderModify(OrderTicket(),OrderOpenPrice(),Ask+(TrailAmount*pips),OrderTakeProfit(),0,CLR_NONE);
         }
}
//+------------------------------------------------------------------+
//insuring its a new candle function
//+------------------------------------------------------------------+
bool IsNewCandle()
{
   static int BarsOnChart=0;
	if (Bars == BarsOnChart)
	return (false);
	BarsOnChart = Bars;
	return(true);
}
//+------------------------------------------------------------------+
//function that checks or an Ma cross
//+------------------------------------------------------------------+
void CheckForMaTrade()
{
double PreviousFast = iMA(NULL,0,FastMA,FastMaShift,FastMaMethod,FastMaAppliedTo,2); 
double CurrentFast = iMA(NULL,0,FastMA,FastMaShift,FastMaMethod,FastMaAppliedTo,1); 
double PreviousSlow= iMA(NULL,0,SlowMA,SlowMaShift,SlowMaMethod,SlowMaAppliedTo,2); 
double CurrentSlow = iMA(NULL,0,SlowMA,SlowMaShift,SlowMaMethod,SlowMaAppliedTo,1); 
if(PreviousFast<PreviousSlow && CurrentFast>CurrentSlow)OrderEntry(0);
if(PreviousFast>PreviousSlow && CurrentFast<CurrentSlow)OrderEntry(1);
}
//+------------------------------------------------------------------+
//order entry function
//+------------------------------------------------------------------+
void OrderEntry(int direction)
{
   if(direction==0)
   {
      double bsl=0;
      double btp=0;
      if(StopLoss!=0)bsl=Ask-(StopLoss*pips);
      if(TakeProfit!=0)btp=Ask+(TakeProfit*pips);
      if(OpenOrdersThisPair(Symbol())==0)int buyticket = OrderSend(Symbol(),OP_BUY,LotSize,Ask,3,0,0,NULL,MagicNumber,0,Green);
      if(buyticket>0)OrderModify(buyticket,OrderOpenPrice(),bsl,btp,0,CLR_NONE);
   }
   
   if(direction==1)
   {
      double ssl=0;
      double stp=0;
      if(StopLoss!=0)ssl=Bid+(StopLoss*pips);
      if(TakeProfit!=0)stp=Bid-(TakeProfit*pips);
      if(OpenOrdersThisPair(Symbol())==0)int sellticket = OrderSend(Symbol(),OP_SELL,LotSize,Bid,3,0,0,NULL,MagicNumber,0,Red);
      if(sellticket>0)OrderModify(sellticket,OrderOpenPrice(),ssl,stp,0,CLR_NONE);
   }
   
}
//+------------------------------------------------------------------+
//checks to see if any orders open on this currency pair.
//+------------------------------------------------------------------+
int OpenOrdersThisPair(string pair)
{
  int total=0;
   for(int i=OrdersTotal()-1; i >= 0; i--)
	  {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);
      if(OrderSymbol()== pair) total++;
	  }
	  return (total);
}
//+------------------------------------------------------------------+
	