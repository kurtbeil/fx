#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red



int rsiPeriod = 7;
int maPeriod = 7;

double Rsi[];
double RsiMa[];


int init() {
	IndicatorBuffers(2);
	
	SetIndexStyle(0,DRAW_LINE);
	SetIndexBuffer(0,Rsi);
	
	SetIndexStyle(1,DRAW_LINE);
	SetIndexBuffer(1,RsiMa);

	return(0);
}

int start() {
	int counted_bars=IndicatorCounted();
	if(counted_bars<0) return(-1);
	if(counted_bars>0) counted_bars--;
	int limit=Bars-counted_bars;
	int i;
	for(i=0; i<limit; i++) {
		Rsi[i] = iRSI(Symbol(),Period(),14,PRICE_CLOSE,i);
	}
	for(i=0; i<limit; i++) {
		RsiMa[i] = iMAOnArray(Rsi,0,maPeriod,0,MODE_SMA,i);
	}
	return(0);
}


