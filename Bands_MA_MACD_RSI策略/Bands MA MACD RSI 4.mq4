//+------------------------------------------------------------------+
//|                                        Bulinberg MA MACD RSI.mq4 |
//|                                                         Antasann |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Antasann"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property description "EURUSD M30 is highly recommended"
input bool onebar=0;//只在一个柱子开头判定
input double lots=0.1;//单量
int magic=549390;
int buy_ticket=0,sell_ticket=0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
//HideTestIndicators(true);
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
//---
   if(onebar&&Volume[0]>1)return;
   for(char i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS) && OrderSymbol()==Symbol() && OrderMagicNumber()==magic)
        {
         if(OrderType()==0)
            buy_ticket=OrderTicket();
         if(OrderType()==1)
            sell_ticket=OrderTicket();
        }
     }

   double MA0=iMA(NULL,0,3,0,MODE_EMA,0,onebar);
   double MA1=iMA(NULL,0,3,0,MODE_EMA,0,1+onebar);
   double bands0=iBands(NULL,0,18,2,0,0,0,onebar);
   double bands1=iBands(NULL,0,18,2,0,0,0,onebar+1);

   double MACD=iMACD(NULL,0,12,26,9,0,0,onebar);
   double RSI=iRSI(NULL,0,14,0,onebar);
//开仓
   if(OrderSelect(buy_ticket,SELECT_BY_TICKET) && OrderCloseTime()==0);
   else if(MA0>bands0 && MA1<bands1 && MACD>0 && RSI>50)
   while(0>(buy_ticket=OrderSend(NULL,OP_BUY,lots,Ask,30,0,0,NULL,magic,0,Green)))
                       RefreshRates();
   if(OrderSelect(sell_ticket,SELECT_BY_TICKET) && OrderCloseTime()==0);
   else if(MA0<bands0 && MA1>bands1 && MACD<0 && RSI<50)
   while(0>(sell_ticket=OrderSend(NULL,OP_SELL,lots,Bid,30,0,0,NULL,magic,0,Red)))
                        RefreshRates();
//平仓
   if(Volume[0]>1)return;
   bool close_buy=0,close_sell=0;
   double bands_main=iBands(NULL,0,18,2,0,0,0,1);
   double MACD_main1=iMACD(NULL,0,12,26,9,0,0,1);
   double MACD_signal1=iMACD(NULL,0,12,26,9,0,1,1);
   double MACD_main2=iMACD(NULL,0,12,26,9,0,0,2);
   double MACD_signal2=iMACD(NULL,0,12,26,9,0,1,2);

   if(OrderSelect(buy_ticket,SELECT_BY_TICKET) && OrderCloseTime()==0)
     {
      double bands_upper1=iBands(NULL,0,18,2,0,0,1,1);
      double bands_upper2=iBands(NULL,0,18,2,0,0,1,2);
      if((Close[1]<bands_upper1 && (Open[1]>=bands_upper1 || Close[2]>=bands_upper2 || Open[2]>=bands_upper2)) || Close[1]<bands_main)
        {
         while(!OrderClose(OrderTicket(),OrderLots()/2,Bid,30,Green))RefreshRates();
        }
      if(MACD_main1<MACD_signal1 && MACD_main2>=MACD_signal2)
         while(!OrderClose(OrderTicket(),OrderLots(),Bid,30,Green))RefreshRates();
     }
   if(OrderSelect(sell_ticket,SELECT_BY_TICKET) && OrderCloseTime()==0)
     {
      double bands_lower1=iBands(NULL,0,18,2,0,0,2,1);
      double bands_lower2=iBands(NULL,0,18,2,0,0,2,2);
      if((Close[1]>bands_lower1 && (Open[1]<=bands_lower1 || Close[2]<=bands_lower2 || Open[2]<=bands_lower2)) || Close[1]>bands_main)
         while(!OrderClose(OrderTicket(),OrderLots()/2,Ask,30,Red))RefreshRates();
      if(MACD_main1>MACD_signal1 && MACD_main2<=MACD_signal2)
         while(!OrderClose(OrderTicket(),OrderLots(),Ask,30,Red))RefreshRates();
     }

//if((Close[1]<bands_upper && (Open[1]>=bands_upper || Close[2]>=bands_upper || Open[2]>=bands_upper))/*K线收盘脱离布林通道上轨 具有多层含义,需要逐个测试*/ || Close[1]<bands_main || (MACD_main1<MACD_signal1 && MACD_main2>=MACD_signal2))
//  close_buy=1;
//if((Close[1]>bands_lower && (Open[1]<=bands_lower || Close[2]<=bands_lower || Open[2]<=bands_lower))/*K线收盘脱离布林通道下轨 具有多层含义,需要逐个测试*/ || Close[1]>bands_main || (MACD_main1>MACD_signal1 && MACD_main2<=MACD_signal2))
/* close_sell=1;
   for(ushort i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS) && OrderSymbol()==Symbol() && OrderMagicNumber()==magic)
        {
         if(close_buy==1 && OrderType()==0)
            while(!OrderClose(OrderTicket(),OrderLots(),Bid,30,Green))RefreshRates();
         if(close_sell==1 && OrderType()==1)
            while(!OrderClose(OrderTicket(),OrderLots(),Ask,30,Red)) RefreshRates();
        }
     }*/
  }
//+------------------------------------------------------------------+
