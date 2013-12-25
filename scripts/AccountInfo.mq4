

#property show_confirm


int start() {
	Print("------------------------------------------");
	Print("Account Number = ",AccountNumber());
	Print("Account Company = ",AccountCompany());	
	Print("Account Server = ",AccountServer());
	Print("------------------------------------------");
	Print("Account Name = ",AccountName());
	Print("Account Balance = ", AccountBalance());
	Print("Account Credit = ", AccountCredit());
	Print("StopOut Level = ", AccountStopoutLevel());
	Print("Account Currency = ", AccountCurrency());
	Print("Account equity = ",AccountEquity());
	Print("Terminal Name = ",TerminalName());
	Print("Terminal Path = ",TerminalPath());	
	Print("------------------------------------------");
	//Print("Account Company = ",AccountCompany());	
	//Print("Account Server = ",AccountServer());
	
	
}