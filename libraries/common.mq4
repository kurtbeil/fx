#property library

#include <CppUtility.mqh>
#include <utility.mqh>


int GetExecuteId() {
	//return(GlobalVariableGet("ExecuteId"));
	return(StrToInteger(ObjectDescription("ExecuteId")));
}

void GenerateExecuteId() {
	// 目前暂用系统时间作为ExecuteId这存在重复的可能性
	// 该方法基于考虑:在同一秒时间内同时在一个客户端内执行两个不同的EA或者指标的可能性几乎为0
	// 但在不同的交易平台偶然出现出现重复，但是由于ExecuteId主要是在调用c语言的dll中对调用者做区分，
	// 在不同交易终端中使用的dll一定是不同的，所以不存在这个问题
	// ExecuteId主要还是解决同一个终端中的不同EA实例之间的冲突问题
	// 用系统时间作为ExecuteId不是一个十分严密的方法，但是为了能用和OrderMagicNumber关联起来，
	// 只能保留期32为整型数的类型（如果扩展类型长度我们能保证这个不重复），
	// 所以系统时间（到秒）可能是一个比较合适的选择。

	/*
	该方法存在的问题主要是一旦周末系统关闭，市场时间停留在关闭前一刻，如果此时正好操作挂多个EA，则ExecuteId重复
	int ExecuteId = 0;
	ExecuteId  += Month() * 100000000;
	ExecuteId  += Day()  * 1000000;
	ExecuteId  += Hour() * 10000;
	ExecuteId  += Minute() * 100;
	ExecuteId  += Seconds() ;
	*/

	// 使用windows的系统时间做为ExecuteId
	int ExecuteId = 0;
	ExecuteId = CppGenerateExecuteId();
	// 是在没有办法由于 MQL4 的全局变量在不同的文件里调用有不同的拷贝,导致无法将ExecuteId存放在一个普通的全局变量中,
	// 使用GlobalVariableGet 也达不到目的因为该变量的范围是整个MT4程序的所有窗口
	// 使用Cpp库也解决不了这个问题，因为调用Cpp库首先要解决唯一调用标识的问题
	// 所有最终的解决方法,使用MQL4是的Object相关函数,这样的解决方法并不干净,其他EA和Indicator可能会对此造成干扰,在界面上
	// 也存在删除这个对象的可能，但没有办法这是目前知道的唯一解决办法。
	ObjectCreate("ExecuteId", OBJ_LABEL, 0, 0, 0);
	ObjectSetText("ExecuteId",DoubleToStr(ExecuteId,0) , 10, "Times New Roman", Red);
	ObjectSet("ExecuteId", OBJPROP_YDISTANCE, 15);
	ObjectSet("ExecuteId", OBJPROP_XDISTANCE, 5);
}

string GetMainExpertName() {
	return(CppGlobalStringGet("MainExpertName"));
}


void ProcessLimitOrder() {
	int count = CppGetLimitOrderCount() ;
	for(int i = 0; i < count; i++) {
		int ticket = 0;
		if ( (Ask <= CppGetLimitOrderPrice() && CppGetLimitOrderType() == OP_BUY ) ||
		        (Bid >= CppGetLimitOrderPrice() && CppGetLimitOrderType() == OP_SELL )) {
			ticket = CreatePosition(CppGetLimitOrderSymbol(),CppGetLimitOrderType(),CppGetLimitOrderLots());
		}
		if ( ticket > 0  || TimeCurrent() > CppGetLimitOrderExpdate()) {
			// 创建成功或者已经超时
			CppRemoveLimitOrder();
		} else {
			// 创建失败将当前订单放至队尾，待下次重试
			CppTurnLimitOrder();
		}
	}
}


void OnInitBegin(string MainExpertName) {
	//GlobalVariableSet("ExecuteId",GenerateExecuteId());
	GenerateExecuteId();
	CppGlobalStringSet("MainExpertName",MainExpertName);
}

// 我们希望增加以下函数来为EA增加诸如导出数据的能力，但是如果是调用者是指标而不是EA要怎么处理?
// 以下函数开发暂缓

void OnInitEnd() {

}


void OnStartBegin() {

}


void OnStartEnd() {
	ProcessLimitOrder();
}


void OnDeinitBegin() {

}

void OnDeinitEnd() {
	// 删除所有挂单
	int count = CppGetLimitOrderCount() ;
	for(int i = 0; i < count; i++) {
		CppRemoveLimitOrder();
	}		
	//  删除调用标识
	ObjectDelete("ExecuteId");
}