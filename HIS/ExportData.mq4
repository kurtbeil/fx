

/***************************************************
 *            ����������ʱ�����ڵ�����             *
 ***************************************************/

string exportfile;

int init(){
  exportfile = "TB_UBE_"+Symbol()+"_M"+Period()+".csv";  
  int handle;
  handle=FileOpen(exportfile,FILE_READ|FILE_WRITE|FILE_CSV ,","); 
  if(handle>0){
    FileSeek(handle, 0, SEEK_END);
    FileWrite(handle,"Time,Open,Close,High,Low,Volume,Ask,Bid");
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
  // ��¼���׹ؼ�����
  datalog( 
    Open[1]+ "," +Close[1] + "," + High[1] + "," + Low[1]+ "," + Volume[1] + "," + Ask + "," + Bid
  );
  // Time,Open,Close,High,Low,Volume,Ask,Bid
}

// ����ÿһ֡
int onEveryTick(){

}

// ����Ƿ��ǰ��ߵĵ�1֡
bool isFirstTick(){
  static double LastVolume= -1 ;  
  if (Volume[0] >= LastVolume && LastVolume != -1 ){
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