//+------------------------------------------------------------------+
//|                                           Draw line to trade.mq4 |
//|                                                         Antasann |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Antasann"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property description "Draw trend line only please!"
#property description "Only one trade for one chart!"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum direction
  {
   buy,
   sell
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum active_style
  {
   alert,//alert only
   operate_order,//operate an order
   alert_and_operate_order//both
  };
input active_style EA_function=0;//EA function
input string open_line_name="trade line";//Line name for opening an order
input double lots=0.1;//Order lots
input direction operation;//Market order type
                          //input string comment="0";//Deal the order only with this comment
int magic=9843;//Order magic number
bool refresh=1;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class lines
  {
private:
   string            line_name;
   bool              initial_line_position;
public:
   string get_name()
     {
      return line_name;
     }
   void set_name(string name)
     {
      line_name=name;
      if(name!=NULL)initial_line_position=get_position();
     }
   bool get_position()
     {
      return line_position(line_name,(line_name==open_line_name)?(operation?Bid:Ask):(operation?Ask:Bid));
     }
   void set_initial_line_position(bool position)
     {
      initial_line_position=position;
     }
   bool get_initial_position()
     {
      return initial_line_position;
     }
public:
                     lines(){line_name=NULL;}
                    ~lines(void)
     {
      line_name=NULL;
     }
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   ChartSetInteger(0,CHART_EVENT_OBJECT_CREATE,1);
   ChartSetInteger(0,CHART_EVENT_OBJECT_DELETE,1);
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
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   if((id==CHARTEVENT_OBJECT_DRAG && ObjectType(sparam)==OBJ_TREND) || 
      id==CHARTEVENT_OBJECT_DELETE || 
      (id==CHARTEVENT_OBJECT_CREATE && ObjectType(sparam)==OBJ_TREND) ||
      (id==CHARTEVENT_OBJECT_CHANGE&&ObjectType(sparam)==OBJ_TREND))
     {
      Print("Object event");
      refresh=1;
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   static lines trend_lines[];

   if(refresh)
     {
      Print("refresh=",refresh);
      refresh=0;
      for(int i=0;i<ArraySize(trend_lines);i++)
        {
         trend_lines[i].set_name(NULL);
        }
      int j=0;
      for(int i=0;i<ObjectsTotal();i++)
        {
         if(ObjectType(ObjectName(i))==OBJ_TREND)
           {
            //trend_lines[j].set_name(ObjectName(i));
            //trend_lines[j].set_initial_line_position(trend_lines[j].get_position());
            j++;
           }
        }
      ArrayResize(trend_lines,j,6);
      int k=0;
      for(int i=0;i<ObjectsTotal();i++)
        {
         if(ObjectType(ObjectName(i))==OBJ_TREND)
           {
            trend_lines[k].set_name(ObjectName(i));
            k++;
           }
        }
     }
   for(int i=0;i<ArraySize(trend_lines);i++)
     {
      if(trend_lines[i].get_position()!=trend_lines[i].get_initial_position())//touch open order line
        {
         trend_lines[i].set_initial_line_position(trend_lines[i].get_position());
         //Print("Position=",trend_lines[i].get_position()," initial position=",trend_lines[i].get_initial_position());
         if(trend_lines[i].get_name()==open_line_name)
           {
            bool order_exist=0;
            for(int j=0;j<OrdersTotal();j++)
              {
               if(OrderSelect(j,SELECT_BY_POS) && OrderSymbol()==Symbol() && OrderMagicNumber()==magic && OrderComment()==(string)ChartID())
                  order_exist=1;
              }
            if(!order_exist)
              {
               if(EA_function==operate_order || EA_function==alert_and_operate_order)
                  while(0>OrderSend(NULL,operation,lots,operation?Bid:Ask,30,0,0,(string)ChartID(),magic,0,operation?Red:Green))
                     RefreshRates();
               if(EA_function==alert_and_operate_order || EA_function==alert)
                 {
                  Alert("Order open!");
                  SendNotification("Order open");
                  Sleep(250);
                  Alert("Order open!");
                  SendNotification("Order open");
                  Sleep(250);
                  Alert("Order open!");
                  SendNotification("Order open");
                 }
              }
           }
         else
           {
            if(EA_function==operate_order || EA_function==alert_and_operate_order)
               for(int j=0;j<OrdersTotal();j++)
                 {
                  if(OrderSelect(j,SELECT_BY_POS) && OrderSymbol()==Symbol() && OrderMagicNumber()==magic && OrderComment()==(string)ChartID())
                     OrderClose(OrderTicket(),OrderLots(),OrderType()?Ask:Bid,30,OrderType()?Red:Green);
                 }
            if(EA_function==alert_and_operate_order || EA_function==alert)
              {
               Alert("Order close!");
               SendNotification("Order close");
               Sleep(250);
               Alert("Order close!");
               SendNotification("Order close");
               Sleep(250);
               Alert("Order close!");
               SendNotification("Order close");
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool line_position(string line_name,double price)
  {
   if(price>ObjectGetValueByTime(0,line_name,Time[0],0))
      return 0;
   else return 1;
  }
//+------------------------------------------------------------------+
