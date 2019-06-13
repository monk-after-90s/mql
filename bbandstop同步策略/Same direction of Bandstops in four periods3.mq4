//+------------------------------------------------------------------+
//|                 Same direction of Bandstops in four periods3.mq4 |
//|                                                         Antasann |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Antasann"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#resource "\\Indicators\\Downloads\\BBand Stop Alert.ex4"
#resource "\\Indicators\\Custom Moving Averages.ex4"
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
   M30,
   H1,
   H4,
   D1,
   any,
   last
  };
input string instructions1="For the basic feature";//Basic parameters
input bbandstops trailstop=bbandstop_20_2;         //Which bbandstop to select to trail stop
sinput datetime time=0;                            //Local time to start the EA
input float lots=0.1;                              //Initial lots
sinput uint magic=23441;                           //magic number

input string instructions2="For the alternative functions";//Alternative parameters
input bool tennotin20=FALSE;          //Trade only if bbandstop(10,2) is not inside bbandstop(20,2) in the last period
input periods bbtrend=none;           //Which period in which the bbandstop trendstop trends is applied to judge trends
input bbandstops lastline=both;       //The last bbandstop which meets the same trend
extern periods lastperiod=any;        //The last period which meets the same trend
input periods macross=none;           //Which period the moving average crosses of which is applied to judge trends
input periods matrend=none;           //Which period the moving average trends of which is applied to judge trends
bbandstops lastupbbs;periods lastupchart;bbandstops lastdownbbs;periods lastdownchart;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   if(_Period==PERIOD_M30 || _Period==PERIOD_H1 || _Period==PERIOD_H4 || _Period==PERIOD_D1);
   else
     {
      Alert("Please attach the EA in period M30,H1,H4 or D1");
      ExpertRemove();
     }
   if(lastperiod==none)lastperiod=any;

   if(trailstop==both)
     {
      Alert("Which one bbandstop to select to trail stop?Not both.");
      ExpertRemove();
     }
   if(time>TimeLocal())
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

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool same8(bool&trend,bbandstops&line,periods&timeframe)//0-buy 1-sell
  {
  // bool same=0;
   short upnumber=0;
   if(iCustom(NULL,PERIOD_M30,"::Indicators\\Downloads\\BBand Stop Alert.ex4",10,2,1.0,1,1,1000,true,0,0)>0)
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
   if(iCustom(NULL,PERIOD_M30,"::Indicators\\Downloads\\BBand Stop Alert.ex4",20,2,1.0,1,1,1000,true,0,0)>0)
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
   if(iCustom(NULL,PERIOD_H1,"::Indicators\\Downloads\\BBand Stop Alert.ex4",10,2,1.0,1,1,1000,true,0,0)>0)
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
   if(iCustom(NULL,PERIOD_H1,"::Indicators\\Downloads\\BBand Stop Alert.ex4",20,2,1.0,1,1,1000,true,0,0)>0)
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
   if(iCustom(NULL,PERIOD_H4,"::Indicators\\Downloads\\BBand Stop Alert.ex4",10,2,1.0,1,1,1000,true,0,0)>0)
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
   if(iCustom(NULL,PERIOD_H4,"::Indicators\\Downloads\\BBand Stop Alert.ex4",20,2,1.0,1,1,1000,true,0,0)>0)
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
   if(iCustom(NULL,PERIOD_D1,"::Indicators\\Downloads\\BBand Stop Alert.ex4",10,2,1.0,1,1,1000,true,0,0)>0)
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
   if(iCustom(NULL,PERIOD_D1,"::Indicators\\Downloads\\BBand Stop Alert.ex4",20,2,1.0,1,1,1000,true,0,0)>0)
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

  }
//+------------------------------------------------------------------+
