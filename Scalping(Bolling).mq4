
#include <utility.mqh>
#include <stdlib.mqh>

#define MAGIC  102

/*
 使用布林带实现把头皮战术
 (1)  实现近距离限价单的能力
 (2)  是否引入信号关闭机制
 (3)  
 
*/



// 获利范围设置
double long_tp_size = 0;
double long_sl_size = 0;
double short_tp_size = 0;
double short_sl_size = 0;

// Rsi信号发生器设置
double long_rsi_level = 25;
double short_rsi_level = 83;
double rsi_period = 7;
int max_long_position = 5;
int max_short_position = 5;

int init() {
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
	// 计算对应的rsi0值
	double rsi0 = iRSI(Symbol(),Period(),rsi_period,PRICE_CLOSE,0);
	double rsi1 = iRSI(Symbol(),Period(),rsi_period,PRICE_CLOSE,1);
	// 计算当前的时间段
	int hh24 = TimeHour(TimeCurrent());

	if ( isLongTradingHour() ) {
		if (PositionCount(Symbol(),OP_BUY,MAGIC) + 1 <=  max_long_position ) {
			if ( rsi1 <= long_rsi_level  &&  rsi0 > long_rsi_level ) {
				// open a buy opsition
				CreatePosition(Symbol(),OP_BUY,getLots(),MAGIC);
			}
		}
	}
	if ( isShortTradingHour() ) {
		if (PositionCount(Symbol(),OP_SELL,MAGIC)  + 1 <= max_short_position) {
			if ( rsi1 >= short_rsi_level  &&  rsi0 < short_rsi_level ) {
				// open a sell opsition
				CreatePosition(Symbol(),OP_SELL,getLots(),MAGIC);
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
		if( OrderMagicNumber()!=MAGIC ) continue;
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
			if( OrderMagicNumber()!=MAGIC ) continue;
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



