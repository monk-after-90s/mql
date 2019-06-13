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
      static datetime DSTbegin=0,DSTend=0;
      if(TimeYear(TimeGMT()-5*3600)!=TimeYear(DSTbegin) || TimeYear(TimeGMT()-5*3600)!=TimeYear(DSTend))
        {
         DSTbegin=D'1.3 2:00:00';
         static char count=0;
         do
           {
            if(TimeDayOfWeek(DSTbegin)==0)
               count++;
            DSTbegin+=24*3600;
           }
         while(count!=2);
         count=0;
         DSTbegin-=24*3600;

         DSTend=D'1.11 01:00:00';
         while(1)
           {
            if(TimeDayOfWeek(DSTend)==0)break;
            DSTend+=24*3600;
           }
         DSTend-=24*3600;
        }
      if((TimeMonth(TimeGMT()-5*3600)>TimeMonth(DSTbegin) && TimeMonth(TimeGMT()-5*3600)<TimeMonth(DSTend)) || 
         (TimeMonth(TimeGMT()-5*3600)==TimeMonth(DSTbegin) && TimeDay(TimeGMT()-5*3600)>=TimeDay(DSTbegin))||
         (TimeMonth(TimeGMT()-5*3600)==TimeMonth(DSTend) && TimeDay(TimeGMT()-5*3600)<=TimeDay(DSTend)))
        {
         if(TimeHour(TimeGMT()-5*3600)>=7 && TimeHour(TimeGMT()-5*3600)<=14)return 1;
        }
      else
        {
         if(TimeHour(TimeGMT()-5*3600)>=8 && TimeHour(TimeGMT()-5*3600)<=15)return 1;
        }
     }
   if(currency1=="NZD" || currency2=="NZD")
     {
      static datetime DSTbegin=0,DSTend=0;
      if(TimeYear(TimeGMT()+12*3600)!=TimeYear(DSTbegin) || TimeYear(TimeGMT()+12*3600)!=TimeYear(DSTend))
        {
         DSTbegin=D'30.9 12:00:00';
         while(1)
           {
            if(TimeDayOfWeek(DSTbegin)==0)break;
            DSTbegin-=24*3600;
           }
         DSTend=D'1.4 12:00:00';
         while(1)
           {
            if(TimeDayOfWeek(DSTend)==0)break;
            DSTend+=24*3600;
           }
         DSTend-=24*3600;
         if(TimeMonth(TimeGMT()+12*3600)>TimeMonth(DSTbegin) || TimeMonth(TimeGMT()+12*3600)<TimeMonth(DSTend) || 
            (TimeMonth(TimeGMT()+12*3600)==TimeMonth(DSTbegin)&&TimeDay(TimeGMT()+12*3600)>=TimeDay(DSTbegin))||
            (TimeMonth(TimeGMT()+12*3600)==TimeMonth(  DSTend)&&TimeDay(TimeGMT()+12*3600)<=TimeDay(DSTend)))
           {
            if(TimeHour(TimeGMT()+12*3600)>=8 && TimeHour(TimeGMT()+12*3600)<=16)
              {
               return 1;
              }
           }
         else
           {
            if(TimeHour(TimeGMT()+12*3600)>=9 && TimeHour(TimeGMT()+12*3600)<=17)
              {
               return 1;
              }
           }
        }
     }
   if(currency1=="AUD" || currency2=="AUD")
     {
      static datetime DSTbegin=0,DSTend=0;
      if(TimeYear(TimeGMT()+10*3600)!=TimeYear(DSTbegin) || TimeYear(TimeGMT()+10*3600)!=TimeYear(DSTend))
        {
         DSTbegin=D'1.10 12:00:00';
         while(1)
           {
            if(TimeDayOfWeek(DSTbegin)==0)break;
            DSTbegin+=24*3600;
           }
         DSTend=D'1.4 12:00:00';
         while(1)
           {
            if(TimeDayOfWeek(DSTend)==0)break;
            DSTend+=24*3600;
           }
         DSTend-=24*3600;
         if(TimeMonth(TimeGMT()+10*3600)>TimeMonth(DSTbegin) || TimeMonth(TimeGMT()+10*3600)<TimeMonth(DSTend) || 
            (TimeMonth(TimeGMT()+10*3600)==TimeMonth(DSTbegin)&&TimeDay(TimeGMT()+10*3600)>=TimeDay(DSTbegin))||
            (TimeMonth(TimeGMT()+10*3600)==TimeMonth(  DSTend)&&TimeDay(TimeGMT()+10*3600)<=TimeDay(DSTend)))
           {
            if(TimeHour(TimeGMT()+10*3600)>=8 && TimeHour(TimeGMT()+10*3600)<=16)
              {
               return 1;
              }
           }
         else
           {
            if(TimeHour(TimeGMT()+10*3600)>=9 && TimeHour(TimeGMT()+10*3600)<=17)
              {
               return 1;
              }
           }
        }
     }
   if(currency1=="JPY" || currency2=="JPY")
     {
      if(TimeGMT()>=D'00:00:00' && TimeGMT()<D'7:30:00')
        {
         return 1;
        }
     }
   if(currency1=="EUR" || currency2=="EUR")
     {
      static datetime DSTbegin=0,DSTend=0;
      if(TimeYear(TimeGMT())!=TimeYear(DSTbegin) || TimeYear(TimeGMT())!=TimeYear(DSTend))
        {
         DSTbegin=D'31.3 12:00:00';
         while(1)
           {
            if(TimeDayOfWeek(DSTbegin)==0)break;
            DSTbegin-=24*3600;
           }

         DSTend=D'31.10 01:00:00';
         while(1)
           {
            if(TimeDayOfWeek(DSTend)==0)break;
            DSTend-=24*3600;
           }
         DSTend-=24*3600;
        }
      if((TimeMonth(TimeGMT())>TimeMonth(DSTbegin) && TimeMonth(TimeGMT())<TimeMonth(DSTend)) || 
         (TimeMonth(TimeGMT())==TimeMonth(DSTbegin) && TimeDay(TimeGMT())>=TimeDay(DSTbegin))||
         (TimeMonth(TimeGMT())==TimeMonth(DSTend) && TimeDay(TimeGMT())<=TimeDay(DSTend)))
        {
         if((TimeHour(TimeGMT()+8*3600)>=15 && TimeHour(TimeGMT()+8*3600)<=22)||(TimeHour(TimeGMT()+8*3600)==14&&TimeMinute(TimeGMT()+8*3600)>=30))return 1;
        }
      else
        {
         if((TimeHour(TimeGMT()+8*3600)>=16 && TimeHour(TimeGMT()+8*3600)<=23)||(TimeHour(TimeGMT()+8*3600)==15&&TimeMinute(TimeGMT()+8*3600)>=30))return 1;
        }
     }
   if(currency1=="CHF" || currency2=="CHF")
     {
      static datetime DSTbegin=0,DSTend=0;
      if(TimeYear(TimeGMT()+3600)!=TimeYear(DSTbegin) || TimeYear(TimeGMT()+3600)!=TimeYear(DSTend))
        {
         DSTbegin=D'31.3 12:00:00';
         while(1)
           {
            if(TimeDayOfWeek(DSTbegin)==0)break;
            DSTbegin-=24*3600;
           }

         DSTend=D'31.10 01:00:00';
         while(1)
           {
            if(TimeDayOfWeek(DSTend)==0)break;
            DSTend-=24*3600;
           }
         DSTend-=24*3600;
        }
      if((TimeMonth(TimeGMT()+3600)>TimeMonth(DSTbegin) && TimeMonth(TimeGMT()+3600)<TimeMonth(DSTend)) || 
         (TimeMonth(TimeGMT()+3600)==TimeMonth(DSTbegin) && TimeDay(TimeGMT()+3600)>=TimeDay(DSTbegin))||
         (TimeMonth(TimeGMT()+3600)==TimeMonth(DSTend) && TimeDay(TimeGMT()+3600)<=TimeDay(DSTend)))
        {
         if((TimeHour(TimeGMT()+3600)>=9 && TimeHour(TimeGMT()+3600)<=15)||(TimeHour(TimeGMT()+3600)==8&&TimeMinute(TimeGMT()+3600)>=30))return 1;
        }
      else
        {
         if((TimeHour(TimeGMT()+3600)>=10 && TimeHour(TimeGMT()+3600)<=16)||(TimeHour(TimeGMT()+3600)==9&&TimeMinute(TimeGMT()+3600)>=30))return 1;
        }
     }
   if(currency1=="GBP" || currency2=="GBP")
     {
      static datetime DSTbegin=0,DSTend=0;
      if(TimeYear(TimeGMT())!=TimeYear(DSTbegin) || TimeYear(TimeGMT())!=TimeYear(DSTend))
        {
         DSTbegin=D'31.3 12:00:00';
         while(1)
           {
            if(TimeDayOfWeek(DSTbegin)==0)break;
            DSTbegin-=24*3600;
           }

         DSTend=D'31.10 01:00:00';
         while(1)
           {
            if(TimeDayOfWeek(DSTend)==0)break;
            DSTend-=24*3600;
           }
         DSTend-=24*3600;
        }
      if((TimeMonth(TimeGMT())>TimeMonth(DSTbegin) && TimeMonth(TimeGMT())<TimeMonth(DSTend)) || 
         (TimeMonth(TimeGMT())==TimeMonth(DSTbegin) && TimeDay(TimeGMT())>=TimeDay(DSTbegin))||
         (TimeMonth(TimeGMT())==TimeMonth(DSTend) && TimeDay(TimeGMT())<=TimeDay(DSTend)))
        {

         if((TimeHour(TimeGMT())>=8 && TimeHour(TimeGMT())<=15)||(TimeHour(TimeGMT())==7&&TimeMinute(TimeGMT())>=30)||(TimeHour(TimeGMT())==16&&TimeMinute(TimeGMT())<30))return 1;
        }
      else
        {
         if((TimeHour(TimeGMT())>=9 && TimeHour(TimeGMT())<=16)||(TimeHour(TimeGMT())==8&&TimeMinute(TimeGMT())>=30)||(TimeHour(TimeGMT())==17&&TimeMinute(TimeGMT())<30))return 1;
        }
     }
   if(currency1!="USD" && currency1!="CAD" && currency1!="NZD" && currency1!="AUD" && currency1!="CHF" && currency1!="EUR" && currency1!="JPY" && currency1!="GBP" &&
      currency2!="USD" && currency2!="CAD" && currency2!="NZD" && currency2!="AUD" && currency2!="CHF" && currency2!="EUR" && currency2!="JPY" && currency2!="GBP")
     {
      return 1;
     }
   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool movestoploss()//TRUE if successful or FALSE
  {
   for(uchar Li_4=0; Li_4<OrdersTotal(); Li_4++)
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
                     if(OrderClose(OrderTicket(),OrderLots(),Ask,500,clrRed))
                        return 0;
                 }
               else if(OrderType()==OP_BUY)
                 {
                  if(prevema>=prevsmma && ema<=smma)
                     if(OrderClose(OrderTicket(),OrderLots(),Bid,500,clrBlue))
                        return 0;
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
char bbvote()
  {
   if(bbvote==none)return ANY;
   double bb1;double bb2;
   if((bb1=iCustom(NULL,0,"::Indicators\\Downloads\\BBand Stop Alert.ex4",length1,2,1.0,1,1,1000,false,0,(onetick?1:0)))/*UpTrend Stop*/>0 &&
      (bb2=iCustom(NULL,0,"::Indicators\\Downloads\\BBand Stop Alert.ex4",length2,2,1.0,1,1,1000,false,0,(onetick?1:0)))/*UpTrend Stop*/>0)
     {
      if(bbvote==sameside)return BUY;
      if(bbvote==misplaced && bb2>=bb1)
         return BUY;
     }
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
char mavote()
  {
   if(mavote==unused)return ANY;
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
