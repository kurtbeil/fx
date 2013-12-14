
#include <utility.mqh>
#include <stdlib.mqh>
#include <common.mqh>
#include <CppUtility.mqh>


/*

1、使用了在布林带的基础上引入了阶梯式的止赢，效果明显提升 (ok)
2、头寸重入时要考虑，前一个同方向头寸的盈利情况，如果亏损那就只能在比之前头寸更有利的情况下才买进

*/

int magic;

// 布林带周期及标准差倍数
int bands_period = 20;
int bands_deviation = 2;

// 交易时布林带宽度限制(按标准点计算)
double bands_wide_min = 4;
double bands_wide_max = 8;

// 两次开仓的时间间隔
int position_interval = 15;

// 获利范围设置(按标准点设置),init程序会将其转化为价格范围
double long_tp_pts = 2.8;
double long_sl_pts = 40;
double short_tp_pts = 2.8;
double short_sl_pts = 40;

double long_tp_size = 0;
double long_sl_size = 0;
double short_tp_size = 0;
double short_sl_size = 0;

// 最大持仓数量
int max_long_position = 3;
int max_short_position = 3;

// 限价单和现价的差距(按标准点设置)
double limit_order_price_gap = 1;

// 限价挂单单的生存时间(按分钟设定)
double limit_order_living_time = 10;

// 交易最长时间范围设定(按分钟设定)
double trading_length = 300;


int  long_trading_hours [24]= {1,1,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,1};
int  short_trading_hours [24]= {1,1,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,1};


// 多头交易的时间范围
bool isLongTradingHour() {
	int i = TimeHour(TimeCurrent());	
	if ( long_trading_hours[i] == 1 ) {
		return (true);
	} else {
		return (false);
	}	
}

// 空头交易的时间范围
bool isShortTradingHour() {
	int i = TimeHour(TimeCurrent());
	if ( short_trading_hours[i] == 1  ) {
		return (true);
	} else {
		return (false);
	}
}


void CheckForOpen() {
	if ( DayOfWeek()== 5  &&  Hour() >= 23  )  return ;    // 周五的晚上不开仓
	if ( DayOfWeek()== 1 ) return;  // 周一凌晨不交易
	if ( Year() == 2013 && Month() == 8 && Day() == 20 ) return;  // 避开20138020的特殊情况

	// 计算对应的布林带的值
	double bands_high  = iBands(Symbol(),Period(),bands_period,bands_deviation,0,PRICE_CLOSE,MODE_UPPER,1);
	double  bands_low = iBands(Symbol(),Period(),bands_period,bands_deviation,0,PRICE_CLOSE,MODE_LOWER,1);

	// 判断布林带宽度是否适合交易
	if ((bands_high-bands_low) * 10000 >= bands_wide_min && (bands_high-bands_low) * 10000 <= bands_wide_max ) {
		if ( isLongTradingHour() ) {
			// 检查是否超过对大头寸允许数量
			if (PositionCount(Symbol(),OP_BUY)  + CppGetLimitOrderCountBy(Symbol(),OP_BUY) + 1 <=  max_long_position ) {
				// 打开同方向头寸必须间隔一定分钟数(由position_interval指定)
				if ( MinutesBetween(TimeCurrent(),GetLastPositionOpenTime(Symbol(),OP_BUY))>position_interval &&
				        MinutesBetween(TimeCurrent(),CppGetLastLimitOrderCrtTimeBy(Symbol(),OP_BUY))>position_interval
				   ) {
					if ( Low[1] < bands_low ) {
						//Print("Try to open a buy position");
						CppCreateLimitOrder(Symbol(),OP_BUY,Ask-limit_order_price_gap*StandardPointSize(),getLots(),TimeCurrent()+limit_order_living_time*60);
					}
				}
			}
		}
		if ( isShortTradingHour() ) {
			// 检查是否超过对大头寸允许数量
			if (PositionCount(Symbol(),OP_SELL)  + CppGetLimitOrderCountBy(Symbol(),OP_SELL)  + 1 <= max_short_position) {
				// 打开同方向头寸必须间隔一定分钟数(由position_interval指定)
				if ( MinutesBetween(TimeCurrent(),GetLastPositionOpenTime(Symbol(),OP_SELL))>position_interval &&
				        MinutesBetween(TimeCurrent(),CppGetLastLimitOrderCrtTimeBy(Symbol(),OP_SELL)) > position_interval
				   ) {
					if ( High[1] > bands_high ) {
						//Print("Try to open a sell position");
						CppCreateLimitOrder(Symbol(),OP_SELL,Bid+limit_order_price_gap*StandardPointSize(),getLots(),TimeCurrent()+limit_order_living_time*60);
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



void CheckForClose() {
	int total;
	int i;

	double bands_high  = iBands(Symbol(),Period(),bands_period,bands_deviation,0,PRICE_CLOSE,MODE_UPPER,1);
	double  bands_low = iBands(Symbol(),Period(),bands_period,bands_deviation,0,PRICE_CLOSE,MODE_LOWER,1);

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
	return (GetLotSize());
}


void LoadTradingConfig(){
	int i;
	
    // 从配置文件中读取参数
	bands_period = ConfigGetDouble("bands_period",bands_period);
	bands_deviation = ConfigGetDouble("bands_deviation",bands_deviation);	
	bands_wide_min = ConfigGetDouble("bands_wide_min",bands_wide_min);
	bands_wide_max = ConfigGetDouble("bands_wide_max",bands_wide_max);
	position_interval = ConfigGetDouble("position_interval",position_interval); 
	long_tp_pts = ConfigGetDouble("long_tp_pts",long_tp_pts); 
	long_sl_pts = ConfigGetDouble("long_sl_pts",long_sl_pts); 
	short_tp_pts = ConfigGetDouble("short_tp_pts",short_tp_pts); 
	short_sl_pts = ConfigGetDouble("short_sl_pts",short_sl_pts); 
	max_long_position = ConfigGetDouble("max_long_position",max_long_position); 
	max_short_position = ConfigGetDouble("max_short_position",max_short_position); 
	limit_order_price_gap = ConfigGetDouble("limit_order_price_gap",limit_order_price_gap); 
	limit_order_living_time = ConfigGetDouble("limit_order_living_time",limit_order_living_time); 
	trading_length = ConfigGetDouble("trading_length",trading_length); 
	for(i=0;i<24;i++){
		long_trading_hours[i] = ConfigGetDouble("long_trading_hours/"+i,long_trading_hours[i]);
		short_trading_hours[i] = ConfigGetDouble("short_trading_hours/"+i,short_trading_hours[i]);	
	}
	// 将以点差设置的止赢和止损转化为实际价格范围 
	long_tp_size = StandardPointSize() *  long_tp_pts;
	long_sl_size =  StandardPointSize() *  long_sl_pts;
	short_tp_size = StandardPointSize() * short_tp_pts;
	short_sl_size = StandardPointSize() * short_sl_pts;
	
	// 打印所有参数
	Print("bands_period=",bands_period);
	Print("bands_deviation=",bands_deviation);
	Print("bands_wide_min=",bands_wide_min);
	Print("bands_wide_max=",bands_wide_max);
	Print("position_interval=",position_interval);
	Print("long_tp_pts=",long_tp_pts);
	Print("long_sl_pts=",long_sl_pts);
	Print("short_tp_pts=",short_tp_pts);
	Print("short_sl_pts=",short_sl_pts);
	Print("max_long_position=",max_long_position);
	Print("max_short_position=",max_short_position);
	Print("limit_order_price_gap=",limit_order_price_gap);
	Print("limit_order_living_time=",limit_order_living_time);
	Print("trading_length=",trading_length);
	
	for(i=0; i<24; i++){
		Print("long_trading_hours["+i+"]=",long_trading_hours[i]);
	}
	for(i=0; i<24; i++){
		Print("short_trading_hours["+i+"]=",short_trading_hours[i]);
	}
	
}


int init() {
	// 调用init()开始事件	
	OnInitBegin(WindowExpertName());
	// 如果初始化失败不做后续动作
	if(!IsInitialized()){
		return;
	}	
	
	// 设置magic
	magic = GetExecuteId();
		
	// 如果初始化成功，才读取相关参数
	LoadTradingConfig();	
		
	// 调用init()结束事件
	OnInitEnd();
}


int deinit(){	
	// 如果初始化失败，不进行任何动作
	if(!IsInitialized()){
		return;
	}	
	// 调用deinit()开始事件
	OnDeinitBegin();
	
	// 调用deinit()结束事件
	OnDeinitEnd();
}



void start()
{	
	// 如果初始化失败，不进行任何动作
	if(!IsInitialized()) {
		return;
	}
		
	// 发送start()开始事件
	OnStartBegin();
	
	// 调用交易逻辑
	if (GetTradingAllowed()){
		CheckForOpen();
	}
	CheckForClose();			
	
	// 发送start()结束事件
	OnStartEnd();	
}  



