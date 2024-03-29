//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property strict
input ushort direction_count=2;  //几个MA值确定趋势
input int ma_period=1;           //移动平均线周期
input ENUM_MA_METHOD method=0;   //移动平均线计算方式
input ENUM_APPLIED_PRICE price=0;//移动平均线应用价格
input double lots=0.1;           //单量
int buyticket=0;
int sellticket=0;
int magic=54245;
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
   if(Volume[0]>1)return;

   ushort risecount=1,dropcount=1;
   for(ushort i=2;;i++)
     {
      if(iMA(NULL,0,ma_period,0,method,price,i)>iMA(NULL,0,ma_period,0,method,price,i-1))
        {
         if(i==2)OrderClose(buyticket,lots,Bid,50,Blue);
         dropcount++;
        }
      else break;
     }
   for(ushort i=2;;i++)
     {
      if(iMA(NULL,0,ma_period,0,method,price,i)<iMA(NULL,0,ma_period,0,method,price,i-1))
        {
         if(i==2)OrderClose(sellticket,lots,Ask,50,Red);
         risecount++;
        }
      else break;
     }
   if(OrderSelect(buyticket,SELECT_BY_TICKET) && OrderCloseTime()==0 && OrderType()==OP_BUY);
   else if(risecount>=direction_count)
     {
      if(0>(buyticket=OrderSend(NULL,OP_BUY,lots,Ask,50,0,0,NULL,magic,0,Blue)))
         Alert("Fail to open the buy order!");
     }
   if(OrderSelect(sellticket,SELECT_BY_TICKET) && OrderCloseTime()==0 && OrderType()==OP_SELL);
   else if(dropcount>=direction_count)
     {
      if(0>(sellticket=OrderSend(NULL,OP_SELL,lots,Bid,50,0,0,NULL,magic,0,Red)))
         Alert("Fail to open the sell order!");
     }

  }
//+------------------------------------------------------------------+
