//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property strict
extern double buylots=0.02;//买单单量
extern double selllots=0.01;//卖单单量
extern double takeprofit=20;//盈利大点
sinput ushort magic=32213;//EA识别码
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   takeprofit=takeprofit*10*Point;
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
   static double prevAsk=Ask,prevBid=Bid;
   float SPANB=(float)NormalizeDouble(iIchimoku(Symbol(),NULL,7,22,44,MODE_SENKOUSPANB,0),Digits),
   SPANA=(float)NormalizeDouble(iIchimoku(Symbol(),NULL,7,22,44,MODE_SENKOUSPANA,0),Digits),
   top=SPANB>SPANA?SPANB:SPANA,bottom=SPANB<SPANA?SPANB:SPANA;
   if(Bid!=prevBid && Bid<=bottom && prevBid>=bottom)//sell time
     {
      bool sellexist=0;
      for(char i=0;i<OrdersTotal();i++)
        {
         if(OrderSelect(i,SELECT_BY_POS) && OrderSymbol()==Symbol() && OrderMagicNumber()==magic)
           {
            if(OrderType()==OP_BUY)
               if(!OrderClose(OrderTicket(),OrderLots(),Bid,100))i--;
            if(OrderType()==OP_SELL)sellexist=1;
           }
        }
      if(sellexist==0)
         if(0>OrderSend(NULL,OP_SELL,selllots,Bid,50,0,Bid-takeprofit,NULL,magic,0,clrRed))
            Alert("Fail to open the sell order!");
     }

   if(Ask!=prevAsk && Ask>=top && prevAsk<=top)//buy time
     {
      bool buyexist=0;
      for(char i=0;i<OrdersTotal();i++)
        {
         if(OrderSelect(i,SELECT_BY_POS) && OrderSymbol()==Symbol() && OrderMagicNumber()==magic)
           {
            if(OrderType()==OP_SELL)
               if(!OrderClose(OrderTicket(),OrderLots(),Ask,100))i--;
            if(OrderType()==OP_BUY)buyexist=1;
           }
        }
      if(buyexist==0)
         if(0>OrderSend(NULL,OP_BUY,buylots,Ask,50,0,Ask+takeprofit,NULL,magic,0,clrBlue))
            Alert("Fail to open the buy order!");
     }
   prevAsk=Ask;prevBid=Bid;
  }
//+------------------------------------------------------------------+
