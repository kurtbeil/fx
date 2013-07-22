
#include <stdlib.mqh>

/***************************************************
 *            ����������ʱ�����ڵ�����             *
 ***************************************************/

string exportfile;

int init(){
   string company = StringReplace(AccountCompany()," ","");
   exportfile = "TB_"+company+"_"+Symbol()+"_M"+Period()+"_EveryTick.csv";  
   FileDelete(exportfile);
   int handle=FileOpen(exportfile,FILE_READ|FILE_WRITE|FILE_CSV ,","); 
   if(handle>0){
      FileSeek(handle, 0, SEEK_END);
      FileWrite(handle,"time,open,close,high,low,volume,ask,bid,rsi,n");
      FileClose(handle );    
   } 
}


// ������־
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

/***************************************************
 *                    �������ṹ                 *
 ***************************************************/

// ����ÿ���ߵĵ�1֡
int onFirstTick(){
   static int n=0;
  // ��¼���׹ؼ�����
  double rsi = iRSI(Symbol(),Period(),7,PRICE_CLOSE,0);
  
  datalog( 
    Open[1]+ "," +Close[1] + "," + High[1] + "," + Low[1]+ "," + Volume[1] + "," + Ask + "," + Bid + "," + rsi + "," + n
  );
  // Time,Open,Close,High,Low,Volume,Ask,Bid
  n++;
}

// ����ÿһ֡
int onEveryTick(){

}

// ����Ƿ��ǰ��ߵĵ�1֡
bool isFirstTick(){
  static double LastVolume= -1 ;  
  if (Volume[0] > LastVolume && LastVolume != -1 ){
    LastVolume = Volume[0];    
    return(false);
  }
  LastVolume = Volume[0];  
  return(true);
}

// ������
int start()
{ 
  if(isFirstTick()) {
    onFirstTick();  
  }
  onEveryTick();  
}





//+------------------------------------------------------------------+