#property library

#include <common.mqh>

#import "CppUtility.dll"
int c_inc(int i);
int c_read(int i);


int CppTest(int i){
	c_inc(i);
	GetExecuteId();
}


