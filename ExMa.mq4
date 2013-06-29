/*
    
*/

#define MAGICMA  101
#define LOGGING  1

int length = 5;
int maPeriod = 12;
int maxPosition = 1;
double stoploss = 0.0045;

int slipPoint = 5;


/***************************************************
 *               �����߼���Ҫ������׼��            *
 ***************************************************/

double HighBuffer[]; 
double LowBuffer[]; 

bool IsHigh(int i){
  int j,idx;
  for(j=1;j<=length;j++){
    idx = i + j;    
    if(idx>=Bars) return(false);    
    if(High[idx]>=High[i]) return (false);
  }
  for(j=1;j<=length;j++){
    idx = i - j;    
    if(idx<0) return(false);
    if(High[idx]>High[i]) return (false);
  }  
  return (true);
}

bool IsLow(int i){
  int j,idx;
  for(j=1;j<=length;j++){
    idx = i + j;    
    if(idx>=Bars) return(false);
    if(Low[idx]<=Low[i])return (false);    
  }
  for(j=1;j<=length;j++){
    idx = i - j;
    if(idx<0) return(false);
    if(Low[idx]<Low[i]) return (false);
  }  
  return (true);
}

void getExPoint(){
  int i,dt;
  int bars,maxBars = 300;
  if (Bars<maxBars) bars= Bars;
  else bars=maxBars;
  ArrayResize(HighBuffer,bars);
  ArrayResize(LowBuffer,bars);
  for(i=bars-1;i>=0;i--){ 
    if(IsHigh(i)) HighBuffer[i]=High[i]; else  HighBuffer[i] = EMPTY;
    if(IsLow(i)) LowBuffer[i]=Low[i]; else LowBuffer[i] = EMPTY;
  }    
  return(0);
}

int getHighPointIndex(int n){
  int i=0,j=-1;
  for(i=0;i<Bars;i++){
    if(HighBuffer[i]!=EMPTY) j++;
    if (j==n) return(i);
  }
  return(-1);
}

int getLowPointIndex(int n){
  int i=0,j=-1;
  for(i=0;i<Bars;i++){
    if(LowBuffer[i]!=EMPTY) j++;
    if (j==n) return(i);
  }
  return(-1);
}

double getHighPointValue(int n){
  int i = getHighPointIndex(n);
  if (i == -1) return(EMPTY);
  return(HighBuffer[i]);
}

double getLowPointValue(int n){
  int i = getLowPointIndex(n);
  if (i == -1) return(EMPTY);
  return(LowBuffer[i]);
}

/***************************************************
 *            �ļ���־�͵�����غ���               *
 ***************************************************/

// ������־
void log(string msg){
  if (LOGGING==1){
    int handle;
    string timestamp = TimeToStr(TimeCurrent());
    handle=FileOpen(Symbol()+"["+MAGICMA+"][TRADING].log",FILE_READ|FILE_WRITE," ");  
    if(handle>0)
    {
       FileSeek(handle, 0, SEEK_END);
       FileWrite(handle,timestamp,":", msg);     
       FileClose(handle );
    }
  }
}

// ������־
void datalog(string msg){
  if (LOGGING==1){
    int handle;
    string timestamp = TimeToStr(TimeCurrent());
    handle=FileOpen(Symbol()+"["+MAGICMA+"][DATA].csv",FILE_READ|FILE_WRITE|FILE_CSV ,",");  
    if(handle>0)
    {
      FileSeek(handle, 0, SEEK_END);
      FileWrite(handle,timestamp, msg);     
      FileClose(handle );
    }
  }
}

/***************************************************
 *                    ���׳������߼�               *
 ***************************************************/
void doTrading(){
  log("doTrading():��ʼ");
  getExPoint();
  // ����  
  double ma1=iMA(Symbol(),0,maPeriod,0,MODE_EMA,PRICE_CLOSE,1);
  double ma2=iMA(Symbol(),0,maPeriod,0,MODE_EMA,PRICE_CLOSE,2);
  double high0 = getHighPointValue(0);
  double low0 = getLowPointValue(0);
  
  double dayMaFast=iMA(Symbol(),PERIOD_M15,5,0,MODE_EMA,PRICE_CLOSE,1);
  double dayMaSlow=iMA(Symbol(),PERIOD_M15,22,0,MODE_EMA,PRICE_CLOSE,1);
  
    
  if( ma2<=high0 && ma1>high0 ){
    // ����      
    if (existPositionByCmd(OP_SELL)) closePosition(OP_SELL);
    if(positionCountByCmd(OP_BUY)<maxPosition)
      if(dayMaFast>dayMaSlow){
        //createPosition(OP_BUY);    
      }
  }
  
  if( ma2>=low0 && ma1<low0 ){
    // ����      
    if (existPositionByCmd(OP_BUY)) closePosition(OP_BUY);
      if(positionCountByCmd(OP_SELL)<maxPosition) 
        if(dayMaSlow>dayMaFast){
          //createPosition(OP_SELL);    
        }        
  }
  
  // ��¼���׹ؼ�����
  datalog( 
    Open[1]+ "," +Close[1] + "," + High[1] + "," + Low[1]+ "," + Volume[1] + "," + Ask + "," + Bid
  );
  // Time,Open,Close,High,Low,Volume,Ask,Bid
  log("doTrading():����");
}

/***************************************************
 *                    ͷ���С����                 *
 ***************************************************/

double getLots(){
  log("getLots():��ʼ");
  double lots;     
  lots = AccountBalance()/AccountLeverage()/150;
  if(lots>1) lots=MathSqrt(lots);  
  lots = MathRound(lots*10)/10;  
  if(lots<0.1) lots=0.1;  
  log("getLots():����(lots=" + lots + ")");
  return (lots);    
}

double getSlipPoints(){
  return (slipPoint*0.0001/Point);
}

/***************************************************
 *                    ֹ������                     *
 ***************************************************/
 
void setupStoploss(){
  log("setupStoploss():��ʼ");
  double sl;
  for(int i=0;i<OrdersTotal();i++){
    if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
    if(OrderSymbol()==Symbol() && OrderMagicNumber()!=MAGICMA) continue;
    
    if( OrderType()== OP_BUY ) {    
      sl=Low[1]-stoploss;    
      if(sl>OrderStopLoss()||OrderStopLoss()==0)
        OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0,Blue);
    }    
    if( OrderType()== OP_SELL ) {    
      sl=High[1]+stoploss;    
      if(sl<OrderStopLoss()||OrderStopLoss()==0)
        OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0,Red);
    }   
  }
  log("setupStoploss():����");
}
/***************************************************
 *                    �ر�ͷ��                     *
 ***************************************************/


// ��ticket id�ر�ͷ��
bool closePositionByTicket(int ticket){
  log("closePositionByTicket(" + ticket + "):��ʼ");
  bool ret=true;  
  double ask,bid;
  if (OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES)==false) {
    log("closePositionByTicket:Ҫ�رյ�ͷ�粢������");
    return;
  }  
  if(OrderType()==OP_BUY){
    bid = Bid;
    ret = OrderClose(OrderTicket(),OrderLots(),bid,getSlipPoints(),Blue);   
    log("call:OrderClose(" + OrderTicket()+ ","+OrderLots()+"," + bid + "):(" + ret + ")"); 
  }
  if(OrderType()==OP_SELL){
    ask = Ask;  
    ret = OrderClose(OrderTicket(),OrderLots(),ask,getSlipPoints(),Red);
    log("call:OrderClose(" + OrderTicket()+ ","+OrderLots()+"," + ask + "):(" + ret + ")"); 
  }   
  log("closePositionByTicket(" + ticket + "):����(" + ret + ")");
  return(ret);
}

// �ر�һ�����������ͷ��
void closePosition(int cmd){
  log("closePosition(" + cmd + "):��ʼ");
  bool ret;
  int ticket;
  for(int i=0;i<OrdersTotal();i++){    
    if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
    if(OrderSymbol()==Symbol() && OrderMagicNumber()!=MAGICMA) continue;        
    if (cmd== OrderType()){
      ticket = OrderTicket();
      ret = closePositionByTicket(ticket);    
      if(!ret){
        addToClose(ticket);
      }
    }     
  }
  log("closePosition(" + cmd + "):����");
}

// ������رն���
// ����ر�ͷ��ʱ�������������Ҫһֱ����ֱ���ɹ�����,�������ÿ1֡������1��
int toBeClosedCnt=0;
int toBeClosed[];

// ��һ��ticket������������
void addToClose(int ticket){
  log("addToClose(" + ticket + "):��ʼ");
  ArrayResize(toBeClosed,toBeClosedCnt);
  // ���ticket�Ƿ��Ѿ��ڶ�����������ھͲ��������
  for(int i=0; i<toBeClosedCnt; i++){
    if(toBeClosed[i] == ticket ){
      return;
    }
  }
  toBeClosedCnt=toBeClosedCnt+1;
  ArrayResize(toBeClosed,toBeClosedCnt);
  toBeClosed[toBeClosedCnt-1] = ticket;
  log("addToClose(" + ticket + "):����");
}


void markToCloseRemoved(int ticket){
  log("markToCloseRemoved(" + ticket + "):��ʼ");
  ArrayResize(toBeClosed,toBeClosedCnt);
  if ( ticket==-1 ) {
    log("error:ticket=-1");
  }else{
    for(int i=0; i<toBeClosedCnt; i++){
      if(toBeClosed[i] == ticket ){
        toBeClosed[i] = -1;
      }
    }
  }
  log("markToCloseRemoved(" + ticket + "):����");
}


// �����������е�����ͷ����йر�
void closeToBeClosed(){  
  bool ret;
  int ticket;
  if (toBeClosedCnt != 0) {
    log("closeToBeClosed()��ʼ");
    int i;
    // ���Թر����д��رյ�ͷ��
    for( i=0; i<toBeClosedCnt; i++) {
      ticket = toBeClosed[i];
      if ( ticket == -1 ) continue;
      if(existPositionByTicket(ticket)){
         ret = closePositionByTicket(ticket);
         if(ret) markToCloseRemoved(ticket);
      }else{
         markToCloseRemoved(toBeClosed[i]);
      }
    }
    // ���µ�������Ĵ�С,ȥ���Ѿ�����־Ϊɾ���Ŀո�����
    ArrayResize(toBeClosed,toBeClosedCnt);
    for( i=0; i<toBeClosedCnt; i++){
      if(toBeClosed[i] == -1 ){
         //log("---if toBeClosed["+i+"]==-1--");
         for(int j=i; j<toBeClosedCnt-1; j++){
           //log("---toBeClosed["+j+"]=toBeClosed["+(j+1)+"]--");
           toBeClosed[j] = toBeClosed[j+1];
         }
         toBeClosedCnt = toBeClosedCnt - 1;
         ArrayResize(toBeClosed,toBeClosedCnt);
         i = i - 1;
         log("i="+i);
      }
    }
    //printToBeClose();
    log("closeToBeClosed()����");
  }  
}

/*
void printToBeClose(){
  log("printToBeClose():��ʼ");
  for(int i=0; i<toBeClosedCnt; i++) {
    //Print("toBeClosed[i]=",toBeClosed[i]);
    log("toBeClosed[" + i + "]=" + toBeClosed[i]);
  }
  log("printToBeClose():����");
}
*/

/***************************************************
 *                    ͷ���������                 *
 ***************************************************/
// ��������ͷ���Ƿ����
bool existPositionByCmd(int cmd){
  log("existPositionByCmd(" + cmd + "):��ʼ");
  for(int i=0;i<OrdersTotal();i++){
    if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
    if(OrderSymbol()==Symbol() && OrderMagicNumber()!=MAGICMA) continue;    
    if (cmd==OP_BUY){
      if (OrderType()==OP_BUYSTOP || OrderType()==OP_BUYLIMIT || OrderType() == OP_BUY) {
        log("existPositionByCmd():����(true)"); 
        return(true);        
      }
    }
    if (cmd==OP_SELL){
      if (OrderType() == OP_SELLSTOP || OrderType()==OP_SELLLIMIT || OrderType() == OP_SELL){
        log("existPositionByCmd():����(true)"); 
        return(true); 
      }
    }
  }
  log("existPositionByCmd():����(false)"); 
  return(false);
}

// ��������ͷ�������
int positionCountByCmd(int cmd){
  log("positionCountByCmd(" + cmd + "):��ʼ");
  int cnt=0;
  for(int i=0;i<OrdersTotal();i++){
    if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
    if(OrderSymbol()==Symbol() && OrderMagicNumber()!=MAGICMA) continue;    
    if (OrderType()==cmd) cnt++;
  }
  log("positionCountByCmd():����(" + cnt + ")");
  return(cnt);
}

// ��ticket���ͷ���Ƿ����
bool existPositionByTicket(int ticket){
  log("existPositionByTicket(" + ticket + "):��ʼ");
  for(int i=0;i<OrdersTotal();i++){
    if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
    if(OrderSymbol()==Symbol() && OrderMagicNumber()!=MAGICMA) continue;    
    if(OrderTicket() == ticket) {
      return(true);
      log("existPositionByTicket(" + ticket + "):����(true)");
    }
  }  
  log("existPositionByTicket(" + ticket + "):����(false)");
  return(false);
}

/***************************************************
 *                    ͷ�紴��                     *
 ***************************************************/
void createPosition(int cmd){
  log("createPosition(" + cmd + "):��ʼ");
  int ticket=0;  
  double ask,bid;
  if (cmd==OP_BUY){    
    ask = Ask;
    ticket = OrderSend(Symbol(),OP_BUY,getLots(),ask,getSlipPoints(),ask-stoploss,0,"",MAGICMA,0,Blue);    
    log("call:OrderSend(" + Symbol()+ ","+OP_BUY+","+getLots()+","+ask+","+getSlipPoints()+","+(ask-stoploss)+",0,\"\","+MAGICMA+"):(" + ticket + ")");
  }
  if (cmd==OP_SELL){
    bid = Bid;
    ticket = OrderSend(Symbol(),OP_SELL,getLots(),bid,getSlipPoints(),bid+stoploss,0,"",MAGICMA,0,Red); 
    log("call:OrderSend(" + Symbol()+ ","+OP_SELL+","+getLots()+","+bid+","+getSlipPoints()+","+(bid+stoploss)+",0,\"\","+MAGICMA+"):(" + ticket + ")");
  }
  if(ticket<0) log("OrderSend����:"+GetLastError());
  log("createPosition():����");
}  
/***************************************************
 *                    �������ṹ                 *
 ***************************************************/

// ����ÿ���ߵĵ�1֡
int onFirstTick(){
  doTrading();
  setupStoploss();    
}

// ����ÿһ֡
int onEveryTick(){
  closeToBeClosed();
}

// ����Ƿ��ǰ��ߵĵ�1֡
bool isFirstTick(){
  static double LastVolume= -1 ;  
  if (Volume[0] >= LastVolume && LastVolume != -1 ){
    LastVolume = Volume[0];    
    return(false);
  }
  LastVolume = Volume[0];  
  return(true);
}

// ������
int start()
{ 
  if(isFirstTick()) {
    onFirstTick();  
  }
  onEveryTick();  
}





//+------------------------------------------------------------------+