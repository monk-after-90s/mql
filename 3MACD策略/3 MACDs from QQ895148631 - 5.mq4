//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property strict
input uint magic=67896;//EA识别码
input double lots=0.1;   //手数
input double stoploss=10;//Stoploss points
input double takeprofit=700;//Takeprofit points

uint ticket;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS) && OrderSymbol()==Symbol() && OrderMagicNumber()==magic)
        {
         ticket=OrderTicket();
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
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   char macd=macd2();
   if(OrderSelect(ticket,SELECT_BY_TICKET) && OrderCloseTime()==0);
   else
     {
      if(macd2()==0)
        {
         ticket=OrderSend(NULL,OP_BUY,lots,Ask,50,NormalizeDouble(Ask-stoploss*Point,Digits),NormalizeDouble(Ask+takeprofit*Point,Digits),NULL,magic,0,clrBlue);
        }
      else if(macd2()==1)
        {
         ticket=OrderSend(NULL,OP_SELL,lots,Bid,50,NormalizeDouble(Bid+stoploss*Point,Digits),NormalizeDouble(Bid-takeprofit*Point,Digits),NULL,magic,0,clrRed);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
char macd2()
  {
   double m1=iMACD(NULL,0,26,60,1,0,0,0);
   double m11=iMACD(NULL,0,26,60,1,0,0,1);

   double m2=iMACD(NULL,0,104,240,1,0,0,0);

   if(m11<=0 && m1>0 && m2>0)return 0;//buy
   if(m11>=0 && m1<0 && m2<0)return 1;//sell
   return 3;
  }
//+------------------------------------------------------------------+
