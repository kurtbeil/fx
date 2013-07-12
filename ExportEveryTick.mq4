

#include <stdlib.mqh>

/***************************************************
 *            ����������ʱ�����ڵ�����             *
 ***************************************************/

string exportfile;


// ���������ļ�
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

// д������־
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

// ������
int start()
{ 
   static double lastVolume= -1,rsi ;
   static int newBar = 1,n = 0;
   // ȷ�����ߵı߽�
   if (Volume[0] >= lastVolume && lastVolume != -1 ){
      newBar = 0;
   }else{
      newBar = 1;
   } 
   lastVolume = Volume[0];
   // ��ȡ��ʱ��RSIֵ 
   rsi = iRSI(Symbol(),Period(),7,PRICE_CLOSE,0);
   // ��������
   datalog( 
     n + "," + Ask + "," + Bid + "," + Volume[0] + "," + newBar + "," + rsi + "," + StringReplace(AccountCompany()," ","") 
   );    
   n ++;
}





//+------------------------------------------------------------------+