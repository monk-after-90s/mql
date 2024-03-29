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

   if(OrderSelect(ticket,SELECT_BY_TICKET) && OrderType()<2 && OrderSymbol()==Symbol() && OrderMagicNumber()==magic && OrderCloseTime()==0)
     {
      double m21=iMACD(NULL,0,104,240,1,0,0,1);
      double m22=iMACD(NULL,0,104,240,1,0,0,2);

      if(m21<0 || m21<m22)
        {
         OrderClose(ticket,OrderLots(),OrderType()?Ask:Bid,100);
        }
     }
   else
     {
      double m10=iMACD(NULL,0,26,60,1,0,0,0);

      double m20=iMACD(NULL,0,104,240,1,0,0,0);
      double m21=iMACD(NULL,0,104,240,1,0,0,1);
      double m22=iMACD(NULL,0,104,240,1,0,0,2);

      if(m10>0 && m20>0 && m21>m22)
        {
         ticket=OrderSend(NULL,OP_BUY,lots,Ask,50,0,0,NULL,magic,0,clrBlue);
        }
      else if(m10<0 && m20<0 && m21<m22)
        {
         ticket=OrderSend(NULL,OP_SELL,lots,Bid,50,0,0,NULL,magic,0,clrRed);
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
//+------------------------------------------------------------------+
