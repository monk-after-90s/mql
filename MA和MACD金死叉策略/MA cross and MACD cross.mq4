//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property strict
input bool onetick=0;   //只在柱子跑完时再判定
input double lots=0.1;  //单量
input uchar distance=3; //允许两种指标交叉点之间的最远距离
input string a;         //快速(绿色)均线参数
input int period1=10;   //时间周期
input string b;         //慢速(黄色)均线参数
input int period2=60;   //时间周期
input string c;         //MACD参数
input int fast_ema_period=12;//快EMA
input int slow_ema_period=26;//慢EMA
input int signal_period=9;   //MACD SMA/Signal SMA
input ENUM_APPLIED_PRICE macdprice=0;//应用价格
int ticket;
int magic=1348549;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   if(period1>=period2)
     {
      Alert("快速均线周期必须小于慢速均线周期！EA移除。");
      return INIT_FAILED;
     }
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---deal the opened order
   if(onetick&&Volume[0]>1)return;
   if(OrderSelect(ticket,SELECT_BY_TICKET) && OrderCloseTime()==0)
     {
      if((iMA(NULL,0,period1,0,0,0,onetick)>iMA(NULL,0,period2,0,0,0,onetick) || iMACD(NULL,0,fast_ema_period,slow_ema_period,signal_period,macdprice,0,onetick)>iMACD(NULL,0,fast_ema_period,slow_ema_period,signal_period,macdprice,1,onetick)) && OrderType()==OP_SELL)
        {
         OrderClose(ticket,lots,Ask,20,Red);
        }
      else if((iMA(NULL,0,period1,0,0,0,onetick)<iMA(NULL,0,period2,0,0,0,onetick) || iMACD(NULL,0,fast_ema_period,slow_ema_period,signal_period,macdprice,0,onetick)<iMACD(NULL,0,fast_ema_period,slow_ema_period,signal_period,macdprice,1,onetick)) && OrderType()==OP_BUY)
        {
         OrderClose(ticket,lots,Bid,20,Blue);
        }
      else return;
     }
//Open an order
   bool MAcrosstype,MACDcrosstype;
   ushort MAcrossposition=MAcrossposition(MAcrosstype),MACDcrossposition=MACDcrossposition(MACDcrosstype);
   if(MAcrossposition==onetick || MACDcrossposition==onetick)
     {
      if(fabs(MACDcrossposition-MAcrossposition)<=distance)
        {
         if(MAcrosstype==0 && MACDcrosstype==0)
           {
            ticket=OrderSend(NULL,OP_BUY,lots,Ask,20,0,0,NULL,magic,0,Blue);
           }
         else if(MAcrosstype==1 && MACDcrosstype==1)
           {
            ticket=OrderSend(NULL,OP_SELL,lots,Bid,20,0,0,NULL,magic,0,Red);
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ushort MAcrossposition(bool&type)
  {
   for(ushort i=onetick;;i++)
     {
      if(iMA(NULL,0,period1,0,0,0,i)>iMA(NULL,0,period2,0,0,0,i) && iMA(NULL,0,period1,0,0,0,i+1)<iMA(NULL,0,period2,0,0,0,i+1))
        {
         type=0;
         return i;
        }
      if(iMA(NULL,0,period1,0,0,0,i)<iMA(NULL,0,period2,0,0,0,i) && iMA(NULL,0,period1,0,0,0,i+1)>iMA(NULL,0,period2,0,0,0,i+1))
        {
         type=1;
         return i;
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ushort MACDcrossposition(bool&type)
  {
   for(ushort i=onetick;;i++)
     {
      if(iMACD(NULL,0,fast_ema_period,slow_ema_period,signal_period,macdprice,1,i)>iMACD(NULL,0,fast_ema_period,slow_ema_period,signal_period,macdprice,0,i)
         && iMACD(NULL,0,fast_ema_period,slow_ema_period,signal_period,macdprice,1,i+1)<iMACD(NULL,0,fast_ema_period,slow_ema_period,signal_period,macdprice,0,i+1)
         )
        {
         type=1;
         return i;
        }
      if(iMACD(NULL,0,fast_ema_period,slow_ema_period,signal_period,macdprice,1,i)<iMACD(NULL,0,fast_ema_period,slow_ema_period,signal_period,macdprice,0,i)
         && iMACD(NULL,0,fast_ema_period,slow_ema_period,signal_period,macdprice,1,i+1)>iMACD(NULL,0,fast_ema_period,slow_ema_period,signal_period,macdprice,0,i+1)
         )
        {
         type=0;
         return i;
        }
     }
  }
//+------------------------------------------------------------------+
