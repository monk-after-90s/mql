//+------------------------------------------------------------------+
//|                 Same direction of Bandstops in four periods5.mq4 |
//|                                                         Antasann |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Antasann"
#property link      "https://www.mql5.com"
#property version   "5.00"
#property strict
#resource "\\Indicators\\Downloads\\BBand Stop Alert.ex4"
#resource "\\Indicators\\Custom Moving Averages.ex4"

#define uptrendstop_M30_10 iCustom(NULL,PERIOD_M30,"::Indicators\\Downloads\\BBand Stop Alert.ex4",10,2,1.0,1,1,1000,true,0,0)
#define uptrendstop_M30_20 iCustom(NULL,PERIOD_M30,"::Indicators\\Downloads\\BBand Stop Alert.ex4",20,2,1.0,1,1,1000,true,0,0)
#define uptrendstop_H1_10 iCustom(NULL,PERIOD_H1,"::Indicators\\Downloads\\BBand Stop Alert.ex4",10,2,1.0,1,1,1000,true,0,0)
#define uptrendstop_H1_20 iCustom(NULL,PERIOD_H1,"::Indicators\\Downloads\\BBand Stop Alert.ex4",20,2,1.0,1,1,1000,true,0,0)
#define uptrendstop_H4_10 iCustom(NULL,PERIOD_H4,"::Indicators\\Downloads\\BBand Stop Alert.ex4",10,2,1.0,1,1,1000,true,0,0)
#define uptrendstop_H4_20 iCustom(NULL,PERIOD_H4,"::Indicators\\Downloads\\BBand Stop Alert.ex4",20,2,1.0,1,1,1000,true,0,0)
#define uptrendstop_D1_10 iCustom(NULL,PERIOD_D1,"::Indicators\\Downloads\\BBand Stop Alert.ex4",10,2,1.0,1,1,1000,true,0,0)
#define uptrendstop_D1_20 iCustom(NULL,PERIOD_D1,"::Indicators\\Downloads\\BBand Stop Alert.ex4",20,2,1.0,1,1,1000,true,0,0)
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum bbandstops
  {
   bbandstop_10_2,//bbandstop(10,2)
   bbandstop_20_2,//bbandstop(20,2) 
   both
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum periods
  {
   none,
   M30=30,
   H1=60,
   H4=240,
   D1=1440,
   any,
   last
  };
input string instructions1="For the basic feature";//Basic parameters
input bbandstops trailstop=bbandstop_20_2;         //Which bbandstop to select to trail stop
sinput datetime time=0;                            //Local time to start the EA
input float lots=0.1;                              //Initial lots
sinput uint magic=23441;                           //magic number

input string instructions2="For the alternative functions";//Alternative parameters
input bool tennotin20=FALSE;          //Trade only if bbandstop(10,2) is not inside bbandstop(20,2) in the last changed period
input periods bbtrend=none;           //Which period in which the bbandstop trendstop trends is applied to judge trends
input bbandstops lastline=both;       //The last bbandstop which meets the same trend
extern periods lastperiod=any;        //The last period which meets the same trend
input periods macross=none;           //Which period the moving average crosses of which is applied to judge trends
input periods matrend=none;           //Which period the moving average trends of which is applied to judge trends
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   if(_Period==PERIOD_M30 || _Period==PERIOD_H1 || _Period==PERIOD_H4 || _Period==PERIOD_D1);
   else
     {
      Alert("Please watch the EA in period M30,H1,H4 or D1");
     }
   if((ulong)time>(ulong)TimeLocal())
     {
      Sleep(1000*((ulong)time-(ulong)TimeLocal()));
     }
   else if(time<=TimeLocal() && time!=0)
     {
      Alert("Set a local time later than present!");
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
   bool trend;bbandstops line;periods timeframe;
   if(1)
     {
      if(same8(trend,line,timeframe))
        {
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool matrendvote(bool trend,periods last_period)
  {
   if(matrend==none)return 1;
   else if(matrend==any)
     {
      Alert("\"Which period the moving average trends of which is applied to judge trends\"can't be set as \"any\"");
      ExpertRemove();
      return 0;
     }
   else
     {
      periods period;
      if(matrend==last)period=last_period;
      else period=matrend;
      double ema[2],smma[2];
      do
        {
         ema[0]=iMA(NULL,period,20,0,MODE_EMA,PRICE_CLOSE,0);
         ema[1]=iMA(NULL,period,20,0,MODE_EMA,PRICE_CLOSE,1);
         smma[0]=iMA(NULL,period,20,0,MODE_SMMA,PRICE_CLOSE,0);
         smma[1]=iMA(NULL,period,20,0,MODE_SMMA,PRICE_CLOSE,1);
        }
      while(_LastError && !IsStopped());
      if(trend==0)
        {
         if(ema[0]>ema[1]&&smma[0]>smma[1])return 1;
        }
      else
        {
         if(ema[0]<ema[1]&&smma[0]<smma[1])return 1;
        }
      return 0;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool macrossvote(bool trend,periods last_period)
  {
   if(macross==none)return 1;
   else if(macross==any)
     {
      Alert("\"Which period the moving average crosses of which is applied to judge trends\"can't be set as \"any\"");
      ExpertRemove();
      return 0;
     }
   else
     {
      periods period;
      if(macross==last)period=last_period;
      else period=macross;
      double ema,smma;
      do
        {
         ema=iMA(NULL,period,20,0,MODE_EMA,PRICE_CLOSE,0);
         smma=iMA(NULL,period,20,0,MODE_SMMA,PRICE_CLOSE,0);
        }
      while(_LastError && !IsStopped());
      if(trend==0)
        {
         if(ema>=smma)return 1;
        }
      else
        {
         if(ema<=smma)return 1;
        }
      return 0;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool lastperiodvote(periods last_period)
  {
   if(lastperiod==any)return 1;
   else if(lastperiod==last || lastperiod==none)
     {
      Alert("\"The last period which meets the same trend\"can't be set as\"last\"or\"none\"");
      ExpertRemove();
      return 0;
     }
   else if(lastperiod==last_period)return 1;
   else return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool lastlinevote(bbandstops last_line)
  {
   if(lastline==both)return TRUE;
   else
     {
      if(lastline==last_line)
         return 1;
      else return 0;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool bbtrendvote(bool trend,periods last_period)
  {
   if(bbtrend==none)return true;
   else if(bbtrend==any)
     {
      Alert("\"Which period in which the bbandstop trendstop trends is applied to judge trends\"can't be set as \"any\"");
      ExpertRemove();
      return FALSE;
     }
   else
     {
      periods period;
      if(bbtrend==last)
        {
         period=last_period;
        }
      else
        {
         period=bbtrend;
        }
      if(trend==0)//uptrend
        {
         double bb[2][2];
         do
           {
            bb[0][0]=iCustom(NULL,period,"::Indicators\\Downloads\\BBand Stop Alert.ex4",10,2,1.0,1,1,1000,true,0,0);
            bb[0][1]=iCustom(NULL,period,"::Indicators\\Downloads\\BBand Stop Alert.ex4",10,2,1.0,1,1,1000,true,0,1);
            bb[1][0]=iCustom(NULL,period,"::Indicators\\Downloads\\BBand Stop Alert.ex4",20,2,1.0,1,1,1000,true,0,0);
            bb[1][1]=iCustom(NULL,period,"::Indicators\\Downloads\\BBand Stop Alert.ex4",20,2,1.0,1,1,1000,true,0,1);
           }
         while(_LastError && !IsStopped());
         if(bb[0][0]>bb[0][1] || bb[1][0]>bb[1][1])return true;

         else return FALSE;
        }
      else//downtrend
        {
         double bb[2][2];
         do
           {
            bb[0][0]=iCustom(NULL,period,"::Indicators\\Downloads\\BBand Stop Alert.ex4",10,2,1.0,1,1,1000,true,1,0);
            bb[0][1]=iCustom(NULL,period,"::Indicators\\Downloads\\BBand Stop Alert.ex4",10,2,1.0,1,1,1000,true,1,1);
            bb[1][0]=iCustom(NULL,period,"::Indicators\\Downloads\\BBand Stop Alert.ex4",20,2,1.0,1,1,1000,true,1,0);
            bb[1][1]=iCustom(NULL,period,"::Indicators\\Downloads\\BBand Stop Alert.ex4",20,2,1.0,1,1,1000,true,1,1);
           }
         while(_LastError && !IsStopped());
         if(bb[0][0]<bb[0][1]||bb[1][0]<bb[1][1])return true;
         else return FALSE;
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool tennotin20vote(periods timeframe)
  {
   if(tennotin20==FALSE)return true;
   else
     {
      double up_10,up_20,down_10,down_20;
      do
        {
         up_10=iCustom(NULL,timeframe,"::Indicators\\Downloads\\BBand Stop Alert.ex4",10,2,1.0,1,1,1000,true,0,0);
         up_20=iCustom(NULL,timeframe,"::Indicators\\Downloads\\BBand Stop Alert.ex4",20,2,1.0,1,1,1000,true,0,0);
         down_10=iCustom(NULL,timeframe,"::Indicators\\Downloads\\BBand Stop Alert.ex4",10,2,1.0,1,1,1000,true,1,0);
         down_20=iCustom(NULL,timeframe,"::Indicators\\Downloads\\BBand Stop Alert.ex4",20,2,1.0,1,1,1000,true,1,0);
        }
      while(_LastError && !IsStopped());
      if((up_10>0 && up_20>0 && up_10<=up_20) || (down_10>0 && down_20>0 && down_10>=down_20))return true;
      else return FALSE;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool trailstopvote()
  {
   for(uchar Li_4=0; Li_4<OrdersTotal(); Li_4++)
     {
      if(OrderSelect(Li_4,SELECT_BY_POS,MODE_TRADES))
         if(OrderSymbol()==Symbol() && OrderMagicNumber()==magic)
           {
            if(trailstop==bbandstop_20_2)//set stoploss   
              {
               do
                 {
                  if(OrderType()==OP_BUY)
                     OrderModify(OrderTicket(),OrderOpenPrice(),
                                 iCustom(NULL,PERIOD_M30,"::Indicators\\Downloads\\BBand Stop Alert.ex4",20,2,1.0,1,1,1000,true,0,0),
                                 0,0);
                  else if(OrderType()==OP_SELL)
                     OrderModify(OrderTicket(),OrderOpenPrice(),
                                 iCustom(NULL,PERIOD_M30,"::Indicators\\Downloads\\BBand Stop Alert.ex4",20,2,1.0,1,1,1000,true,1,0),
                                 0,0);
                 }
               while(_LastError && !IsStopped());
              }
            else if(trailstop==bbandstop_10_2)
              {
               do
                 {
                  if(OrderType()==OP_BUY)
                     OrderModify(OrderTicket(),OrderOpenPrice(),
                                 iCustom(NULL,PERIOD_M30,"::Indicators\\Downloads\\BBand Stop Alert.ex4",10,2,1.0,1,1,1000,true,0,0),
                                 0,0);
                  else if(OrderType()==OP_SELL)
                     OrderModify(OrderTicket(),OrderOpenPrice(),
                                 iCustom(NULL,PERIOD_M30,"::Indicators\\Downloads\\BBand Stop Alert.ex4",10,2,1.0,1,1,1000,true,1,0),
                                 0,0);
                 }
               while(_LastError && !IsStopped());
              }
            return 0;
           }
     }
   return 1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool same8(bool&trend,bbandstops&line,periods&timeframe)//0-buy 1-sell
  {
   static bbandstops lastupbbs;static periods lastupchart;static bbandstops lastdownbbs;static periods lastdownchart;
   double bb[4][2];
   do
     {
      bb[0][0]=uptrendstop_M30_10;
     }
   while(_LastError && !IsStopped());
   do
     {
      bb[0][1]=uptrendstop_M30_20;
     }
   while(_LastError && !IsStopped());
   do
     {
      bb[1][0]=uptrendstop_H1_10;
     }
   while(_LastError && !IsStopped());
   do
     {
      bb[1][1]=uptrendstop_H1_20;
     }
   while(_LastError && !IsStopped());
   do
     {
      bb[2][0]=uptrendstop_H4_10;
     }
   while(_LastError && !IsStopped());
   do
     {
      bb[2][1]=uptrendstop_H4_20;
     }
   while(_LastError && !IsStopped());
   do
     {
      bb[3][0]=uptrendstop_D1_10;
     }
   while(_LastError && !IsStopped());
   do
     {
      bb[3][1]=uptrendstop_D1_20;
     }
   while(_LastError && !IsStopped());
   short upnumber=0;
   if(bb[0][0]>0)
     {
      upnumber++;
      lastupbbs=bbandstop_10_2;
      lastupchart=M30;
     }
   else
     {
      lastdownbbs=bbandstop_10_2;
      lastdownchart=M30;
     }
   if(bb[0][1]>0)
     {
      upnumber++;
      lastupbbs=bbandstop_20_2;
      lastupchart=M30;
     }
   else
     {
      lastdownbbs=bbandstop_20_2;
      lastdownchart=M30;
     }
   if(bb[1][0]>0)
     {
      upnumber++;
      lastupbbs=bbandstop_10_2;
      lastupchart=H1;
     }
   else
     {
      lastdownbbs=bbandstop_10_2;
      lastdownchart=H1;
     }
   if(bb[1][1]>0)
     {
      upnumber++;
      lastupbbs=bbandstop_20_2;
      lastupchart=H1;
     }
   else
     {
      lastdownbbs=bbandstop_20_2;
      lastdownchart=H1;
     }
   if(bb[2][0]>0)
     {
      upnumber++;
      lastupbbs=bbandstop_10_2;
      lastupchart=H4;
     }
   else
     {
      lastdownbbs=bbandstop_10_2;
      lastdownchart=H4;
     }
   if(bb[2][1]>0)
     {
      upnumber++;
      lastupbbs=bbandstop_20_2;
      lastupchart=H4;
     }
   else
     {
      lastdownbbs=bbandstop_20_2;
      lastdownchart=H4;
     }
   if(bb[3][0]>0)
     {
      upnumber++;
      lastupbbs=bbandstop_10_2;
      lastupchart=D1;
     }
   else
     {
      lastdownbbs=bbandstop_10_2;
      lastdownchart=D1;
     }
   if(bb[3][1]>0)
     {
      upnumber++;
      lastupbbs=bbandstop_20_2;
      lastupchart=D1;
     }
   else
     {
      lastdownbbs=bbandstop_20_2;
      lastdownchart=D1;
     }
/*Print("upnumber=",upnumber,"\n\r,lastupchart=",EnumToString(lastupchart),",lastupbbs=",EnumToString(lastupbbs),
         "\n\r,lastdownbbs=",EnumToString(lastdownbbs),",lastdownchart=",EnumToString(lastdownchart));
*/
   bool same=0;
   if(upnumber==8)
     {
      same=1;
      trend=0;
      line=lastdownbbs;
      timeframe=lastdownchart;
     }
   else if(upnumber==0)
     {
      same=1;
      trend=1;
      line=lastupbbs;
      timeframe=lastupchart;
     }
   return same;
  }
//+------------------------------------------------------------------+
