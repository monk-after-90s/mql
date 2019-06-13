//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
enum order
  {
   buy,                   //多单
   sell,                  //空单
   none                   //手动
  };
#property strict
input order op =none;     //运行EA即开多/空单或者手动开单
input double lots=0.01;   //手数

extern double stoploss=0; //移动止损发生前的止损距离点数(0为不设置)

extern double interval=10;//间距点数
extern uchar num=10;      //最大单量数

extern double profit=20;  //移动止损触发的盈利点数
extern double trail=5;    //移动止损距离点数
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   num--;
   interval*=(Point*10);
   profit*=(Point*10);
   trail*=(Point*10);
   stoploss*=(Point*10);
   if(!ObjectCreate("Delete",OBJ_BUTTON,0,0,0))return INIT_FAILED;
   ObjectSetInteger(0,"Delete",OBJPROP_XSIZE,380);
   ObjectSetInteger(0,"Delete",OBJPROP_YSIZE,40);
   ObjectSetInteger(0,"Delete",OBJPROP_XDISTANCE,300);
   ObjectSetInteger(0,"Delete",OBJPROP_YDISTANCE,10);

   ObjectSetString(0,"Delete",OBJPROP_TEXT,"点击删除所有订单");
   ObjectSetInteger(0,"Delete",OBJPROP_FONTSIZE,15);
   ObjectSetInteger(0,"Delete",OBJPROP_COLOR,clrRed);
   if(op==buy)
     {
      OrderSend(NULL,OP_BUY,lots,Ask,50,stoploss?(Ask-stoploss):0,0);
     }
   else if(op==sell)
     {
      OrderSend(NULL,OP_SELL,lots,Bid,50,stoploss?(Bid+stoploss):0,0);
     }
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
bool deleteing=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         // Event ID 
                  const long& lparam,   // Parameter of type long event 
                  const double& dparam, // Parameter of type double event 
                  const string& sparam  // Parameter of type string events 
                  )
  {
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      if(sparam=="Delete")
        {
         if(ObjectGetInteger(0,"Delete",OBJPROP_STATE))
           {
            ObjectSetString(0,"Delete",OBJPROP_TEXT,"正在删除所有订单，EA功能暂停");
            deleteing=1;
            for(uchar Li_4=0; Li_4<OrdersTotal(); Li_4++)
              {
               if(OrderSelect(Li_4,SELECT_BY_POS,MODE_TRADES))
                  if(OrderSymbol()==Symbol())
                    {
                     if(OrderType()==OP_BUY)
                       {
                        if(!OrderClose(OrderTicket(),OrderLots(),Bid,500))Li_4--;
                       }
                     else if(OrderType()==OP_SELL)
                       {
                        if(!OrderClose(OrderTicket(),OrderLots(),Ask,500))Li_4--;
                       }
                     else
                       {
                        if(!OrderDelete(OrderTicket()))Li_4--;
                       }
                    }
              }
           }
         else
           {

            ObjectSetString(0,"Delete",OBJPROP_TEXT,"点击删除所有订单");
            deleteing=0;
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   ObjectDelete("Delete");
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   if(deleteing)
     {
      for(uchar Li_4=0; Li_4<OrdersTotal(); Li_4++)
        {
         if(OrderSelect(Li_4,SELECT_BY_POS,MODE_TRADES))
            if(OrderSymbol()==Symbol())
              {
               if(OrderType()==OP_BUY)
                 {
                  OrderClose(OrderTicket(),OrderLots(),Bid,500);
                 }
               else if(OrderType()==OP_SELL)
                 {
                  OrderClose(OrderTicket(),OrderLots(),Ask,500);
                 }
               else
                 {
                  OrderDelete(OrderTicket());
                 }
              }
        }
      return;
     }
   double centerlots;
   double centerprice=centerprice(centerlots);
   if(centerprice==0)return;
   double prices[];
   ArrayResize(prices,num+3);
   ArrayInitialize(prices,0.0);
   bool bORs;
   for(uchar Li_4=0; Li_4<OrdersTotal(); Li_4++)
     {
      if(OrderSelect(Li_4,SELECT_BY_POS,MODE_TRADES))
         if(OrderSymbol()==Symbol())
           {
            if(OrderType()==OP_BUY)
              {
               if(OrderStopLoss()==0 && stoploss!=0)OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-stoploss,0,0);
               if(Bid-OrderOpenPrice()>=profit && Bid-OrderStopLoss()>trail)
                 {
                  OrderModify(OrderTicket(),OrderOpenPrice(),Bid-trail,0,0);
                 }
              }
            else if(OrderType()==OP_SELL)
              {
               if(OrderStopLoss()==0 && stoploss!=0)OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+stoploss,0,0);
               else if(OrderStopLoss()==0 && stoploss==0)OrderModify(OrderTicket(),OrderOpenPrice(),999999,0,0);
               if(OrderOpenPrice()-Ask>=profit && OrderStopLoss()-Ask>trail)
                 {
                  OrderModify(OrderTicket(),OrderOpenPrice(),Ask+trail,0,0);
                 }
              }
            bORs=(OrderType()==OP_BUY || OrderType()==OP_BUYLIMIT || OrderType()==OP_BUYSTOP)?0:1;
            if(OrderOpenPrice()<=centerprice+
               MathCeil(num/2.0)*interval && 
               OrderOpenPrice()>=centerprice-
               MathCeil(num/2.0)*interval
               )
              {
               if(arraysearch(prices,OrderOpenPrice()))
                 {
                  OrderDelete(OrderTicket());
                  continue;
                 }
               for(uchar i=0;i<num+3;i++)
                 {
                  if(prices[i]==0)
                    {
                     prices[i]=OrderOpenPrice();
                     break;
                    }
                 }
              }
            else
              {
               OrderDelete(OrderTicket());
              }
           }
     }
/*for(uchar i=0;i<ArraySize(prices);i++)
     {
      Alert("prices[",i,"]=",prices[i]);
     }
   Alert("centerprice=",centerprice);*/
   for(char i=-MathCeil(num/2.0);i<=MathCeil(num/2.0);i++)
     {
/* for(uchar i=0;i<ArraySize(prices);i++)
        {
         Alert("prices[",i,"]=",prices[i]);
        }
      Alert("centerprice+i*interval=",centerprice+i*interval);*/
      if(!arraysearch(prices,NormalizeDouble(centerprice+i*interval,Digits)))
        {
         if(bORs)
           {
            OrderSend(NULL,OP_SELLLIMIT,centerlots,centerprice+i*interval,0,0,NULL);
            OrderSend(NULL,OP_SELLSTOP,centerlots,centerprice+i*interval,0,0,NULL);
           }
         else
           {
            OrderSend(NULL,OP_BUYLIMIT,centerlots,centerprice+i*interval,0,0,NULL);
            OrderSend(NULL,OP_BUYSTOP,centerlots,centerprice+i*interval,0,0,NULL);
           }
        }
     }
  }
//+------------------------------------------------------------------+
bool arraysearch(double&array[],double value)
  {
   for(uchar i=0;i<ArraySize(array);i++)
     {
      if(NormalizeDouble(array[i],Digits)==NormalizeDouble(value,Digits))
        {
         return 1;
        }
     }
   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double centerprice(double&centerlots)
  {
   double minidifference=999999999;
   double centerprice=0;
   double lots=0;
   for(uchar Li_4=0; Li_4<OrdersTotal(); Li_4++)
     {
      if(OrderSelect(Li_4,SELECT_BY_POS,MODE_TRADES))
         if(OrderSymbol()==Symbol())
           {
            double difference=fabs(OrderOpenPrice()-((OrderType()==OP_BUY || OrderType()==OP_BUYLIMIT || OrderType()==OP_BUYSTOP)?Ask:Bid));
            if(difference<minidifference)
              {
               minidifference=difference;
               centerprice=OrderOpenPrice();
               lots=OrderLots();
              }
           }
     }
   centerlots=lots;
   return NormalizeDouble(centerprice,Digits);
  }
//+------------------------------------------------------------------+
