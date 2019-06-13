//+------------------------------------------------------------------+
//|                bband crosses and average leaves previous bar.mq4 |
//|                                                         Antasann |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Antasann"
#property link      "https://www.mql5.com"
#property version   ""
#property strict
#resource "\\Indicators\\Downloads\\BBand Stop Alert.ex4"
#define BUY 0;
#define SELL 1;
#define NONE 2;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum stoploss
  {
   length_1,                  //Narrow bbandstop
   length_2,                  //Wide bbandstop
   ma                         //Moving average touch a bar
  };

input int length1=10;         //Smaller length of bbandstops
input int length2=35;         //Bigger length of bbandstops
input bool misplace=TRUE;     //Bbandstops must misplaces
input int period=55;          //Moving average period
input ENUM_MA_METHOD method=MODE_LWMA;//Moving average method
input char num=1;             //The maximum continuous pairs of bbandstops to be used
input bool barprice=1;        //Highest/Lowest value if true otherwise open/close value must all leave the ma line
sinput uint magic=4534;       //Magic number
input bool onetick=FALSE;     //Judge only once every bar
extern double lots=0.1;       //Order lots
input float multiplier=1.0;   //Multiplier which Martin strategy uses
input float maxlots=10;       //Allowed maximum lots in Martin strategy

input bool markettime=1;     //Trade only when the market is open
input stoploss stop=length_1; //Way to move stoploss
int ticket;
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
   correctlots();
   char bbvote=bbvote(),barleavemavote=barleavemavote();
   if(0==bbvote && barleavemavote==0)
     {
      if((ticket=OrderSend(NULL,OP_BUY,lots,Ask,50,
         stop==length_1?iCustom(NULL,0,"::Indicators\\Downloads\\BBand Stop Alert.ex4",length1,2,1.0,1,1,1000,false,0,onetick):(stop==length_2?iCustom(NULL,0,"::Indicators\\Downloads\\BBand Stop Alert.ex4",length2,2,1.0,1,1,1000,false,0,onetick):0)
         ,
         0,"",magic))<0)Alert("Fail to open a buy order");
     }
   else if(1==bbvote && barleavemavote==1)
     {
      if((ticket=OrderSend(NULL,OP_SELL,lots,Bid,50,
         stop==length_1?iCustom(NULL,0,"::Indicators\\Downloads\\BBand Stop Alert.ex4",length1,2,1.0,1,1,1000,false,1,onetick):(stop==length_2?iCustom(NULL,0,"::Indicators\\Downloads\\BBand Stop Alert.ex4",length2,2,1.0,1,1,1000,false,1,onetick):0)
         ,
         0,"",magic))<0)Alert("Fail to open a sell order");
     }
  }
//+------------------------------------------------------------------+
char barleavemavote()
  {
   if(barprice)
     {
      if(High[1]<iMA(NULL,0,period,0,method,0,1) && High[0]<iMA(NULL,0,period,0,method,0,0))
        {
         return SELL;
        }
      else if(Low[1]>iMA(NULL,0,period,0,method,0,1) && Low[0]>iMA(NULL,0,period,0,method,0,0))
        {
         return BUY;
        }
     }
   else
     {
      if(Open[1]<iMA(NULL,0,period,0,method,0,1) && Close[1]<iMA(NULL,0,period,0,method,0,1) && Open[0]<iMA(NULL,0,period,0,method,0,0) && Close[0]<iMA(NULL,0,period,0,method,0,0))
        {
         return SELL;
        }
      else if(Open[1]>iMA(NULL,0,period,0,method,0,1) && Close[1]>iMA(NULL,0,period,0,method,0,1) && Open[0]>iMA(NULL,0,period,0,method,0,0) && Close[0]>iMA(NULL,0,period,0,method,0,0))
        {
         return BUY;
        }
     }
   return NONE;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool movestoploss()
  {
   if(OrderSelect(ticket,SELECT_BY_TICKET))
     {
      if(OrderCloseTime())return 0;
      if(stop!=ma)
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
      else
        {
         if(OrderType()==OP_BUY)
           {
            if(Bid<iMA(NULL,0,period,0,method,0,0) && OrderClose(ticket,OrderLots(),Bid,500))return 0;
           }
         if(OrderType()==OP_SELL)
           {
            if(Ask>iMA(NULL,0,period,0,method,0,0) && OrderClose(ticket,OrderLots(),Ask,500))return 0;
           }
        }
      return 1;
     }
   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void correctlots()
  {
   if(multiplier==1.0)return;
   const static double initial=lots;double losslots;
   if(!lastorderbenefit(losslots))
     {
      if((lots=multiplier*losslots)<=maxlots);
      else lots=initial;
     }
   else lots=initial;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool lastorderbenefit(double&losslots)//return 1 if the newest closed buy or sell order of the current symbol opened by the EA do not lose profit,otherwise 0
  {
   for(int Li_0=OrdersHistoryTotal()-1; Li_0>=0; Li_0--)
     {
      if(OrderSelect(Li_0,SELECT_BY_POS,MODE_HISTORY))
        {
         if(OrderType()<2 && OrderSymbol()==Symbol() && OrderMagicNumber()==magic)
           {
            if(OrderProfit()>=0.0)
               return 1;
            else
              {
               losslots=OrderLots();
               return 0;
              }
           }
        }
     }
   return 1;
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
char bbvote()
  {

   double bb1=iCustom(NULL,0,"::Indicators\\Downloads\\BBand Stop Alert.ex4",length1,2,1.0,1,1,1000,false,0,onetick);/*UpTrend Stop*/
   double bb2=iCustom(NULL,0,"::Indicators\\Downloads\\BBand Stop Alert.ex4",length2,2,1.0,1,1,1000,false,0,onetick);/*UpTrend Stop*/
   if(misplace?(bb1>0 && bb2>=bb1):(bb1>0 && bb2>0))
     {
      char count=1;
      for(char i=onetick+1;;i++)
        {
         bb1=iCustom(NULL,0,"::Indicators\\Downloads\\BBand Stop Alert.ex4",length1,2,1.0,1,1,1000,false,0,i);
         bb2=iCustom(NULL,0,"::Indicators\\Downloads\\BBand Stop Alert.ex4",length2,2,1.0,1,1,1000,false,0,i);
         if(misplace?(bb1>0 && bb2>=bb1):(bb1>0 && bb2>0))count++;
         else if(bb1<0 || bb2<0)break;
         else return NONE;
        }
      if(count<=num)
        {
         return BUY;
        }
     }
   bb1=iCustom(NULL,0,"::Indicators\\Downloads\\BBand Stop Alert.ex4",length1,2,1.0,1,1,1000,false,1,onetick);
   bb2=iCustom(NULL,0,"::Indicators\\Downloads\\BBand Stop Alert.ex4",length2,2,1.0,1,1,1000,false,1,onetick);
   if(misplace?(bb2>0 && bb2<=bb1):(bb1>0 && bb2>0))
     {
      char count=1;
      for(char i=onetick+1;;i++)
        {
         bb1=iCustom(NULL,0,"::Indicators\\Downloads\\BBand Stop Alert.ex4",length1,2,1.0,1,1,1000,false,1,i);
         bb2=iCustom(NULL,0,"::Indicators\\Downloads\\BBand Stop Alert.ex4",length2,2,1.0,1,1,1000,false,1,i);
         if(misplace?(bb2>0 && bb2<=bb1):(bb1>0 && bb2>0))count++;
         else if(bb1<0 || bb2<0)break;
         else return NONE;
        }
      if(count<=num)
        {
         return SELL;
        }
     }
   return NONE;
  }
//+------------------------------------------------------------------+
