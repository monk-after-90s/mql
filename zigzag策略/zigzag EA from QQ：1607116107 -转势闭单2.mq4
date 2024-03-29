//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property strict
#property description "建议放在M5周期"

extern double tp=40;//止盈点数
extern double sl=400;//止盈点数
input uint magic=431;//EA识别码
input double lots=0.01;//单量
input int shift=0;//极点出现后第几个柱子开始下单
#resource "ZigZag.ex4" 
input string a;//Zigzag三个参数
input int Depth=12;
input int Deviation=5;
input int Backstep=3;
uint ticket=0;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   tp*=Point;
   sl*=Point;
   for(uchar i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS) && OrderType()<2 && OrderSymbol()==Symbol() && OrderMagicNumber()==magic)
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
/*  if(OrderSelect(ticket,SELECT_BY_TICKET) && OrderCloseTime()==0)
      return;*/

   double zz;
   if((zz=iCustom(NULL,0,"::ZigZag.ex4",Depth,Deviation,Backstep,0,shift))>0)
     {
      if(fabs(High[shift]-zz)>fabs(Low[shift]-zz))
        {
         if(!OrderSelect(ticket,SELECT_BY_TICKET) || (OrderSelect(ticket,SELECT_BY_TICKET) && OrderCloseTime()>0))
            ticket=OrderSend(NULL,OP_BUY,lots,Ask,10,NormalizeDouble(Ask-sl,Digits),NormalizeDouble(Ask+tp,Digits),NULL,0,0,Blue);
         else if(OrderType()==OP_SELL)
           {
            OrderClose(OrderTicket(),OrderLots(),Ask,50);
            ticket=OrderSend(NULL,OP_BUY,lots,Ask,10,NormalizeDouble(Ask-sl,Digits),NormalizeDouble(Ask+tp,Digits),NULL,0,0,Blue);
           }
        }
      else
        {
         if(!OrderSelect(ticket,SELECT_BY_TICKET) || (OrderSelect(ticket,SELECT_BY_TICKET) && OrderCloseTime()>0))
            ticket=OrderSend(NULL,OP_SELL,lots,Bid,10,NormalizeDouble(Bid+sl,Digits),NormalizeDouble(Bid-tp,Digits),NULL,0,0,Red);
         else if(OrderType()==OP_BUY)
           {
            OrderClose(OrderTicket(),OrderLots(),Bid,50);
            ticket=OrderSend(NULL,OP_SELL,lots,Bid,10,NormalizeDouble(Bid+sl,Digits),NormalizeDouble(Bid-tp,Digits),NULL,0,0,Red);

           }
        }
     }
  }
//+------------------------------------------------------------------+
