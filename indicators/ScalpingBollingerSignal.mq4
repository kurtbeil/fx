#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red


double Buffer1[];
double Buffer2[];

int init() {
	IndicatorBuffers(2);
	
	SetIndexStyle(0,DRAW_ARROW,0,2);
	SetIndexArrow(0,236);
	SetIndexBuffer(0,Buffer1);

	SetIndexStyle(1,DRAW_ARROW,0,2);
	SetIndexArrow(1,236);
	SetIndexBuffer(1,Buffer2);

	return(0);
}

int start() {
	int counted_bars=IndicatorCounted();
	if(counted_bars<0) return(-1);
	if(counted_bars>0) counted_bars--;
	int limit=Bars-counted_bars;
	for(int i=0; i<limit; i++) {
		int hh24 = TimeHour(Time[i]);
		if (hh24 == 23 || hh24 == 0 || hh24 ==1) {
			double bands_high  = iBands(NULL,0,20,2,0,PRICE_CLOSE,MODE_UPPER,i+1);
			double  bands_low = iBands(NULL,0,20,2,0,PRICE_CLOSE,MODE_LOWER,i+1);
			if ((bands_high-bands_low) * 10000 > 5.5) {
				if ( Low[i] < bands_low ) {
					Buffer1[i] = Low[i];
				}
				if ( High[i] > bands_high ) {
					Buffer2[i] = High[i];
				}
			}
			string ts = TimeToStr(Time[i]);
		}
	}
	return(0);
}


