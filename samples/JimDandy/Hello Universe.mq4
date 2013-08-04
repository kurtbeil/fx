//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+

#property copyright "Copyright 2013, JimDandy1958."
#property link      "http://www.youtube.com"

int MyMa;//variable on global scope for our switch example we wrote at the end.
/////////////////////////////////////////////////////////////////////////
int start()
  {
//----
double spread = MarketInfo(Symbol(),MODE_SPREAD);
double minlot = MarketInfo(Symbol(),MODE_MINLOT);
double maxlot = MarketInfo(Symbol(),MODE_MAXLOT);
double step   = MarketInfo(Symbol(),MODE_LOTSTEP);
double margin = MarketInfo(Symbol(),MODE_MARGINREQUIRED);
double leverage =NormalizeDouble((Bid/(margin/100))*1000,0);

int number = MessageBox("The spread on this pair is "+DoubleToStr(spread/10,1)+
"\nThe smallest lotsize available on this broker is "+DoubleToStr(minlot,2)+
"\nThe largest lotsize available on this broker is "+DoubleToStr(maxlot,2)+
"\nYou can increase your order's lotsize by "+DoubleToStr(step,2)+
"\nThe margin required to trade a microlot (.01) is: "+DoubleToStr(margin/100,2)+
"\nSo this server uses :"+DoubleToStr(leverage,0)+":1 leverage.",Period()+"M "+Symbol(),0x00000002|0x00000030|0x00000100);

button3(number);

Print("End of Start Function");

//----
   return(0);
  }
////////////////////////////////////////////////////////// 
void button3(int number)
{
if(number ==0)MessageBox("You pushed Abort!!!");
else button4(number);
Print("End of Button3 Function");
}
/////////////////////////////////////////////////////////
void button4(int number)
{
if(number ==1)MessageBox("You pushed Retry!!!");
else button5(number);
Print("End of Button4 Function");
}
///////////////////////////////////////////////////////////
void button5(int number)
{
if(number ==2)MessageBox("You pushed Ignore!!!");
else testswitch(number);
Print("End of Button5 Function");
}

void testswitch(int number)
{
   switch(number)
   {
   case 3:MessageBox("You pushed Abort!!!");Print("End of testswitch Function");break;
   case 7:MessageBox("You pushed Retry!!!");Print("End of testswitch Function");break;
   case 5:MessageBox("You pushed Ignore!!!");Print("End of testswitch Function");break;
   default:MessageBox("I do not know what button you pushed!");Print("End of testswitch Function");break;
   }
}

void MaAdjuster(int number)
{
   switch(number)
   {
   case 5:MyMa=960;break;
   case 15:MyMa=320;break;
   case 30:MyMa=160;break;
   case 60:MyMa=80;break;
   case 240:MyMa=20;break;
   }
}







//+------------------------------------------------------------------+