

#include <stdlib.mqh>

/***************************************************
 *            导出所经历时间周期的数据             *
 ***************************************************/

string exportfile;


// 创建导出文件
int init(){
  exportfile = "TB_"+Symbol()+"_M"+Period()+"_EveryTick.csv";  
  int handle;
  handle=FileOpen(exportfile,FILE_READ|FILE_WRITE|FILE_CSV ,","); 
  if(handle>0){
    FileSeek(handle, 0, SEEK_END);
    FileWrite(handle,"Time,N,Ask,Bid,Volume,NewBar,Rsi");
    FileClose(handle );    
  } 
}

// 写数据日志
void datalog(string msg){
    int handle;
    string timestamp = TimeToStr(TimeCurrent());
    handle=FileOpen(exportfile,FILE_READ|FILE_WRITE|FILE_CSV ,",");  
    if(handle>0)
    {
      FileSeek(handle, 0, SEEK_END);
      FileWrite(handle,timestamp, msg);     
      FileClose(handle );
    }  
}

// 主程序
int start()
{ 
   static double lastVolume= -1,rsi ;
   static int newBar = 1,n = 0;
   // 确定棒线的边界
   if (Volume[0] >= lastVolume && lastVolume != -1 ){
      newBar = 0;
   }else{
      newBar = 1;
   } 
   lastVolume = Volume[0];
   // 获取即时的RSI值 
   rsi = iRSI(Symbol(),Period(),7,PRICE_CLOSE,0);
   // 导出数据
   datalog( 
     n + "," + Ask + "," + Bid + "," + Volume[0] + "," + newBar + "," + rsi + "," + StringReplace(AccountCompany()," ","") 
   );    
   n ++;
}





//+------------------------------------------------------------------+