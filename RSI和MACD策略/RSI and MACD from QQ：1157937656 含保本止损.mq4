//+------------------------------------------------------------------+
//|                              RSI and MACD from QQ：1157937656.mq4 |
//|                                                         Antasann |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Antasann"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
input bool auto=0;//是否手动确认交易
input int period=14;//RSI周期
extern double stoploss=300;//初始止损点
extern double movecondition=100;//触发移动止损的盈利点数
extern double movespace=100;//每次移动止损空间点数
sinput double lots=0.1;//手数


sinput uint magic=9051;//EA识别码
uint ticket;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   stoploss*=Point;
   movecondition*=Point;
   movespace*=Point;
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS) && OrderSymbol()==Symbol() && OrderMagicNumber()==magic)
        {
         ticket=OrderTicket();
         break;
        }
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
//---
   double h4=iRSI(NULL,PERIOD_H4,period,PRICE_CLOSE,0);
   double h1=iRSI(NULL,PERIOD_H1,period,PRICE_CLOSE,0);
   double min15=iRSI(NULL,PERIOD_M15,period,PRICE_CLOSE,0);
   double min15_1=iRSI(NULL,PERIOD_M15,period,PRICE_CLOSE,1);
/*  Print(
         "h4=",h4,
         " h1=",h1,
         " min15=",min15,
         " min15_1=",min15_1
         );*/
   if(OrderSelect(ticket,SELECT_BY_TICKET) && OrderCloseTime()==0)
     {
      if(OrderType()==OP_BUY)
        {
         if(OrderOpenPrice()-OrderStopLoss()>stoploss-movespace/2)
           {
            if(Bid>OrderOpenPrice()+movecondition)
              {
               double prevstoploss=OrderStopLoss();
               OrderModify(ticket,OrderOpenPrice(),prevstoploss+movespace,0,0);
              }
           }
         else
           {
            if(Bid>OrderStopLoss()+movecondition)
              {
               double prevstoploss=OrderStopLoss();
               OrderModify(ticket,OrderOpenPrice(),prevstoploss+movespace,0,0);
              }
           }
        }
      else if(OrderType()==OP_SELL)
        {
         if(OrderStopLoss()-OrderOpenPrice()>stoploss-movespace/2)
           {
            if(Ask<OrderOpenPrice()-movecondition)
              {
               double prevstoploss=OrderStopLoss();
               OrderModify(ticket,OrderOpenPrice(),prevstoploss-movespace,0,0);
              }
           }
         else
           {
            if(Ask<OrderStopLoss()-movecondition)
              {
               double prevstoploss=OrderStopLoss();
               Print("prevstoploss=",prevstoploss," prevstoploss-movespace=",prevstoploss-movespace);
               OrderModify(ticket,OrderOpenPrice(),prevstoploss-movespace,0,0);
              }
           }
        }
     }
   else
     {
      if(h4<20 && h1<25 && min15<30 && min15_1>=30)
        {
         if(!auto || MessageBox("多单信号，要做速点！",NULL,MB_YESNO)==IDYES)
            ticket=OrderSend(NULL,OP_BUY,lots,Ask,50,NormalizeDouble(Ask-stoploss,Digits),0,NULL,magic,0,clrBlue);
        }
      else if(h4>80 && h1>75 && min15>70 && min15_1<=70)
        {
         if(!auto || MessageBox("空单信号，要做速点！",NULL,MB_YESNO)==IDYES)
            ticket=OrderSend(NULL,OP_SELL,lots,Bid,50,NormalizeDouble(Bid+stoploss,Digits),0,NULL,magic,0,clrRed);
        }
     }
  }
//+------------------------------------------------------------------+
