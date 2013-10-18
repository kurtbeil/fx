
-- 建表脚本
create table TB_ST_LOG (
  LOG_ID NUMBER,
  LOG_DATE DATE,
  LOG_MSG VARCHAR2(4000)
);
create table TB_ST_PROFIT_SLICE (
  TP_LEVEL NUMBER,
  SL_LEVEL NUMBER,
  LEN NUMBER,
  TYPE VARCHAR2(10),
  TIME DATE,
  N NUMBER,
  N1 NUMBER,
  TP NUMBER,
  SL NUMBER,
  CL NUMBER,
  CLOSE_BY VARCHAR2(100)
);
create table TB_ST_PROFIT_SLICE_BAK (
  TP_LEVEL NUMBER,
  SL_LEVEL NUMBER,
  LEN NUMBER,
  TYPE VARCHAR2(10),
  TIME DATE,
  N NUMBER,
  N1 NUMBER,
  TP NUMBER,
  SL NUMBER,
  CL NUMBER,
  CLOSE_BY VARCHAR2(100)
);
create table TB_ST_PROFIT_SLICE_LONG (
  N NUMBER,
  N1 NUMBER,
  TP NUMBER,
  SL NUMBER,
  CL NUMBER,
  CLOSE_BY VARCHAR2(100)
);
create table TB_ST_PROFIT_SLICE_SHORT (
  N NUMBER,
  N1 NUMBER,
  TP NUMBER,
  SL NUMBER,
  CL NUMBER,
  CLOSE_BY VARCHAR2(100)
);
create table TB_ST_RSI_TRADING (
  TIME DATE,
  N NUMBER,
  TYPE VARCHAR2(10),
  RSI NUMBER,
  N1 NUMBER,
  CLOSE_BY VARCHAR2(100)
);
create table TB_ST_RSI_TRADING_BAK (
  TIME DATE,
  N NUMBER,
  TYPE VARCHAR2(10),
  RSI NUMBER,
  N1 NUMBER,
  CLOSE_BY VARCHAR2(100)
);
create table TB_ST_RSI_TRADING_CLOSE (
  TIME DATE,
  N NUMBER,
  TYPE VARCHAR2(10),
  RSI NUMBER,
  CLOSE_BY VARCHAR2(100)
);
create table TB_ST_RSI_TRADING_DETAIL (
  TP_LEVEL NUMBER,
  SL_LEVEL NUMBER,
  LEN NUMBER,
  TYPE VARCHAR2(10),
  TIME DATE,
  N NUMBER,
  N1 NUMBER,
  TP NUMBER,
  SL NUMBER,
  CL NUMBER,
  PROFIT NUMBER,
  HH24 VARCHAR2(2),
  RSI NUMBER,
  CLOSE_BY VARCHAR2(100),
  G NUMBER,
  GCNT NUMBER,
  M NUMBER,
  TOTAL_PROFIT NUMBER,
  PREDICT_TOTAL_PROFIT NUMBER,
  DEVIATION NUMBER,
  K NUMBER
);
create table TB_ST_RSI_TRADING_DETAIL_0 (
  TP_LEVEL NUMBER,
  SL_LEVEL NUMBER,
  LEN NUMBER,
  TYPE VARCHAR2(10),
  TIME DATE,
  N NUMBER,
  N1 NUMBER,
  TP NUMBER,
  SL NUMBER,
  CL NUMBER,
  PROFIT NUMBER,
  HH24 VARCHAR2(2),
  RSI NUMBER,
  CLOSE_BY VARCHAR2(100)
);
create table TB_ST_RSI_TRADING_DETAIL_1 (
  TP_LEVEL NUMBER,
  SL_LEVEL NUMBER,
  LEN NUMBER,
  TYPE VARCHAR2(10),
  TIME DATE,
  N NUMBER,
  N1 NUMBER,
  TP NUMBER,
  SL NUMBER,
  CL NUMBER,
  PROFIT NUMBER,
  HH24 VARCHAR2(2),
  RSI NUMBER,
  CLOSE_BY VARCHAR2(100),
  G NUMBER,
  GCNT NUMBER,
  M NUMBER,
  TOTAL_PROFIT NUMBER
);
create table TB_ST_RSI_TRADING_DETAIL_FIT (
  G NUMBER,
  CNT NUMBER,
  B1 NUMBER,
  B0 NUMBER
);
create table TB_ST_RSI_TRADING_OPEN (
  TIME DATE,
  N NUMBER,
  TYPE VARCHAR2(10),
  RSI NUMBER
);
create table TB_ST_RSI_TRADING_STAT (
  G NUMBER,
  TP_LEVEL NUMBER,
  SL_LEVEL NUMBER,
  LEN NUMBER,
  TYPE VARCHAR2(10),
  HH24 VARCHAR2(2),
  RSI NUMBER,
  CNT NUMBER,
  TP NUMBER,
  SL NUMBER,
  CL NUMBER,
  PROFIT NUMBER,
  AVG_PROFIT NUMBER,
  TP_PROFIT NUMBER,
  SL_PROFIT NUMBER,
  CL_PROFIT NUMBER,
  TP_PCT NUMBER,
  SL_PCT NUMBER,
  CL_PCT NUMBER,
  DEVIATION NUMBER,
  AVG_DEVIATION NUMBER,
  AVG_DEVIATION_SQUARE NUMBER,
  AVG_DEVIATE_RATE NUMBER,
  K NUMBER
);
create table TB_ST_TRADING_DATA (
  TIME DATE,
  OPEN NUMBER,
  CLOSE NUMBER,
  HIGH NUMBER,
  LOW NUMBER,
  VOLUME NUMBER,
  ASK NUMBER,
  BID NUMBER,
  RSI NUMBER,
  RSI1 NUMBER,
  N NUMBER
);
create table TB_ST_TRADING_DATA_MIX (
  TIME DATE,
  N NUMBER,
  ASK NUMBER,
  BID NUMBER,
  TIME1 DATE,
  N1 NUMBER,
  ASK1 NUMBER,
  BID1 NUMBER
);

-- 创建序列  
create sequence SEQ_LOG
minvalue 1
maxvalue 999999999999999999999999999
start with 1
increment by 1
cache 20;
 
-- 创建索引
create index TB_ST_PROFIT_SLICE_LONG_i1 on TB_ST_PROFIT_SLICE_LONG (N);
create index TB_ST_PROFIT_SLICE_SHORT_I1 on TB_ST_PROFIT_SLICE_SHORT (N);
create index TB_ST_TRADING_DATA_I1 on TB_ST_TRADING_DATA (N);
create index TB_ST_RSI_TRADING_DETAIL_I1 on TB_ST_RSI_TRADING_DETAIL (G);
create index tb_st_rsi_trading_detail_1_i1 on tb_st_rsi_trading_detail_1(g);
  
-- 修改表nolgging属性
alter table tb_st_trading_data nologging;
alter table tb_st_trading_data_mix nologging;
alter table tb_st_profit_slice_long nologging;
alter table tb_st_profit_slice_short nologging;
alter table tb_st_profit_slice nologging;
alter table tb_st_rsi_trading nologging;
alter table tb_st_rsi_trading_detail nologging;
alter table tb_st_rsi_trading_detail_fit nologging;
alter table tb_st_rsi_trading_detail_0 nologging;
alter table tb_st_rsi_trading_detail_1 nologging;
alter table tb_st_rsi_trading_stat nologging;  
alter table tb_st_profit_slice_bak nologging;
alter table tb_st_rsi_trading_bak nologging;
  
-- 修改索引nolgging属性
alter index tb_st_profit_slice_short_i1 nologging;
alter index tb_st_profit_slice_long_i1 nologging;
alter index tb_st_rsi_trading_detail_i1 nologging;
alter index tb_st_trading_data_i1 nologging;
alter index tb_st_rsi_trading_detail_1_i1 nologging;