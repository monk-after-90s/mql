//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property strict
input ushort magic=67896;//EA识别码
input double lots=0.1;   //手数
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---

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
   uint ticket;
   if(macd3()==0)
     {
      if(!HasOrder(ticket))
        {
         OrderSend(NULL,OP_BUY,lots,Ask,50,0,0,NULL,magic,0,clrBlue);
        }
      else if(OrderSelect(ticket,SELECT_BY_TICKET) && OrderType()==OP_SELL && OrderSymbol()==Symbol() && OrderMagicNumber()==magic)
        {
         if(OrderClose(OrderTicket(),OrderLots(),Ask,100))
           {
            OrderSend(NULL,OP_BUY,lots,Ask,50,0,0,NULL,magic,0,clrBlue);
           }
        }
     }
   else if(macd3()==1)
     {
      if(!HasOrder(ticket))
        {
         OrderSend(NULL,OP_SELL,lots,Bid,50,0,0,NULL,magic,0,clrRed);
        }
      else if(OrderSelect(ticket,SELECT_BY_TICKET) && OrderType()==OP_BUY && OrderSymbol()==Symbol() && OrderMagicNumber()==magic)
        {
         if(OrderClose(OrderTicket(),OrderLots(),Bid,100))
           {
            OrderSend(NULL,OP_SELL,lots,Bid,50,0,0,NULL,magic,0,clrRed);
           }
        }
     }
   else
     {
      if(OrderSelect(ticket,SELECT_BY_TICKET))OrderClose(OrderTicket(),OrderLots(),OrderType()?Ask:Bid,100);
     }
  }
//+------------------------------------------------------------------+
char macd3()
  {
   double m1=iMACD(NULL,0,3,7,3,0,0,0);
   double m2=iMACD(NULL,0,12,26,9,0,0,0);
   double m3=iMACD(NULL,0,60,130,45,0,0,0);
   if(m1>0&&m2>0&&m3>0)return 0;//buy
   if(m1<0&&m2<0&&m3<0)return 1;//sell
   return 3;
  }
//+------------------------------------------------------------------+
bool HasOrder(uint&ticket)
  {
   int totalOrders=OrdersTotal();
   for(int pos=0; pos<totalOrders;++pos)
     {
      if(OrderSelect(pos,SELECT_BY_POS,MODE_TRADES))
        {
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic && OrderType()<2)
           {
            ticket=OrderTicket();
            return true;
           }
        }
     }
   return false;
  }
//+------------------------------------------------------------------+
