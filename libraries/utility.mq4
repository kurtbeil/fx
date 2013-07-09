


void log(string filename,string msg){
  //if (LOGGING==1){
    int handle;
    string timestamp = TimeToStr(TimeCurrent());
    handle=FileOpen(filename,FILE_READ|FILE_WRITE," ");  
    if(handle>0)
    {
       FileSeek(handle, 0, SEEK_END);
       FileWrite(handle,timestamp,":", msg);     
       FileClose(handle );
    }
  //}
}