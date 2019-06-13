//+------------------------------------------------------------------+
//|                             Cross Cloud(from Chengliang Xie).mq4 |
//|                                                            Antas |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Antas"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
extern float buylots=0.02;//lots of every buy order
extern float selllots=0.01;//lots of every sell order
sinput ushort magic=32213;//magic number
uint lastticket=0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
Print("buylots=",buylots,"   selllots=",selllots);
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
   static bool turn=0;
   float top=(float)NormalizeDouble(iIchimoku(Symbol(),NULL,7,22,44,MODE_SENKOUSPANB,0),Digits);
   float bottom=(float)NormalizeDouble(iIchimoku(Symbol(),NULL,7,22,44,MODE_SENKOUSPANA,0),Digits);
   if(Bid<top && 
      Bid>bottom && 
      Ask<top && 
      Ask>bottom)turn=1;
   if(!turn)return;
   if(Ask>top)
     {
      uint ticket;
      if((ticket=OrderSend(Symbol(),OP_BUY,buylots,Ask,500,0,Ask+200*Point,NULL,magic,0))>0)
        {
         while(1)
           {
            if(OrderClose(lastticket,selllots,Ask,500))break;
           }
         lastticket=ticket;
         turn=0;
        }
     }
   if(Bid<bottom)
     {
      uint ticket;
      if((ticket=OrderSend(Symbol(),OP_SELL,selllots,Bid,500,0,Bid-200*Point,NULL,magic,0))>0)
        {
         while(1)
           {
            if(OrderClose(lastticket,selllots,Bid,500))break;
           }
         lastticket=ticket;
         turn=0;
        }
     }

  }
//+------------------------------------------------------------------+
