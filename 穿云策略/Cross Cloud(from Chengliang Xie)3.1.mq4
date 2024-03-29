//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property strict
extern double buylots=0.02;//买单单量
extern double selllots=0.01;//卖单单量
extern double takeprofit=20;//盈利大点,0为不设置止盈

sinput ushort magic=32213;//EA识别码
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   takeprofit=takeprofit*10*Point;
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
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
   static double prevAsk=Ask,prevBid=Bid;
//Attention!!!SPANB and SPANA may exchange each other's position
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
         if(MessageBox("空单信号，要做快点！",NULL,MB_YESNO)==IDYES)
            if(0>OrderSend(NULL,OP_SELL,selllots,Bid,50,0,NormalizeDouble(takeprofit?Bid-takeprofit:0,Digits),NULL,magic,0,clrRed))
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
         if(MessageBox("多单信号，要做快点！",NULL,MB_YESNO)==IDYES)
            if(0>OrderSend(NULL,OP_BUY,buylots,Ask,50,0,NormalizeDouble(takeprofit?Ask+takeprofit:0,Digits),NULL,magic,0,clrBlue))
               Alert("Fail to open the buy order!");
     }
   prevAsk=Ask;prevBid=Bid;
  }
//+------------------------------------------------------------------+
