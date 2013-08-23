
#include <utility.mqh>
#include <stdlib.mqh>

#define MAGIC  102

/*

---------------------------------------------------------------------------------------------------------
2013-08-04  一个初步可用把头皮交易方法
commit id : 267345753012947d87d7b07789c8d6582efd44cd
程序在HotForex市场中的数据（时间2013-05-23至2013-07-30），且使用点差10点（10万分点）或以下，
可以勉强获利，但是在我们所设定的交易时间范围内点差通常在30点左右。
疑问：在交易测试中，交易记录的开仓价和平仓价间的价差，要比系统计算获利值高出20点左右，目前尚
不知是什么原因，但观察“落雨”的交易记录也有发现类似情况，但其差别量小得多。
---------------------------------------------------------------------------------------------------------
2013-08-04  通过数据分析结果对程序进行优化
commit id : fb09c1c53a00a6967b7bf9503e7847f9397c57ff
之前通过 pyfx/scalping/pkg_luoyu_test 数据进行计算的出一些结论，现将这些结论应用在本交易程序中，
主要是：
  1、多空头寸需要不同的tp和sl设定。
  2、多空交易时间段也应有所区别。
  3、rsi的信号范围应有所区别

里程碑:
1、交易系统的参数更加灵活了
2、获得了一套比较优化的参数，使得交易系统在点差20点（10万分点）或以下,具备正期望。

下一步:
1、进一步优化的空间不会非常大，应该尝试引入新的过滤器提高交易的盈利潜力  
2、通过挂线交易来分析交易系统的合理性和缺陷
---------------------------------------------------------------------------------------------------------
2013-08-21
commit id : 437c89a7efda6a8d15ee67317e881f1877c4adf9
将之前的RSI周期调整为16获得了更好的交易效果，能在30点点差（10万分点）情况下具备正期望
master
*/


datetime lastBuyCreated =EMPTY;
datetime lastSellCreated =EMPTY;

double takeprofit = 5;
double stoploss = 15;

 
// 获利范围设置
double long_tp_size = 0;
double long_sl_size = 0;
double short_tp_size = 0;
double short_sl_size = 0;

// Rsi信号发生器设置
double long_rsi_low = 0;
double long_rsi_high = 30;
double short_rsi_low = 70;
double short_rsi_high = 100;



int init(){
   long_tp_size = 0.0001 * 2.5;
   long_sl_size =  0.0001 * 18;
   short_tp_size  = 0.0001 * 6;
   short_sl_size = 0.0001 * 16;
}


// 交易最长时间范围设定
double trading_length = 120;


// 多头交易的时间范围
bool isLongTradingHour() {
	int hh24 = TimeHour(TimeCurrent());
	//if ( hh24 == 22 || hh24 == 23 || hh24 == 0 || hh24 == 2 ) {
	if ( hh24 == 23 || hh24 == 0 || hh24 == 1 || hh24 == 2 ) {
		//if (  hh24 == 0 ) {
		return (true);
	} else {
		return (false);
	}	
}

// 空头交易的时间范围
bool isShortTradingHour() {
	int hh24 = TimeHour(TimeCurrent());
	if ( hh24 == 22 || hh24 == 0 ) {
		//if (  hh24 == 0 ) {
		return (true);
	} else {
		return (false);
	}	
}



void checkForOpen() {
	double rsi = iRSI(Symbol(),Period(),7,PRICE_CLOSE,0);
	int hh24 = TimeHour(TimeCurrent());
	//Print("PositionCount(Symbol(),OP_BUY,MAGIC)=" + PositionCount(Symbol(),OP_BUY,MAGIC));
	//PositionCount(Symbol(),OP_BUY,MAGIC);
	if ( isLongTradingHour() ) {
		//if ( lastBuyCreated == EMPTY || !isSameHour(TimeCurrent(),lastBuyCreated) ) {
		if (PositionCount(Symbol(),OP_BUY,MAGIC) == 0 ) {
			if ( rsi >= long_rsi_low  &&  rsi <= long_rsi_high ) {
				// open a buy opsition
				lastBuyCreated = TimeCurrent();
				CreatePosition(Symbol(),OP_BUY,getLots(),MAGIC);
			}
		}
	}
	if ( isShortTradingHour() ) {
		//if( lastSellCreated == EMPTY || !isSameHour(TimeCurrent(),lastSellCreated) ) {
		if (PositionCount(Symbol(),OP_SELL,MAGIC) == 0 ) {
		if ( rsi > short_rsi_low  &&  rsi < short_rsi_high ) {
				// open a sell opsition
				lastSellCreated = TimeCurrent();
				CreatePosition(Symbol(),OP_SELL,getLots(),MAGIC);
			}
		}
	}
}

void checkForClose() {
	bool ret;
	int ticket;
	for(int i=0; i<OrdersTotal(); i++) {
		if( OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false ) continue;
		if( OrderMagicNumber()!=MAGIC ) continue;
		if( OrderSymbol()!=Symbol() ) continue;
		if(OrderType() == OP_BUY) {
			if ( Bid-OrderOpenPrice() > long_tp_size ||
			        OrderOpenPrice()-Bid > long_sl_size ||
			        MinutesBetween(TimeCurrent(),lastBuyCreated) > trading_length ) {
				ClosePosition(OrderTicket());
				//writeOpenLog(OrderType()+","+TimeToStr(OrderOpenTime())+","+OrderOpenPrice()+","+TimeToStr(TimeCurrent())+","+Bid);
			}

		}
		if(OrderType() == OP_SELL) {
			if ( OrderOpenPrice() - Ask > short_tp_size ||
			        Ask-OrderOpenPrice() > short_sl_size ||
			        MinutesBetween(TimeCurrent(),lastSellCreated) > trading_length ) {
				ClosePosition(OrderTicket());
				//writeOpenLog(OrderType()+","+TimeToStr(OrderOpenTime())+","+OrderOpenPrice()+","+TimeToStr(TimeCurrent())+","+Ask);
			}
		}

	}
}




double getLots() {
	return (0.1);
}



/*
double getLots(){
  double lots;     
  lots = AccountBalance()/10000;
  //Print("lots="+lots);
  lots = MathRound(lots*10)/10;  
  if(lots<0.1) lots=0.1;  
  return (lots);    
}
*/


bool isFirstTick() {
	static double LastVolume= -1 ;
	if (Volume[0] >= LastVolume && LastVolume != -1 ) {
		LastVolume = Volume[0];
		return(false);
	}
	LastVolume = Volume[0];
	return(true);
}


int start() {
	if (isFirstTick()) {
		checkForOpen();		
	}
	checkForClose();
}



