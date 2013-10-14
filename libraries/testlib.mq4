#property library


int error=0;
int assert=0;

void printAssertResul() {
	Print("Test:"+assert+"assert process,pass:"+(assert - error)+",fail:"+error);
}

void assertStringEqual(string unit,string s1,string s2) {
	assert ++ ;
	if (s1!=s2) {
		Print(unit + " :Assert Fail,s1=\"" + s1 + "\",s2=\"" + s2+"\"");
		error ++ ;
	}
}

void assertDoubleEqual(string unit,double d1,double d2) {
	assert ++ ;
	if (d1!=d2) {
		Print(unit + " :Assert Fail,d1=\"" + d1 + "\",d2=\"" + d2+"\"");
		error ++ ;
	}
}

void assertIntEqual(string unit,int d1,int d2) {
	assert ++ ;
	if (d1!=d2) {
		Print(unit + " :Assert Fail,d1=\"" + d1 + "\",d2=\"" + d2+"\"");
		error ++ ;
	}
}