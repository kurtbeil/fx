
#import "common.ex4"

int GetExecuteId();
string GetMainExpertName();


void OnInitBegin(string MainExpertname);
void OnInitEnd();

void OnDeinitBegin();
void OnDeinitEnd();

void OnStartBegin();
void OnStartEnd();


bool GetTradingAllowed();
string GetAccountTypeName();
double GetLotSize();
bool IsInitialized();
string GetToken();
double ConfigGetDouble(string path,double df);
int ConfigGetInt(string path,int df);
string ConfigGetString(string path,string df);