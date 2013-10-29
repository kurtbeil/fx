
#include <stdlib.mqh>
#include <utility.mqh>
#include <common.mqh>

/***************************************************
 *           导出所经历时间周期的数据                                       *
 ***************************************************/

int init() {
	OnInitBegin(WindowExpertName());
	WriteData(
	    "export",
	    "time,open,close,high,low,volume,ask,bid,rsi,rsi1,point,n"
	);
}

// 主程序过程
int start() {
	if(IsFirstTick()) {
		static int n=0;
		double rsi = iRSI(Symbol(),Period(),7,PRICE_CLOSE,0);
		double rsi1 = iRSI(Symbol(),Period(),7,PRICE_CLOSE,1);
		double pts = (Ask-Bid) * 10000;
		WriteData(
		    "export",
		    Time[1]+"," +Open[1]+ "," +Close[1] + "," + High[1] + "," + Low[1]+ "," + Volume[1] + "," + Ask + "," + Bid + "," + rsi + "," + rsi1 + "," +pts + "," + n
		);
		n++;
	}
}





//+------------------------------------------------------------------+