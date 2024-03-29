//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property strict
input uint magic=67896;//EA识别码
input double lots=0.1;   //手数
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
//---

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   char macd=macd2();
   if(macd==0)
     {
      if(OrderSelect(ticket,SELECT_BY_TICKET) && OrderCloseTime()==0 && OrderType()==OP_BUY);
      else
        {
         uint prvticket=ticket;
         ticket=OrderSend(NULL,OP_BUY,lots,Ask,50,0,0,NULL,magic,0,clrBlue);
         if(OrderSelect(prvticket,SELECT_BY_TICKET) && OrderCloseTime()==0 && OrderType()==OP_SELL)
            OrderClose(OrderTicket(),OrderLots(),Ask,100);
        }
     }
   else if(macd==1)
     {
      if(OrderSelect(ticket,SELECT_BY_TICKET) && OrderCloseTime()==0 && OrderType()==OP_SELL);
      else
        {
         uint prvticket=ticket;
         ticket=OrderSend(NULL,OP_SELL,lots,Bid,50,0,0,NULL,magic,0,clrRed);
         if(OrderSelect(prvticket,SELECT_BY_TICKET) && OrderCloseTime()==0 && OrderType()==OP_BUY)
            OrderClose(OrderTicket(),OrderLots(),Bid,100);
        }
     }
   else
     {
      if(OrderSelect(ticket,SELECT_BY_TICKET) && OrderCloseTime()==0)
        {
         OrderClose(OrderTicket(),OrderLots(),OrderType()?Ask:Bid,100);
        }
     }

  }
//+------------------------------------------------------------------+
char macd2()
  {
   double m1=iMACD(NULL,0,26,60,1,0,0,0);
   double m2=iMACD(NULL,0,104,240,1,0,0,0);
   if(m1>=0&&m2>=0)return 0;//buy
   if(m1<=0&&m2<=0)return 1;//sell
   return 3;
  }