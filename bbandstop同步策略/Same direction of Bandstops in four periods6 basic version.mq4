//+------------------------------------------------------------------+
//|                 Same direction of Bandstops in four periods.mq4 |
//|                                                         Antasann |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Antasann"
#property link      "https://www.mql5.com"
#property version   "6.00"
#property strict
#resource "\\Indicators\\Downloads\\BBand Stop Alert.ex4"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum bbandstops
  {
   bbandstop_10_2=10,//bbandstop(10,2)
   bbandstop_20_2=20,//bbandstop(20,2) 
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double bbvalue(periods frame,bool trend,char length)
  {
   double value;
   do
     {
      value=iCustom(NULL,frame,"::Indicators\\Downloads\\BBand Stop Alert.ex4",length,2,1.0,1,1,1000,true,trend,0);
     }
   while(GetLastError() && !IsStopped());
   return value;
  }
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
   if(time<=TimeLocal() && time!=0)
     {
      Alert("Set a local time later than present!");
      ExpertRemove();
     }
   if(trailstop==both)
     {
      Alert("\"Which bbandstop to select to trail stop\"can't be set as \"both\"");
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
   if(time>TimeLocal())return;
   bool trend;bbandstops last_line;periods last_timeframe;
   if(trailstopvote() && same8(trend,last_line,last_timeframe))
      if(0<OrderSend(NULL,
         trend?OP_SELL:OP_BUY,
         lots,
         trend?Bid:Ask,
         500,
         0,0,NULL,magic))
         Print("A ",trend?"sell":"buy"," order is opened.");

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
            double bb=NormalizeDouble(bbvalue(M30,(OrderType()==OP_BUY)?0:1,trailstop)
                                      ,Digits);
            //Print("OrderStopLoss()=",OrderStopLoss()," bb=",bb);
            if(OrderStopLoss()!=bb && bb>0)
              {
               OrderModify(OrderTicket(),OrderOpenPrice(),bb,OrderTakeProfit(),0);
              }
/*
            if(trailstop==bbandstop_20_2)//set stoploss   
              {
               if(OrderType()==OP_BUY)
                  OrderModify(OrderTicket(),OrderOpenPrice(),bbvalue(M30,0,20)//iCustom(NULL,PERIOD_M30,"::Indicators\\Downloads\\BBand Stop Alert.ex4",20,2,1.0,1,1,1000,true,0,0)
                              ,0,0);
               else if(OrderType()==OP_SELL)
                  OrderModify(OrderTicket(),OrderOpenPrice(),bbvalue(M30,1,20)//iCustom(NULL,PERIOD_M30,"::Indicators\\Downloads\\BBand Stop Alert.ex4",20,2,1.0,1,1,1000,true,1,0)
                              ,0,0);
              }
            else if(trailstop==bbandstop_10_2)
              {
               if(OrderType()==OP_BUY)
                  OrderModify(OrderTicket(),OrderOpenPrice(),bbvalue(M30,0,10)//iCustom(NULL,PERIOD_M30,"::Indicators\\Downloads\\BBand Stop Alert.ex4",10,2,1.0,1,1,1000,true,0,0)
                              ,0,0);
               else if(OrderType()==OP_SELL)
                  OrderModify(OrderTicket(),OrderOpenPrice(),bbvalue(M30,1,10)//iCustom(NULL,PERIOD_M30,"::Indicators\\Downloads\\BBand Stop Alert.ex4",10,2,1.0,1,1,1000,true,1,0)
                              ,0,0);
              }*/
            return 0;
           }
     }
   return 1;
  }
//+------------------------------------------------------------------+
bool same8(bool&trend,bbandstops&line,periods&timeframe)//0-buy 1-sell
  {
   static bbandstops lastupbbs;static periods lastupchart;static bbandstops lastdownbbs;static periods lastdownchart;
   short upnumber=0;
   if(bbvalue(M30,0,10)>0)
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
   if(bbvalue(M30,0,20)>0)
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
   if(bbvalue(H1,0,10)>0)
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
   if(bbvalue(H1,0,20)>0)
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
   if(bbvalue(H4,0,10)>0)
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
   if(bbvalue(H4,0,20)>0)
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
   if(bbvalue(D1,0,10)>0)
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
   if(bbvalue(D1,0,20)>0)
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
//Print("upnumber=",upnumber,"\n\r,lastupchart=",EnumToString(lastupchart),",lastupbbs=",EnumToString(lastupbbs),"\n\r,lastdownbbs=",EnumToString(lastdownbbs),",lastdownchart=",EnumToString(lastdownchart));

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
