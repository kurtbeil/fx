// CUtility.cpp : Defines the entry point for the DLL application.
//

#include "stdafx.h"
#include "CUtility.h"


// Dll ��ڶ���
BOOL APIENTRY DllMain( HANDLE hModule, 
                       DWORD  ul_reason_for_call, 
                       LPVOID lpReserved
					 )
{
    switch (ul_reason_for_call)
	{
		case DLL_PROCESS_ATTACH:
		case DLL_THREAD_ATTACH:
		case DLL_THREAD_DETACH:
		case DLL_PROCESS_DETACH:
			break;
    }
    return TRUE;
}




int cnt = 0;

CUTILITY_API int __stdcall inc(int i)
{
	cnt += i;
	return cnt;
}



