//+------------------------------------------------------------------+
//|                                             bbbandstop cross.mq4 |
//|                                                         Antasann |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Antasann"
#property link      ""
#property version   "1.00"
#property strict
#resource "\\Indicators\\Downloads\\BBand Stop Alert.ex4"
#define BUY 0;
#define SELL 1;
#define NONE 2;
#define ANY 3;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum bb
  {
   none,                      //Not used
   misplaced,                 //Bbandstop of longer length is not outside which of the shorter one
   sameside                   //The two bbandstops are at the same side
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ma
  {
   unused,                    //Not used
   cross,                     //Use dead cross and gold cross
   position                   //Use positions of moving average lines
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum stoploss
  {
   length_1,                  //Narrow bbandstop
   length_2,                  //Wide bbandstop
   macross                    //Moving average cross
  };
input int length1=10;         //Smaller length of bbandstops
input int length2=20;         //Bigger length of bbandstops
sinput uint magic=3452;       //Magic number
input bool onetick=FALSE;     //Judge only once every bar
extern double lots=0.1;       //Order lots
input float multiplier=1.0;   //Multiplier which Martin strategy uses
input bool markettime=FALSE;  //Trade only when the market is open
input bb bbvote=misplaced;    //Bbandstops judge
input ma mavote=unused;       //Moving averages judge 
input stoploss stop=length_1; //Way to move stoploss
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   if(length1>=length2)
     {
      Alert("length1 must be less than length2.");
      ExpertRemove();
     }
   if(bbvote==none)
     {
      if(mavote==unused || mavote==position)
        {
         Alert("If \"Bbandstops judge\" is set as \"Not used\",\"Moving averages judge\" can't be set as\"Not used\"or\"Use positions of moving average lines\"");
         ExpertRemove();
        }
      if(stop==length_1 || stop==length_2)
        {
         Alert("If \"Bbandstops judge\" is set as \"Not used\",Way to move stoploss can't be set as\"Narrow bbandstop\"or\"Wide bbandstop\"!");
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
   static uint prevbars=Bars;
   if(onetick)
     {
      if(prevbars==Bars)
        {
         return;
        }
     }
   prevbars=Bars;
   if(movestoploss())return;
   if(!markettimevote())return;
   if(bbvote()==3)//ANY
     {
      if(mavote()==0)//BUY
        {
         if(0>OrderSend(NULL,OP_BUY,lots,Ask,50,0,0,NULL,magic))Print("Fail to open the order!");
        }
      else if(mavote()==1)//SELL
        {
         if(0>OrderSend(NULL,OP_SELL,lots,Bid,50,0,0,NULL,magic))Print("Fail to open the order!");
        }
      else if(mavote()==3)//ANY
        {
         Alert("Parameter error!");
         ExpertRemove();
        }
     }
   else if(bbvote()==0)//BUY
     {
      if(mavote()==3 || mavote()==0)
        {
         if(0>OrderSend(NULL,OP_BUY,lots,Ask,50,0,0,NULL,magic))Print("Fail to open the order!");
        }
     }
   else if(bbvote()==1)//SELL
     {
      if(mavote()==1 || mavote()==3)
        {
         if(0>OrderSend(NULL,OP_SELL,lots,Bid,50,0,0,NULL,magic))Print("Fail to open the order!");
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool markettimevote()//TRUE if it is trade time,otherwise FALSE
  {
   if(markettime==FALSE)return 1;
   string currency1=StringSubstr(Symbol(),0,3);
   string currency2=StringSubstr(Symbol(),3,3);
   if(currency1=="USD" || currency2=="USD" || currency1=="CAD" || currency2=="CAD")
     {
      static datetime USDDSTbegin=0,USDDSTend=0;
      if(TimeYear(USDDSTbegin)!=TimeYear(TimeGMT()) || TimeYear(USDDSTend)!=TimeYear(TimeGMT()))
        {
         USDDSTbegin=D'1.3 12:00:00';
         static char count=0;
         do
           {
            if(TimeDayOfWeek(USDDSTbegin)==0)
               count++;
            USDDSTbegin+=24*3600;
           }
         while(count!=2);
         count=0;
         USDDSTbegin-=24*3600;
         USDDSTbegin=USDDSTbegin-10*3600+5*3600;

         USDDSTend=D'1.11 12:00:00';
         while(1)
           {
            if(TimeDayOfWeek(USDDSTend)==0)break;
            USDDSTend+=24*3600;
           }
         USDDSTend=USDDSTend-10*3600+4*3600;
        }
      if(TimeGMT()>USDDSTbegin && TimeGMT()<USDDSTend)
        {
         if(TimeGMT()>D'12:00:00' && TimeGMT()<D'20:00:00')
           {
            return 1;
           }
        }
      else
        {
         if(TimeGMT()>D'13:00:00' && TimeGMT()<D'21:00:00')
           {
            return 1;
           }
        }
     }
   else if(currency1=="NZD" || currency2=="NZD")
     {
      static datetime NZDDSTbegin=0,NZDDSTend=0;
      if(TimeYear(NZDDSTbegin)!=TimeYear(TimeGMT()) || TimeYear(NZDDSTend)!=TimeYear(TimeGMT()))
        {
         NZDDSTbegin=D'30.9 12:00:00';
         while(1)
           {
            if(TimeDayOfWeek(NZDDSTbegin)==0)break;
            NZDDSTbegin-=24*3600;
           }
         NZDDSTbegin=NZDDSTbegin-10*3600-12*3600;
         NZDDSTend=D'1.4 12:00:00';
         while(1)
           {
            if(TimeDayOfWeek(NZDDSTend)==0)break;
            NZDDSTend+=24*3600;
           }
         NZDDSTend=NZDDSTend-10*3600-13*3600;
        }
      if(TimeGMT()>NZDDSTend && TimeGMT()<NZDDSTbegin)//not DST
        {
         if(TimeGMT()>D'21:00:00' || TimeGMT()<D'6:00:00')
           {
            return 1;
           }
        }
      else//DST
        {
         if(TimeGMT()>D'20:00:00' || TimeGMT()<D'5:00:00')
           {
            return 1;
           }
        }
     }
   else if(currency1=="AUD" || currency2=="AUD")
     {
      static datetime DSTbegin=0,DSTend=0;
      if(TimeYear(DSTbegin)!=TimeYear(TimeGMT()) || TimeYear(DSTend)!=TimeYear(TimeGMT()))
        {
         DSTbegin=D'1.10 12:00:00';
         while(1)
           {
            if(TimeDayOfWeek(DSTbegin)==0)break;
            DSTbegin+=24*3600;
           }
         DSTbegin=DSTbegin-10*3600-10*3600;
         DSTend=D'1.4 12:00:00';
         while(1)
           {
            if(TimeDayOfWeek(DSTend)==0)break;
            DSTend+=24*3600;
           }
         DSTend=DSTend-10*3600-11*3600;
        }
      if(TimeGMT()>DSTend && TimeGMT()<DSTbegin)//not DST
        {
         if(TimeGMT()>D'23:00:00' || TimeGMT()<D'8:00:00')
           {
            return 1;
           }
        }
      else//DST
        {
         if(TimeGMT()>D'22:00:00' || TimeGMT()<D'7:00:00')
           {
            return 1;
           }
        }
     }
   else if(currency1=="JPY" || currency2=="JPY")
     {
      if(TimeGMT()>=D'00:00:00' && TimeGMT()<D'7:30:00')
        {
         return 1;
        }
     }
   else if(currency1=="EUR" || currency2=="EUR")
     {
      static datetime DSTbegin=0,DSTend=0;
      if(TimeYear(DSTbegin)!=TimeYear(TimeGMT()) || TimeYear(DSTend)!=TimeYear(TimeGMT()))
        {
         DSTbegin=D'31.3 01:00:00';
         while(1)
           {
            if(TimeDayOfWeek(DSTbegin)==0)
               break;
            DSTbegin-=24*3600;
           }
         DSTend=D'31.10 01:00:00';
         while(1)
           {
            if(TimeDayOfWeek(DSTend)==0)break;
            DSTend-=24*3600;
           }
        }
      if(TimeGMT()>DSTbegin && TimeGMT()<DSTend)
        {
         if(TimeGMT()>D'06:30:00' && TimeGMT()<D'15:00:00')
           {
            return 1;
           }
        }
      else
        {
         if(TimeGMT()>D'07:30:00' && TimeGMT()<D'16:00:00')
           {
            return 1;
           }
        }
     }
   else if(currency1=="CHF" || currency2=="CHF")
     {
      static datetime DSTbegin=0,DSTend=0;
      if(TimeYear(DSTbegin)!=TimeYear(TimeGMT()) || TimeYear(DSTend)!=TimeYear(TimeGMT()))
        {
         DSTbegin=D'31.3 01:00:00';
         while(1)
           {
            if(TimeDayOfWeek(DSTbegin)==0)
               break;
            DSTbegin-=24*3600;
           }
         DSTend=D'31.10 01:00:00';
         while(1)
           {
            if(TimeDayOfWeek(DSTend)==0)break;
            DSTend-=24*3600;
           }
        }
      if(TimeGMT()>DSTbegin && TimeGMT()<DSTend)
        {
         if(TimeGMT()>D'07:30:00' && TimeGMT()<D'15:00:00')
           {
            return 1;
           }
        }
      else
        {
         if(TimeGMT()>D'08:30:00' && TimeGMT()<D'16:00:00')
           {
            return 1;
           }
        }
     }
   else if(currency1=="GBP" || currency2=="GBP")
     {
      static datetime DSTbegin=0,DSTend=0;
      if(TimeYear(DSTbegin)!=TimeYear(TimeGMT()) || TimeYear(DSTend)!=TimeYear(TimeGMT()))
        {
         DSTbegin=D'31.3 01:00:00';
         while(1)
           {
            if(TimeDayOfWeek(DSTbegin)==0)
               break;
            DSTbegin-=24*3600;
           }
         DSTend=D'31.10 01:00:00';
         while(1)
           {
            if(TimeDayOfWeek(DSTend)==0)break;
            DSTend-=24*3600;
           }
         DSTend-=3600;
        }
      if(TimeGMT()>DSTbegin && TimeGMT()<DSTend)
        {
         if(TimeGMT()>D'07:30:00' && TimeGMT()<D'16:30:00')
           {
            return 1;
           }
        }
      else
        {
         if(TimeGMT()>D'8:30:00' && TimeGMT()<D'17:30:00')
           {
            return 1;
           }
        }
     }
   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
/*bool markettimevote()//TRUE if it is trade time,otherwise FALSE
  {
   if(markettime=FALSE)return 1;
   string currency1=StringSubstr(Symbol(),0,3);
   string currency2=StringSubstr(Symbol(),3,3);
   datetime begin,end;
   if(currency1=="NZD" || currency2=="NZD")
     {
      begin=D'20:00:00';
      end=D'5:00:00';
      if(end<begin)end+=24*3600;
      if(TimeGMT()>begin && TimeGMT()<end)
        {
         return 1;
        }
     }
   return 0;
  }*/
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool movestoploss()//TRUE if successful or FALSE
  {
   for(uchar Li_4=0; Li_4<OrdersTotal(); Li_4++)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      if(OrderSelect(Li_4,SELECT_BY_POS,MODE_TRADES))
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic)
           {
            if(stop!=macross)
               //if(stop==length_1)
              {
               if(OrderType()==OP_BUY)
                 {
                  double bbvalue=iCustom(NULL,0,"::Indicators\\Downloads\\BBand Stop Alert.ex4",(stop==length_1)?length1:length2,2,1.0,1,1,1000,false,0,(onetick?1:0));
                  if(OrderStopLoss()!=bbvalue && bbvalue>0)
                    {
                     if(!OrderModify(OrderTicket(),OrderOpenPrice(),bbvalue,OrderTakeProfit(),0))
                        Print("Fail to modify the order.");
                    }
                 }
               else if(OrderType()==OP_SELL)
                 {
                  double bbvalue=iCustom(NULL,0,"::Indicators\\Downloads\\BBand Stop Alert.ex4",(stop==length_1)?length1:length2,2,1.0,1,1,1000,false,1,(onetick?1:0));
                  if(OrderStopLoss()!=bbvalue && bbvalue>0)
                    {
                     if(!OrderModify(OrderTicket(),OrderOpenPrice(),bbvalue,OrderTakeProfit(),0))
                        Print("Fail to modify the order.");
                    }

                 }
              }
            else//stop==macross
              {
               double prevema,prevsmma,ema,smma;
               do
                 {
                  ema=iMA(NULL,0,20,0,MODE_EMA,PRICE_CLOSE,(onetick?1:0));
                  smma=iMA(NULL,0,20,0,MODE_SMMA,PRICE_CLOSE,(onetick?1:0));
                  prevema=iMA(NULL,0,20,0,MODE_EMA,PRICE_CLOSE,(onetick?2:1));
                  prevsmma=iMA(NULL,0,20,0,MODE_SMMA,PRICE_CLOSE,(onetick?2:1));
                 }
               while(GetLastError() && !IsStopped());
               if(OrderType()==OP_SELL)
                 {
                  if(prevema<=prevsmma && ema>=smma)
                     if(!OrderClose(OrderTicket(),OrderLots(),Ask,500,clrRed))
                        Alert("Fail to close the order!Check the error!");
                 }
               else if(OrderType()==OP_BUY)
                 {
                  if(prevema>=prevsmma && ema<=smma)
                     if(!OrderClose(OrderTicket(),OrderLots(),Bid,500,clrBlue))
                        Alert("Fail to close the order!Check the error!");
                 }
              }
            return 1;
           }
     }
   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
char bbvote()
  {
   if(bbvote==none)return ANY;
   double bb1;double bb2;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if((bb1=iCustom(NULL,0,"::Indicators\\Downloads\\BBand Stop Alert.ex4",length1,2,1.0,1,1,1000,false,0,(onetick?1:0)))/*UpTrend Stop*/>0 &&
      (bb2=iCustom(NULL,0,"::Indicators\\Downloads\\BBand Stop Alert.ex4",length2,2,1.0,1,1,1000,false,0,(onetick?1:0)))/*UpTrend Stop*/>0)
     {
      if(bbvote==sameside)return BUY;
      if(bbvote==misplaced && bb2>=bb1)
         return BUY;
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if((bb1=iCustom(NULL,0,"::Indicators\\Downloads\\BBand Stop Alert.ex4",length1,2,1.0,1,1,1000,false,1,(onetick?1:0)))>0 &&
      (bb2=iCustom(NULL,0,"::Indicators\\Downloads\\BBand Stop Alert.ex4",length2,2,1.0,1,1,1000,false,1,(onetick?1:0)))>0)
     {
      if(bbvote==sameside)return SELL;
      if(bbvote==misplaced && bb2<=bb1)
         return SELL;
     }
   return NONE;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
char mavote()
  {
   if(mavote==unused)return ANY;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(mavote==cross)
     {
      double prevema,prevsmma;
      double ema;double smma;
      do
        {
         ema=iMA(NULL,0,20,0,MODE_EMA,PRICE_CLOSE,(onetick?1:0));
         smma=iMA(NULL,0,20,0,MODE_SMMA,PRICE_CLOSE,(onetick?1:0));
         prevema=iMA(NULL,0,20,0,MODE_EMA,PRICE_CLOSE,(onetick?2:1));
         prevsmma=iMA(NULL,0,20,0,MODE_SMMA,PRICE_CLOSE,(onetick?2:1));
        }
      while(GetLastError() && !IsStopped());
      if(prevema>=prevsmma && ema<=smma)
        {
         return SELL;
        }
      if(prevema<=prevsmma && ema>=smma)
        {
         return BUY;
        }
      return NONE;
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(mavote==position)
     {
      double ema;double smma;
      do
        {
         ema=iMA(NULL,0,20,0,MODE_EMA,PRICE_CLOSE,(onetick?1:0));
         smma=iMA(NULL,0,20,0,MODE_SMMA,PRICE_CLOSE,(onetick?1:0));
        }
      while(GetLastError() && !IsStopped());
      if(ema<smma)
         return SELL;
      if(ema>smma)
         return BUY;
     }
   return NONE;
  }
//+------------------------------------------------------------------+
