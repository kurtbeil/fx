

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
	//string response = CppPyExpertRegistr("Scalping",AccountNumber(),AccountCompany(),AccountServer());
	
	//Alert("ssss");
	SendNotification("sss");
	MessageBox("","","");
}