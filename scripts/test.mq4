

#include <CppUtility.mqh>
#include <common.mqh>
#include <utility.mqh>
#property show_confirm


int init() {
	//OnInitBegin(WindowExpertName());
	return(0);
}

int deinit(){	
	//OnDeinitEnd();
}



int start() {	
	string file = "I:\\Program Files\\HotForex MetaTrader\\experts\\config\\pycfg\\Scalping.py";
	string var = "config/HF Markets Ltd/Micro/EURCAD/M1/bands_period";
	int p = 0,q=0;
	
	string result = CppPyConfigRead(file,var);		
	Print("result=",result);
	string type = CppPyResultReadType(result);
	Print("type=",type);
	string value = CppPyResultReadValue(result);
	Print("value=",value);
	
	double d1 = CppPyConfigReadDouble(file,var,1.0);
	Print("d1=",d1);
	
	int d2 = CppPyConfigReadInt(file,var,1);
	Print("d1=",d1);
	
	
	//pos = StringFind(result,":",7+1);
	//Print("pos=",pos);
	
	
}