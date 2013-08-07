
#include <stdlib.mqh>

/***************************************************
 *           å¯¼å‡ºæ‰€ç»åŽ†æ—¶é—´å‘¨æœŸçš„æ•°æ®                                       *
 ***************************************************/

string exportfile;

int init(){
   string company = StringReplace(AccountCompany()," ","");
   exportfile = "TB_"+company+"_"+Symbol()+"_M"+Period()+".csv";  
   FileDelete(exportfile);
   int handle=FileOpen(exportfile,FILE_READ|FILE_WRITE|FILE_CSV ,","); 
   if(handle>0){
      FileSeek(handle, 0, SEEK_END);
      FileWrite(handle,"time,open,close,high,low,volume,ask,bid,rsi,n");
      FileClose(handle );    
   } 
}


// Êý¾ÝÈÕÖ¾
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
 *                    ä¸»é¢˜ç¨‹åºç»“æž„                                                 *
 ***************************************************/

// ´¦ÀíÃ¿¸ùÏßµÄµÚ1Ö¡
int onFirstTick(){
   static int n=0;
  // ¼ÇÂ¼½»Ò×¹Ø¼üÊý¾Ý
  double rsi = iRSI(Symbol(),Period(),7,PRICE_CLOSE,0);  
  datalog( 
    Open[1]+ "," +Close[1] + "," + High[1] + "," + Low[1]+ "," + Volume[1] + "," + Ask + "," + Bid + "," + rsi + "," + n
  );
  // Time,Open,Close,High,Low,Volume,Ask,Bid
  n++;
}

// ´¦ÀíÃ¿Ò»Ö¡
int onEveryTick(){

}

// ¼ì²éÊÇ·ñÊÇ°ôÏßµÄµÚ1Ö¡
bool isFirstTick(){
  static double LastVolume= -1 ;  
  if (Volume[0] > LastVolume && LastVolume != -1 ){
    LastVolume = Volume[0];    
    return(false);
  }
  LastVolume = Volume[0];  
  return(true);
}

// Ö÷³ÌÐò
int start()
{ 
  if(isFirstTick()) {
    onFirstTick();  
  }
  onEveryTick();  
}





//+------------------------------------------------------------------+