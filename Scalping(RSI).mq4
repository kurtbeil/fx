
#include <utility.mqh>
#include <stdlib.mqh>
#include <common.mqh>

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
---------------------------------------------------------------------------------------------------------
2013-09-3
commit id : e295da5286afbd1bad2418fd6a6b3a0e2f731948
\database\tester\pkg_scalping_tester.pck
对比数据库测试程序和mt4交易程序间的数据，目前已基本对平。
存在问题：
1、导出数据是发现，分钟图上有缺失，导致120分钟后直接关闭头寸的规则，在两种环境存在1-2分钟的误差。(已解决)
2、MT4测试时，每笔交易的利润(profit)和(开仓价-平仓价)之间存在一个误差，目前还不知道其原因。
---------------------------------------------------------------------------------------------------------
2013-09-22
commit_id : f66bc1ed3c2b0dfa072899ba1ed8f94818d31f0c
1、增加每周五23:30平仓的，且23:00后不再进行交易。
2、数据准确性:99.8%，即1000笔交易两笔存在差异，累计买卖价格误差10个万分点。

交易效果:
	 在近期的交易2013-6-20 到 2013-9-19交易效果超过 (2013-08-21的版本)


*/



// 获利范围设置
double long_tp_size = 0;
double long_sl_size = 0;
double short_tp_size = 0;
double short_sl_size = 0;

int magic;

// Rsi信号发生器设置
double long_rsi_level = 25;
double short_rsi_level = 83;
double rsi_period = 7;
int max_long_position = 5;
int max_short_position = 5;


void closelog(string msg) {
	int handle;
	string exportfile = "closelog.csv";
	string timestamp = TimeToStr(TimeCurrent());
	handle=FileOpen(exportfile,FILE_READ|FILE_WRITE|FILE_CSV ,",");
	if(handle>0) {
		FileSeek(handle, 0, SEEK_END);
		FileWrite(handle,timestamp, msg);
		FileClose(handle );
	}
}


// 交易最长时间范围设定
double trading_length = 120;


// 多头交易的时间范围
bool isLongTradingHour() {
	int hh24 = TimeHour(TimeCurrent());
	if (  hh24 == 0 || hh24 == 1  ) {
		return (true);
	} else {
		return (false);
	}
}

// 空头交易的时间范围
bool isShortTradingHour() {
	int hh24 = TimeHour(TimeCurrent());
	if (  hh24 == 0 || hh24 == 1 ) {
		return (true);
	} else {
		return (false);
	}
}


void checkForOpen() {

    if ( DayOfWeek()== 5  &&  Hour() >= 23  )  return ;    // 周五的23点以后不再开仓
	if ( Year() == 2013 && Month() == 8 && Day() == 20 ) return;  // 避开20138020的特殊情况
	// 计算对应的rsi0值
	double rsi0 = iRSI(Symbol(),Period(),rsi_period,PRICE_CLOSE,0);
	double rsi1 = iRSI(Symbol(),Period(),rsi_period,PRICE_CLOSE,1);
	// 计算当前的时间段
	int hh24 = TimeHour(TimeCurrent());

	if ( isLongTradingHour() ) {
		if (PositionCount(Symbol(),OP_BUY) + 1 <=  max_long_position ) {
			if ( rsi1 <= long_rsi_level  &&  rsi0 > long_rsi_level ) {
				// open a buy opsition
				CreatePosition(Symbol(),OP_BUY,getLots());
			}
		}
	}
	if ( isShortTradingHour() ) {
		if (PositionCount(Symbol(),OP_SELL)  + 1 <= max_short_position) {
			if ( rsi1 >= short_rsi_level  &&  rsi0 < short_rsi_level ) {
				// open a sell opsition
				CreatePosition(Symbol(),OP_SELL,getLots());
			}
		}
	}
}

void checkForClose() {
	int total;
	int i;

	// 遍历所有已开头寸检查是否满足平仓的条件
	total=OrdersTotal();
	for(i=0; i<total; i++) {
		if( OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false ) continue;
		if( OrderMagicNumber()!=magic ) continue;
		if( OrderSymbol()!=Symbol() ) continue;
		// 尝试关闭多头头寸
		if(OrderType() == OP_BUY) {
			if ( Round(Bid-OrderOpenPrice(),5) > long_tp_size ||
			        Round(OrderOpenPrice()-Bid,5) > long_sl_size ||
			        MinutesBetween(TimeCurrent(),OrderOpenTime()) >= trading_length ) {
				//ClosePosition(OrderTicket());
				PutTicketCloseQueue(OrderTicket());  // 将ticket放入待关闭队列
				closelog(TimeToStr(OrderOpenTime())+","+TimeToStr(OrderCloseTime())+","+OrderOpenPrice()+","+OrderOpenPrice());
			}
		}
		// 尝试关闭空头头寸
		if(OrderType() == OP_SELL) {
			if ( Round(OrderOpenPrice() - Ask,5) > short_tp_size ||
			        Round(Ask - OrderOpenPrice(),5) > short_sl_size ||
			        MinutesBetween(TimeCurrent(),OrderOpenTime()) >= trading_length ) {
				PutTicketCloseQueue(OrderTicket());  // 将ticket放入待关闭队列
				closelog(TimeToStr(OrderOpenTime())+","+TimeToStr(OrderCloseTime())+","+OrderOpenPrice()+","+OrderOpenPrice());
			}
		}
	}
	ClearTicketCloseQueue();  // 将队列中的头寸全部关闭

	// 时间进入周五的23:30以后,市场即将关闭,马上关闭所有头寸
	if ( DayOfWeek()== 5  &&  Hour() == 23 &&  Minute() > 30 ) {
		total=OrdersTotal();
		for(i=0; i<total; i++) {
			if( OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false ) continue;
			if( OrderMagicNumber()!=magic ) continue;
			if( OrderSymbol()!=Symbol() ) continue;
			PutTicketCloseQueue(OrderTicket());  // 将ticket放入待关闭队列
		}
	}
	ClearTicketCloseQueue();  // 将队列中的头寸全部关闭
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

int init() {
   OnInitBegin(WindowExpertName());	
    magic = GetExecuteId();
	long_tp_size = StandardPointSize() * 2;
	long_sl_size =  StandardPointSize() *  12;
	short_tp_size = StandardPointSize() * 2;
	short_sl_size = StandardPointSize() * 12;

	string exportfile = "closelog.csv";

	FileDelete(exportfile);
	int handle=FileOpen(exportfile,FILE_READ|FILE_WRITE|FILE_CSV ,",");
	if(handle>0) {
		FileSeek(handle, 0, SEEK_END);
		FileWrite(handle,"time,opentime,closetime,openprice,closeprice");
		FileClose(handle );
	}
	
}


int start() {
	if (IsFirstTick()) {
		checkForOpen();
		checkForClose();
		//string timestamp = TimeToStr(TimeCurrent());
		//if (timestamp == "2013.07.05 00:00" ) {
		//	Print("here here !");
		//}
	}
}

int deinit(){	
	OnDeinitEnd();
}


