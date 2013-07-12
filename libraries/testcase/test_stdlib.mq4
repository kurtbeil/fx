//+------------------------------------------------------------------+
//|                                                        close.mq4 |
//|                      Copyright ?2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property library

#include <stdlib.mqh>

int error=0;
int assert=0;

void printAssertResul(){
   Print("≤‚ ‘–≈œ¢:"+assert+"∂œ—‘±ª÷¥––,Õ®π˝:"+(assert - error)+", ß∞‹:"+error);
}

void assertStringEqual(string unit,string s1,string s2){
   assert ++ ;
   if (s1!=s2) {
      Print(unit + " :Assert Fail,s1=\"" + s1 + "\",s2=\"" + s2+"\"");
      error ++ ;
   }
}

int test_StringReplace(){
  string unit = "test_stdlib.test_StringReplace";
  assertStringEqual(unit,StringReplace("123","2","$"),"1$3");
  assertStringEqual(unit,StringReplace("123","1","$"),"$23");
  assertStringEqual(unit,StringReplace("123","3","$"),"12$");
  assertStringEqual(unit,StringReplace("123111123","123","$"),"$111$");
  assertStringEqual(unit,StringReplace("123123123","123","$"),"$$$");
  assertStringEqual(unit,StringReplace("123123123","2",""),"131313");
  assertStringEqual(unit,StringReplace("123123123","","111"),"123123123");
  assertStringEqual(unit,StringReplace("1232312323","123","1"),"123123");
  //assertStringEqual(unit,StringReplace("1232312323","123","111"),"≤‚ ‘¥ÌŒÛ");
}

int test_stdlib()
{
   test_StringReplace();
}






//+------------------------------------------------------------------+