
#include <stdlib.mqh>

/***************************************************
<<<<<<< HEAD
 *            导出所经历时间周期的数据                                      *
=======
 *           导出所经历时间周期的数据                                       *
>>>>>>> cab55242c5c2885bc4ad7cf632d468fbb5c30978
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


// ˽ߝɕ־
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
<<<<<<< HEAD
 *                    ׷͢ԌѲޡٹ                 *
=======
 *                    主题程序结构                                                 *
>>>>>>> cab55242c5c2885bc4ad7cf632d468fbb5c30978
 ***************************************************/

// ԦmÿٹПք֚1֡
int onFirstTick(){
   static int n=0;
  // ݇¼ݻӗژݼ˽ߝ
  double rsi = iRSI(Symbol(),Period(),7,PRICE_CLOSE,0);  
  datalog( 
    Open[1]+ "," +Close[1] + "," + High[1] + "," + Low[1]+ "," + Volume[1] + "," + Ask + "," + Bid + "," + rsi + "," + n
  );
  // Time,Open,Close,High,Low,Volume,Ask,Bid
  n++;
}

// Ԧmÿһ֡
int onEveryTick(){

}

// ݬөˇرˇѴПք֚1֡
bool isFirstTick(){
  static double LastVolume= -1 ;  
  if (Volume[0] > LastVolume && LastVolume != -1 ){
    LastVolume = Volume[0];    
    return(false);
  }
  LastVolume = Volume[0];  
  return(true);
}

// ׷ԌѲ
int start()
{ 
  if(isFirstTick()) {
    onFirstTick();  
  }
  onEveryTick();  
}





//+------------------------------------------------------------------+