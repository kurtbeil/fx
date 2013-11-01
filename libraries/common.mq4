

#property library



int ExecuteId = 0;

int GetExecuteId() {
	return(ExecuteId);
}


int GenerateExecuteId() {
    // 目前暂用系统时间作为ExecuteId这存在重复的可能性
	// 该方法基于考虑:在同一秒时间内同时在一个客户端内执行两个不同的EA或者指标的可能性几乎为0
	// 但在不同的交易平台偶然出现出现重复，但是由于ExecuteId主要是在调用c语言的dll中对调用者做区分，
	// 在不同交易终端中使用的dll一定是不同的，所以不存在这个问题
	// ExecuteId主要还是解决同一个终端中的不同EA实例之间的冲突问题
	int ExecuteId = 0;
	ExecuteId  += Month() * 100000000;
	ExecuteId  += Day()  * 1000000;
	ExecuteId  += Hour() * 10000;
	ExecuteId  += Minute() * 100;
	ExecuteId  += Seconds() ;
	return(ExecuteId);
}

void OnInitBegin() {
	//检查是否做交易测试
	if(!IsTesting()) {
		ExecuteId = GenerateExecuteId();
	}
}

// 我们希望增加以下函数来为EA增加诸如导出数据的能力，但是如果是调用者是指标而不是EA要怎么处理?
// 以下函数开发暂缓

void OnInitEnd() {

}


void OnStartBegin() {

}


void OnStartEnd() {

}
