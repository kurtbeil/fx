//+------------------------------------------------------------------+
//|                                               Moving Average.mq4 |
//|                      Copyright © 2005, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+


int init(){

  return (-1);  
}

void start()
{
	Print("hellol ");
    ObjectCreate("text_object", OBJ_TEXT, 0, Time[0], Ask);
}  


