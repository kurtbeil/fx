//+------------------------------------------------------------------+
//|                                                       stdlib.mqh |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#import "stdlib.ex4"

string ErrorDescription(int error_code);
int    RGB(int red_value,int green_value,int blue_value);
bool   CompareDoubles(double number1,double number2);
string DoubleToStrMorePrecision(double number,int precision);
string IntegerToHexString(int integer_number);
string StringReplace(string text,string s1,string s2);


double MinutesBetween(datetime datetime1,datetime datetime2);
double HoursBetween(datetime datetime1,datetime datetime2);
double DaysBetween(datetime datetime1,datetime datetime2);