create or replace package pkg_scalping_tester is

  -- ���̶���
  procedure load_trading_data(i_table_name varchar2, i_len number);
  procedure get_profit_slice(i_tp_level number, i_sl_level number, i_len number);
  procedure get_rsi_trading(i_long_rsi number, i_short_rsi number);
  procedure get_rsi_trading_stat;
  procedure get_data(i_table_name varchar2);
  procedure test01;
  procedure test02;
  procedure test03;

-- ������ص����ݽṹ
/*

with sql1 as
 (select table_name,
         column_name,
         data_type,
         data_length,
         column_id,
         count(*) over(partition by table_name) colcnt
    from user_tab_cols
   where table_name like 'TB_ST%'
     and table_name not like '%20%'
     and table_name not like '%35%'
     and table_name not like '%40%')
select table_name, column_id, --
'  ' || column_name || ' ' || data_type || --
case when data_type in ('VARCHAR2', 'VARCHAR', 'CHAR') then '(' || to_char(data_length) || ')' else '' end || --
case when column_id = colcnt then '' else ',' end scripts
  from sql1 a
union
select table_name, 0 column_id, 'create table ' || table_name || ' ('
  from sql1
 where column_id = 1
union
select table_name, colcnt + 1 column_id, ');'
  from sql1
 where column_id = 1;

*/

/* 
-- ��������  
create sequence SEQ_LOG
minvalue 1
maxvalue 999999999999999999999999999
start with 1
increment by 1
cache 20;
 
-- ��������
create index TB_ST_PROFIT_SLICE_LONG_i1 on TB_ST_PROFIT_SLICE_LONG (N);
create index TB_ST_PROFIT_SLICE_SHORT_I1 on TB_ST_PROFIT_SLICE_SHORT (N);
create index TB_ST_TRADING_DATA_I1 on TB_ST_TRADING_DATA (N);
create index TB_ST_RSI_TRADING_DETAIL_I1 on TB_ST_RSI_TRADING_DETAIL (G);
create index tb_st_rsi_trading_detail_1_i1 on tb_st_rsi_trading_detail_1(g);
  
-- �޸ı�nolgging����
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
  
-- �޸�����nolgging����
alter index tb_st_profit_slice_short_i1 nologging;
alter index tb_st_profit_slice_long_i1 nologging;
alter index tb_st_rsi_trading_detail_i1 nologging;
alter index tb_st_trading_data_i1 nologging;
alter index tb_st_rsi_trading_detail_1_i1 nologging;
  
  */

end pkg_scalping_tester;
/
create or replace package body pkg_scalping_tester is

  /*
    �������⣺                                                            ��1��
    1. ��֧���ź�������ʹ�ý���ͷ���ź�
    2. ��������ͷ������
    -- ������������ֻҪ�޸�get_rsi_trading�����ʵ����ƿ��Խ��
    -- �������������������⣬���γ�һ���Ƚ������Ľ���ϵͳ����������  
    
    
    ���õĽ����� : type,hh24
    ������� : rsi   (��Դ�ڹ�����)
    ������� : sl,tp (��Դ�ڷ��տ���)    
    ������� : avg_profit,tp_pct,avg_deviate_rate,k������
    
    
    һЩ�м�ֵ���뷨��               
    1����һ������������ʱrsi�仯ʱ��tl-sl������Ӧ�Ķ�ά��������仯ͼ      
      ��rsi,sl,tp��ά������,��ɫ��ʾƽ�����������                       ��2��
    2������ͬ�·����ݷֱ�����������Ƭ��������Ѱ����ͬ��Ƭλ�ã�
    �Ĳ����·ݵ�ӯ�������������ƽ��ӯ��������������������             ��3��  
    ���������Կ��ǽ�����ϣ�
  */

  procedure log(i_msg varchar2) is
  begin
    insert into tb_st_log
      select seq_log.nextval, sysdate, i_msg from dual;
    commit;
  end;

  procedure clear_log is
  begin
    execute immediate 'truncate table tb_st_log';
  end;

  --  ���뽻������
  procedure load_trading_data(i_table_name varchar2, i_len number) is
    v_column_name varchar2(4000);
  begin
    log('load_trading_data(' || i_table_name || ',' || to_char(i_len) || '):��ʼ');
    -- ��ȡ���ݱ�����ͬ���ֶ�
    select wm_concat(column_name)
      into v_column_name
      from user_tab_cols a
     where table_name = 'TB_ST_TRADING_DATA'
       and exists (select 1
              from user_tab_cols b
             where table_name = upper(i_table_name)
               and b.column_name = a.column_name)
     order by column_id;
    execute immediate 'truncate table tb_st_trading_data';
    execute immediate '
    insert /*+append*/ into tb_st_trading_data(' ||
                      v_column_name || ')
      select ' || v_column_name || ' from ' || i_table_name;
    commit;
  
    -- ��������֮����ض��������ڵ����ݽ��й���
    execute immediate 'truncate table tb_st_trading_data_mix';
    insert /*+append*/
    into tb_st_trading_data_mix
      select a.time, a.n, a.ask, a.bid, b.time time1, b.n n1, b.ask ask1, b.bid bid1
        from tb_st_trading_data a, tb_st_trading_data b
       where a.n < b.n
         and b.n <= a.n + i_len;
    commit;
    log('load_trading_data:����');
  end;

  -- ����ӯ����Ƭ
  procedure get_profit_slice(i_tp_level number, i_sl_level number, i_len number) is
  begin
    log('get_profit_slice(' || to_char(i_tp_level) || ',' || to_char(i_sl_level) || ',' ||
        to_char(i_len) || '):��ʼ');
    -- �������ཻ�׵�ӯ����Ƭ
    execute immediate 'truncate table tb_st_profit_slice_long';
    insert /*+append*/
    into tb_st_profit_slice_long
      select n, min(n1) n1, 1 tp, 0 sl, 0 cl, 'take profit' close_by
        from tb_st_trading_data_mix
       where (bid1 - ask) * 10000 > i_tp_level
       group by n
      union
      select n, min(n1) n1, 0 tp, 1 sl, 0 cl, 'stop loss' close_by
        from tb_st_trading_data_mix
       where (bid1 - ask) * 10000 < -i_sl_level
       group by n
      union
      select n, max(n1) n1, 0 tp, 0 sl, 1 cl, 'trading length' close_by
        from tb_st_trading_data_mix
      --where n1 - n <= i_len
       where (time1 - time) * 1440 <= i_len
       group by n;
    commit;
    delete /*+rule*/
    from tb_st_profit_slice_long a
     where a.n1 <> (select min(b.n1) from tb_st_profit_slice_long b where b.n = a.n);
    delete /*+rule*/
    from tb_st_profit_slice_long a
     where a.cl <> (select min(b.cl) from tb_st_profit_slice_long b where b.n = a.n);
    commit;
  
    -- �������ս��׵�ӯ����Ƭ
    execute immediate 'truncate table tb_st_profit_slice_short';
    insert /*+append*/
    into tb_st_profit_slice_short
      select n, min(n1) n1, 1 tp, 0 sl, 0 cl, 'take profit' close_by
        from tb_st_trading_data_mix
       where (bid - ask1) * 10000 > i_tp_level
       group by n
      union
      select n, min(n1) n1, 0 tp, 1 sl, 0 cl, 'stop loss' close_by
        from tb_st_trading_data_mix
       where (bid - ask1) * 10000 < -i_sl_level
       group by n
      union
      select n, max(n1) n1, 0 tp, 0 sl, 1 cl, 'trading length' close_by
        from tb_st_trading_data_mix
      --where n1 - n <= i_len
       where (time1 - time) * 1440 <= i_len
       group by n;
    commit;
    delete /*+rule*/
    from tb_st_profit_slice_short a
     where a.n1 <> (select min(b.n1) from tb_st_profit_slice_short b where b.n = a.n);
    delete /*+rule*/
    from tb_st_profit_slice_short a
     where a.cl <> (select min(b.cl) from tb_st_profit_slice_short b where b.n = a.n);
    commit;
  
    -- �ϲ���������
    execute immediate 'truncate table tb_st_profit_slice';
    insert /*+append*/
    into tb_st_profit_slice
      select i_tp_level,
             i_sl_level,
             i_len,
             'long' type,
             b.time,
             a.n,
             a.n1,
             a.tp,
             a.sl,
             a.cl,
             --(c.bid - b.ask) * 10000 profit
             a.close_by
        from tb_st_profit_slice_long a, tb_st_trading_data b, tb_st_trading_data c
       where a.n = b.n(+)
         and a.n1 = c.n(+);
    commit;
    insert /*+append*/
    into tb_st_profit_slice
      select i_tp_level,
             i_sl_level,
             i_len,
             'short' type,
             b.time,
             a.n,
             a.n1,
             a.tp,
             a.sl,
             a.cl,
             --(b.bid - c.ask) * 10000 profit
             a.close_by
        from tb_st_profit_slice_short a, tb_st_trading_data b, tb_st_trading_data c
       where a.n = b.n(+)
         and a.n1 = c.n(+);
    commit;
  
    log('get_profit_slice:����');
  end;

  -- RSI���׼�¼������
  procedure get_rsi_trading(i_long_rsi number, i_short_rsi number) is
  begin
    log('get_rsi_trading(' || to_char(i_long_rsi) || ',' || to_char(i_short_rsi) ||
        '):��ʼ');
    -- RSI��ͷ�����
    execute immediate 'truncate table tb_st_rsi_trading_open';
    insert /*+append*/
    into tb_st_rsi_trading_open
      select a.time, a.n, 'long' type, i_long_rsi
        from tb_st_trading_data a
       where a.rsi1 <= i_long_rsi
         and a.rsi > i_long_rsi
      union all
      select a.time, a.n, 'short' type, i_short_rsi
        from tb_st_trading_data a
       where a.rsi1 >= i_short_rsi
         and a.rsi < i_short_rsi;
    commit;
  
    -- ���������ɹرս��׵�
    execute immediate 'truncate table tb_st_rsi_trading_close';
    -- ����1:RSI�ر�ͷ�����
    -- �������⣺
    -- 1������Ĭ���˹رչ���ʹ�öԵȡ�����ͷ��Ŀ����ź�,ʵ����Ӧ���ǿ��Խ��ж��Ƶ�
    -- ��ʱ��ʹ��rsi�ر��źŹر�ͷ��
    /*insert \*+append*\
    into tb_st_rsi_trading_close
      select a.time, a.n, 'long' type, i_long_rsi, 'rsi' close_rule
        from tb_st_trading_data a
       where a.rsi1 >= i_short_rsi
         and a.rsi < i_short_rsi
      union all
      select a.time, a.n, 'short' type, i_short_rsi, 'rsi' close_rule
        from tb_st_trading_data a
       where a.rsi1 <= i_long_rsi
         and a.rsi > i_long_rsi;
    commit;*/
  
    -- ����2:ÿ�����23:30Ҫǿ�йر�����ͷ��
    insert into tb_st_rsi_trading_close
      select min(time) time, --
             min(n) n,
             'long' type,
             i_long_rsi,
             'weekend' close_by
        from tb_st_trading_data
       where to_char(time, 'D') = '6' -- ����
         and to_char(time, 'hh24:mi') > '23:30'
       group by to_char(time, 'yyyymmdd')
      union
      select min(time) time, min(n) n, 'short' type, i_short_rsi, 'weekend' close_by
        from tb_st_trading_data
       where to_char(time, 'D') = '6' -- ����
         and to_char(time, 'hh24:mi') > '23:30'
       group by to_char(time, 'yyyymmdd');
    commit;
  
    -- ����3:�����������ǿ�ƹر�����ͷ��
    insert into tb_st_rsi_trading_close
      select max(time) time, max(n) n, 'long' type, i_long_rsi, 'end' close_rule
        from tb_st_trading_data
      union
      select max(time) time, max(n) n, 'short' type, i_short_rsi, 'end' close_rule
        from tb_st_trading_data;
    commit;
  
    -- �ϲ������źź�ƽ���ź�
    execute immediate 'truncate table tb_st_rsi_trading';
    insert into tb_st_rsi_trading --
    with sql1 as
      (select a.n, min(b.n) n1, a.type
         from tb_st_rsi_trading_open a, tb_st_rsi_trading_close b
        where b.n > a.n
          and a.type = b.type
        group by a.n, a.type)
      select a.time, a.n, a.type, a.rsi, b.n n1, b.close_by
        from tb_st_rsi_trading_open a, tb_st_rsi_trading_close b, sql1 c
       where a.n = c.n(+)
         and c.n1 = b.n(+)
         and a.type = c.type(+)
         and c.type = b.type(+);
    commit;
  
    -- �����23���Ժ��ڽ��н��� 
    delete tb_st_rsi_trading
     where to_char(time, 'D') = '6' -- ����
       and to_char(time, 'hh24:mi') >= '23:00';
    commit;
  
    log('get_rsi_trading:����');
  end;

  procedure get_rsi_trading_stat is
  begin
    log('get_rsi_trading_stat:��ʼ');
  
    -- �ϲ�����������Ƭ��RSI�ź�,�γɽ��׼�¼��������������
    execute immediate 'truncate table tb_st_rsi_trading_detail_0';
    insert /*+append*/
    into tb_st_rsi_trading_detail_0 --
    with sql1 as
      (select a.tp_level,
              a.sl_level,
              a.len,
              a.type,
              a.time,
              a.n,
              least(a.n1, b.n1) n1,
              case
                when a.n1 < b.n1 then
                 a.tp
                else
                 0
              end tp,
              case
                when a.n1 < b.n1 then
                 a.sl
                else
                 0
              end sl,
              case
                when a.n1 < b.n1 then
                 a.cl
                else
                 1
              end cl,
              to_char(a.time, 'hh24') hh24,
              b.rsi,
              case
                when a.n1 < b.n1 then
                 a.close_by
                else
                 b.close_by
              end close_by
         from tb_st_profit_slice_bak a, tb_st_rsi_trading_bak b
        where a.n = b.n
          and a.type = b.type)
    --insert into tb_st_rsi_trading_detail_0
      select a.tp_level,
             a.sl_level,
             a.len,
             a.type,
             a.time,
             a.n,
             a.n1,
             a.tp,
             a.sl,
             a.cl,
             decode(a.type, 'long', (c.bid - b.ask), 'short', (b.bid - c.ask)) *
             10000 profit,
             a.hh24,
             a.rsi,
             a.close_by
        from sql1 a, tb_st_trading_data b, tb_st_trading_data c
       where a.n = b.n
         and a.n1 = c.n;
    commit;
  
    -- �������׼�¼�Ͷ�Ӧ�Ļ�����Ƭ,�γɽ�����ϸ
    execute immediate 'truncate table tb_st_rsi_trading_detail_1';
    insert /*+append*/
    into tb_st_rsi_trading_detail_1
      select a.*,
             dense_rank() over(order by a.tp_level, a.sl_level, a.len, a.type, to_char(a.time, 'hh24'), a.rsi) g,
             count(*) over(partition by a.tp_level, a.sl_level, a.len, a.type, to_char(a.time, 'hh24'), a.rsi) gcnt,
             row_number() over(partition by a.tp_level, a.sl_level, a.len, a.type, to_char(a.time, 'hh24'), a.rsi order by a.n) m,
             sum(profit) over(partition by a.tp_level, a.sl_level, a.len, a.type, to_char(a.time, 'hh24'), a.rsi order by a.n) total_profit
        from tb_st_rsi_trading_detail_0 a;
    commit;
  
    -- ͨ��һԪ���Իع���ϳ�"���״���--�ۼ�����"��ֱ�߷���
    execute immediate 'truncate table tb_st_rsi_trading_detail_fit';
    insert /*+append*/
    into tb_st_rsi_trading_detail_fit
      select g,
             count(*) cnt,
             sum((x - x0) * (y - y0)) / sum((x - x0) * (x - x0)) b1,
             avg(y) - sum((x - x0) * (y - y0)) / sum((x - x0) * (x - x0)) * avg(x) b0
        from (select g,
                     m x,
                     total_profit y,
                     avg(m) over(partition by g) x0,
                     avg(total_profit) over(partition by g) y0
                from tb_st_rsi_trading_detail_1
               where gcnt > 1)
       group by g;
    commit;
  
    --  ����ÿ�ʽ��׵����
    execute immediate 'truncate table tb_st_rsi_trading_detail';
    insert /*+append*/
    into tb_st_rsi_trading_detail
      select a.*,
             b0 + b.b1 * a.m predict_total_profit,
             abs(total_profit - (b0 + b.b1 * a.m)) deviation,
             b.b1 k
        from tb_st_rsi_trading_detail_1 a, tb_st_rsi_trading_detail_fit b
       where a.g = b.g(+);
    commit;
  
    -- �Խ��׼�¼����ͳ��
    execute immediate 'truncate table tb_st_rsi_trading_stat';
    insert /*+append*/
    into tb_st_rsi_trading_stat
      select g,
             tp_level,
             sl_level,
             len,
             type,
             hh24,
             rsi,
             count(*) cnt,
             sum(tp) tp,
             sum(sl) sl,
             sum(cl) cl,
             sum(profit) profit,
             sum(profit) / count(*) avg_profit,
             sum(tp * profit) tp_profit,
             sum(sl * profit) sl_profit,
             sum(cl * profit) cl_profit,
             sum(tp) / count(*) tp_pct,
             sum(sl) / count(*) sl_pct,
             sum(cl) / count(*) cl_pct,
             sum(deviation) deviation,
             sum(deviation) / count(*) avg_deviation,
             sum(deviation * deviation) / count(*) avg_deviation_square,
             sum(deviation / abs(decode(total_profit, 0, null, total_profit))) /
             count(*) avg_deviate_rate,
             max(k) k
      --row_number() over(order by sum(profit) desc) r1,
      --row_number() over(order by sum(tp) / count(*) desc) r2,
      --row_number() over(order by sum(deviation) / count(*)) r3
        from tb_st_rsi_trading_detail
       group by g, tp_level, sl_level, len, type, hh24, rsi;
    commit;
  
    log('get_rsi_trading_stat:����');
  end;

  procedure get_data(i_table_name varchar2) is
    i number;
    j number;
  begin
    log('get_data:��ʼ');
  
    -- ���뽨���ԭʼ����
    --load_trading_data('tb_hfmarketsltd_eurcad_m1_real', 120);
    load_trading_data(i_table_name, 120);
  
    -- ��������ӯ����Ƭ����    
    execute immediate 'truncate table tb_st_profit_slice_bak';
    i := 0.5;
    while i <= 10 loop
      j := 0.5;
      while j <= 30 loop
        get_profit_slice(i, j, 120);
        insert /*+append*/
        into tb_st_profit_slice_bak
          select * from tb_st_profit_slice;
        commit;
        j := j + .5;
      end loop;
      i := i + .5;
    end loop;
  
    -- ��������RSI���׵�
    execute immediate 'truncate table tb_st_rsi_trading_bak';
    i := 5;
    while i <= 35 loop
      get_rsi_trading(i, 100 - i);
      insert /*+append*/
      into tb_st_rsi_trading_bak
        select * from tb_st_rsi_trading;
      commit;
      i := i + 1;
    end loop;
  
    -- ��ȡ��������ͳ�ƽ��
    get_rsi_trading_stat;
  
    log('get_data:����');
  end;

  procedure test01 is
  begin
    clear_log;
    log('test01:��ʼ');
    -- ����201306����
    get_data('tb_hfltd_eurcad_m1_42p_201306');
    execute immediate '
      create table tb_st_rsi_trading_stat_201306 as select * from tb_st_rsi_trading_stat ';
    execute immediate '      
      create table tb_st_rsi_trading_201306 as select * from tb_st_rsi_trading_detail_1 ';
    log('test01:201306���');
  
    -- ����201307����
    get_data('tb_hfltd_eurcad_m1_42p_201307');
    execute immediate '
      create table tb_st_rsi_trading_stat_201307 as select * from tb_st_rsi_trading_stat ';
    execute immediate '      
      create table tb_st_rsi_trading_201307 as select * from tb_st_rsi_trading_detail_1 ';
    log('test01:201307���');
  
    -- ����201308����
    get_data('tb_hfltd_eurcad_m1_42p_201308');
    execute immediate '
      create table tb_st_rsi_trading_stat_201308 as select * from tb_st_rsi_trading_stat ';
    execute immediate '      
      create table tb_st_rsi_trading_201308 as select * from tb_st_rsi_trading_detail_1 ';
    log('test01:201308���');
    log('test01:����');
  end;

  procedure test02 is
  begin
    clear_log;
    log('test02:��ʼ');
    -- ����30p����
    get_data('tb_hfmarketsltd_eurcad_m1_30p');
    execute immediate '
      create table tb_st_rsi_trading_stat_30p as select * from tb_st_rsi_trading_stat ';
    execute immediate '      
      create table tb_st_rsi_trading_detail_30p as select * from tb_st_rsi_trading_detail_1 ';
    log('test01:30p���');
  
    -- ����35p����
    get_data('tb_hfmarketsltd_eurcad_m1_35p');
    execute immediate '
      create table tb_st_rsi_trading_stat_35p as select * from tb_st_rsi_trading_stat ';
    execute immediate '      
      create table tb_st_rsi_trading_detail_35p as select * from tb_st_rsi_trading_detail_1 ';
    log('test01:35p���');
  
    -- ����40p����
    get_data('tb_hfmarketsltd_eurcad_m1_40p');
    execute immediate '
      create table tb_st_rsi_trading_stat_40p as select * from tb_st_rsi_trading_stat ';
    execute immediate '      
      create table tb_st_rsi_trading_detail_40p as select * from tb_st_rsi_trading_detail_1 ';
    log('test01:40p���');
  
    log('test02:����');
  end;

  procedure test03 is
  begin
    clear_log;
    --load_trading_data('duh0829_1', 120);
    --load_trading_data('duh0829_2',120);
    --load_trading_data('DUH0902_1', 120);
    --get_rsi_trading(30, 70);
    get_data('DUH0902_3');
  end;

/*
-- ���ݼ��
select n,type,rsi,count(*) from tb_st_rsi_trading_bak group by n,type,rsi having count(*) > 1;
select tp_level, sl_level, len, type, n, count(*)
  from tb_st_profit_slice_bak
 group by tp_level, sl_level, len, type, n
having count(*) > 1;
*/

/*
-- ͳ�ƽ��
select a.tp_level,
       a.sl_level,
       a.len,
       a.type,
       to_char(a.time, 'hh24') hh24,
       b.rsi,
       count(*) cnt,
       sum(tp) tp,
       sum(sl) sl,
       sum(cl) cl,
       sum(profit) profit,
       sum(tp * profit) tp_profit,
       sum(sl * profit) sl_profit,
       sum(cl * profit) cl_profit,
       sum(tp)/count(*) tp_pct,
       sum(sl)/count(*) sl_pct,
       sum(cl)/count(*) cl_pct
  from tb_st_profit_slice_bak a, tb_st_rsi_trading_bak b
 where a.n = b.n
   and a.type = b.type
 group by a.tp_level,
          a.sl_level,
          a.len,
          a.type,
          to_char(a.time, 'hh24'),
          b.rsi;
*/

/*
select a.*,
       to_char(a.time, 'hh24') hh24,
       b.rsi,
       dense_rank() over(ORDER BY a.tp_level, a.sl_level, a.len, a.type, to_char(a.time, 'hh24'), b.rsi) g,
       row_number() over(partition by a.tp_level, a.sl_level, a.len, a.type, to_char(a.time, 'hh24'), b.rsi order by a.n) m
  from tb_st_profit_slice_bak a, tb_st_rsi_trading_bak b
 where a.n = b.n
   and a.type = b.type;
*/

/*
# һԪ���Իع�
x = cars$speed;
y = cars$dist;
# ʹ�ù�ʽ�ֹ�����
B1=sum((x-mean(x))*(y-mean(y)))/sum((x-mean(x))^2);
B0=mean(y)-B1*mean(x);
paste("ģ�� : Y = ",round(B0,3)," + ",round(B1,3),"X",sep = "");
# ʹ��lm��������
lm(y~x);
*/

/*
select tp_level,
       sl_level,
       rsi,
       cnt,
       profit,
       tp_pct,
       profit / cnt avg_profit,
       avg_deviate_rate,
       k
  from tb_st_rsi_trading_stat
 where type = 'short'
   and hh24 = '00'
   and cnt > 1;
*/

/*
drop table duh0921_1;
create table duh0921_1 as 
--select * from tb_st_rsi_trading_detail where tp_level = 5 and sl_level = 10 and rsi in (30,70);
select * from tb_st_rsi_trading_detail where tp_level = 2.5 and sl_level = 12 and rsi in (30,70);
select a.n,       
       a.close_by,
       to_char(a.time,'yyyy.mm.dd hh24:mi') open_time,
       decode(a.type, 'long', b.ask, 'short', b.bid, 0) open_price,
       to_char(c.time,'yyyy.mm.dd hh24:mi') open_time,
       decode(a.type, 'long', c.bid, 'short', c.ask, 0) close_price
  from duh0921_1 a, tb_st_trading_data b, tb_st_trading_data c
 where a.n = b.n
   and a.n1 = c.n order by a.n;
*/

end pkg_scalping_tester;
/
