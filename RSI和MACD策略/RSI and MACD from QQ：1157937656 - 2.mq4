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
input string a;//多单入场RSI值判定标准
input double buyh4=20;//当h4的RSI小于一个值
input double buyh1=25;//当h1的RSI小于一个值
input double buymin15=30;//当min15的RSI小于一个值
input string b;//空单入场RSI值判定标准

input double sellh4=80;//当h4的RSI大于一个值
input double sellh1=75;//当h1的RSI大于一个值
input double sellmin15=70;//当min15的RSI大于一个值



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
         if(Bid>OrderStopLoss()+stoploss+movecondition)
           {
            double prevstoploss=OrderStopLoss();
            OrderModify(ticket,OrderOpenPrice(),prevstoploss+movespace,0,0);
           }
        }
      else if(OrderType()==OP_SELL)
        {
         if(Ask<OrderStopLoss()-stoploss-movecondition)
           {
            double prevstoploss=OrderStopLoss();
            OrderModify(ticket,OrderOpenPrice(),prevstoploss-movespace,0,0);
           }

        }
     }
   else
     {
      if(h4<buyh4 && h1<buyh1 && min15<buymin15 && min15_1>=buymin15)
        {
         if(!auto || MessageBox("多单信号，要做速点！",NULL,MB_YESNO)==IDYES)
            ticket=OrderSend(NULL,OP_BUY,lots,Ask,50,NormalizeDouble(Ask-stoploss,Digits),0,NULL,magic,0,clrBlue);
        }
      else if(h4>sellh4 && h1>sellh1 && min15>sellmin15 && min15_1<=sellmin15)
        {
         if(!auto || MessageBox("空单信号，要做速点！",NULL,MB_YESNO)==IDYES)
            ticket=OrderSend(NULL,OP_SELL,lots,Bid,50,NormalizeDouble(Bid+stoploss,Digits),0,NULL,magic,0,clrRed);
        }
     }
  }
//+------------------------------------------------------------------+
