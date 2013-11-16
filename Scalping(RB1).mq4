
#include <utility.mqh>
#include <stdlib.mqh>
#include <common.mqh>
#include <CppUtility.mqh>


/*

1、使用了在布林带的基础上引入了阶梯式的止赢，效果明显提升 (ok)
2、头寸重入时要考虑，前一个同方向头寸的盈利情况，如果亏损那就只能在比之前头寸更有利的情况下才买进



*/

int magic;

// 获利范围设置
double long_tp_size = 0;
double long_sl_size = 0;
double short_tp_size = 0;
double short_sl_size = 0;

int max_long_position = 5;
int max_short_position = 5;

// 交易最长时间范围设定
double trading_length = 300;

int init() {
	OnInitBegin(WindowExpertName());
	magic = GetExecuteId();
	long_tp_size = StandardPointSize() *  2.5;
	long_sl_size =  StandardPointSize() *  40;
	short_tp_size = StandardPointSize() * 2.5;
	short_sl_size = StandardPointSize() * 40;
}



// 多头交易的时间范围
bool isLongTradingHour() {
	int hh24 = TimeHour(TimeCurrent());
	if (  hh24==23 || hh24 == 0 || hh24 == 1  ) {
		return (true);
	} else {
		return (false);
	}
	return(false);
}

// 空头交易的时间范围
bool isShortTradingHour() {
	int hh24 = TimeHour(TimeCurrent());
	if (  hh24==23 || hh24 == 0 || hh24 == 1 ) {
		return (true);
	} else {
		return (false);
	}
}


void checkForOpen() {
	if ( DayOfWeek()== 5  &&  Hour() >= 23  )  return ;    // 周五的23点以后不再开仓
	if ( DayOfWeek()== 1 ) return;  // 周一凌晨不交易
	if ( Year() == 2013 && Month() == 8 && Day() == 20 ) return;  // 避开20138020的特殊情况

	// 计算对应的布林带的值
	double bands_high  = iBands(Symbol(),Period(),20,2,0,PRICE_CLOSE,MODE_UPPER,1);
	double  bands_low = iBands(Symbol(),Period(),20,2,0,PRICE_CLOSE,MODE_LOWER,1);

	// 判断布林带宽度是否适合交易
	if ((bands_high-bands_low) * 10000 >= 4 && (bands_high-bands_low) * 10000 <= 8 ) {
		if ( isLongTradingHour() ) {
			// 检查是否超过对大头寸允许数量
			if (PositionCount(Symbol(),OP_BUY)  + CppGetLimitOrderCountBy(Symbol(),OP_BUY) + 1 <=  max_long_position ) {
				// 打开同方向头寸必须间隔15分钟
				if ( MinutesBetween(TimeCurrent(),GetLastPositionOpenTime(Symbol(),OP_BUY))>15 &&
				        MinutesBetween(TimeCurrent(),CppGetLastLimitOrderCrtTimeBy(Symbol(),OP_BUY))>15
				   ) {
					if ( Low[1] < bands_low ) {
						//Print("Try to open a buy position");
						CppCreateLimitOrder(Symbol(),OP_BUY,Ask-1*StandardPointSize(),getLots(),TimeCurrent()+10*60);
					}
				}
			}
		}
		if ( isShortTradingHour() ) {
			// 检查是否超过对大头寸允许数量
			if (PositionCount(Symbol(),OP_SELL)  + CppGetLimitOrderCountBy(Symbol(),OP_SELL)  + 1 <= max_short_position) {
				// 打开同方向头寸必须间隔15分钟
				if ( MinutesBetween(TimeCurrent(),GetLastPositionOpenTime(Symbol(),OP_SELL))>15 &&
				        MinutesBetween(TimeCurrent(),CppGetLastLimitOrderCrtTimeBy(Symbol(),OP_SELL)) > 15
				   ) {
					if ( High[1] > bands_high ) {
						//Print("Try to open a sell position");
						CppCreateLimitOrder(Symbol(),OP_SELL,Bid+1*StandardPointSize(),getLots(),TimeCurrent()+10*60);
					}
				}
			}
		}
	}
}


double getLongTP(int minutes) {
	int n = minutes/30;
	double ret =  long_tp_size - n*StandardPointSize();
	return (ret);
}

double getShortTP(int minutes) {
	int n = minutes/30;
	double ret = short_tp_size - n*StandardPointSize();
	return(ret);
}



void checkForClose() {
	int total;
	int i;

	double bands_high  = iBands(Symbol(),Period(),20,2,0,PRICE_CLOSE,MODE_UPPER,1);
	double  bands_low = iBands(Symbol(),Period(),20,2,0,PRICE_CLOSE,MODE_LOWER,1);

	// 遍历所有已开头寸检查是否满足平仓的条件
	total=OrdersTotal();
	for(i=0; i<total; i++) {
		if( OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false ) continue;
		if( OrderMagicNumber()!=magic ) continue;
		if( OrderSymbol()!=Symbol() ) continue;
		// 尝试关闭多头头寸
		int minutes =  MinutesBetween(TimeCurrent(),OrderOpenTime());
		if (minutes >= trading_length) {
			PutTicketCloseQueue(OrderTicket());
			continue;
		}
		//double long_tp = 2*long_tp_size*(trading_length-minutes)/trading_length-long_tp_size;
		double long_tp = getLongTP(minutes);
		if(OrderType() == OP_BUY) {
			//  检查是否达到盈利或止损条件
			if ( Round(Bid-OrderOpenPrice(),5) > long_tp ||
			        Round(OrderOpenPrice()-Bid,5) > long_sl_size  ) {
				PutTicketCloseQueue(OrderTicket());
				continue;
			}
			// 检查布林带的关闭条件是否产生
			if ( High[1] > bands_high ) {
				//PutTicketCloseQueue(OrderTicket());
				continue;
			}
		}
		// 尝试关闭空头头寸
		//double short_tp = 2*short_tp_size*(trading_length-minutes)/trading_length-short_tp_size;
		double short_tp = getShortTP(minutes);
		if(OrderType() == OP_SELL) {
			//  检查是否达到盈利或止损条件
			if ( Round(OrderOpenPrice() - Ask,5) > short_tp ||
			        Round(Ask - OrderOpenPrice(),5) > short_sl_size ) {
				PutTicketCloseQueue(OrderTicket());
				continue;
			}
			// 检查布林带的关闭条件是否产生
			if (  Low[1] < bands_low ) {
				//PutTicketCloseQueue(OrderTicket());
				continue;
			}
		}
	}
	// 将队列中的头寸全部关闭
	ClearTicketCloseQueue();

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


	// 将队列中的头寸全部关闭
	ClearTicketCloseQueue();
}


double getLots() {
	return (0.01);
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
	//Print("-----0-----");
	OnStartBegin();
	//if (IsFirstTick()) {
	//Print("-----1-----");
	checkForOpen();
	//Print("-----2-----");
	checkForClose();
	//Print("-----3-----");
	//}
	OnStartEnd();
	//Print("-----4-----");
}



