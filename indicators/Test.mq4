
#property indicator_chart_window

#define LOGGING  1
string logfile = "indicator.test.log";


void log(string msg){
  if (LOGGING==1){
    int handle;
    string timestamp = TimeToStr(TimeCurrent());
    handle=FileOpen(logfile,FILE_READ|FILE_WRITE," ");  
    if(handle>0)
    {
       FileSeek(handle, 0, SEEK_END);
       FileWrite(handle,timestamp,":", msg);     
       FileClose(handle );
    }
  }
}

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   log("init():begin");
   
   log("init():end");
   return(0);
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
{ 
   log("start():begin");  
   int counted=IndicatorCounted();   
   log("counted=" +  counted);
   log("Bars=" +  Bars);   
   log("start():end");
   return(0);
}

