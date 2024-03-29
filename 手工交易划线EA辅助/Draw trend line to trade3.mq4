//+------------------------------------------------------------------+
//|                                           Draw line to trade.mq4 |
//|                                                         Antasann |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Antasann"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property description "本EA只能感知趋势线!"
#property description "一个图表最多只能做一个单!"
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
   alert,//只报警
   operate_order,//开平仓
   alert_and_operate_order//兼而有之
  };
input active_style EA_function=0;//EA功能
input string open_line_name="开仓线";//将用于开仓的趋势线的名字改为这个，其余趋势线用于平仓
input double lots=0.1;//单量
input direction operation;//开仓方向
                          //input string comment="0";//Deal the order only with this comment
int magic=9843;//Order magic number
bool refresh;
//bool object_event=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class lines
  {
private:
   int               serial_number;
   bool              initial_line_position;
public:
   int get_number()
     {
      return serial_number;
     }
   void set_serial_number(int number)
     {
      serial_number=number;
      if(number>=0)initial_line_position=get_position();
      if(ObjectName(number)==open_line_name)ObjectSet(open_line_name,OBJPROP_COLOR,(color)Green);
      else ObjectSet(ObjectName(number),OBJPROP_COLOR,(color)Red);
     }
   string get_name()
     {
      return ObjectName(serial_number);
     }
   bool get_position()
     {
      return line_position(serial_number,(ObjectName(serial_number)==open_line_name)?(operation?Bid:Ask):(operation?Ask:Bid));
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
                     lines(){}
                    ~lines(void){}
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   refresh=1;
//Print("refresh=",refresh);
   ChartSetInteger(0,CHART_EVENT_OBJECT_CREATE,1);
   ChartSetInteger(0,CHART_EVENT_OBJECT_DELETE,1);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   if((id==CHARTEVENT_OBJECT_DRAG && ObjectType(sparam)==OBJ_TREND && StringSubstr(sparam,0,1)!="#") || 
      id==CHARTEVENT_OBJECT_DELETE || 
      (id==CHARTEVENT_OBJECT_CREATE && ObjectType(sparam)==OBJ_TREND&&StringSubstr(sparam,0,1)!="#") ||
      (id==CHARTEVENT_OBJECT_CHANGE&&ObjectType(sparam)==OBJ_TREND&&StringSubstr(sparam,0,1)!="#")/*||
      (id==CHARTEVENT_OBJECT_CLICK && ObjectType(sparam)==OBJ_TREND&&StringSubstr(sparam,0,1)!="#")*/)
     {
      //object_event=1;
      //Print(object_event);

      //Print("Object event:",id);
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
      //Print("refresh=",refresh);
      refresh=0;
      ArrayFree(trend_lines);
/*for(int i=0;i<ArraySize(trend_lines);i++)
        {
         trend_lines[i].set_serial_number(NULL);
        }*/
      int j=0;
      for(int i=0;i<ObjectsTotal();i++)
        {
         if(ObjectType(ObjectName(i))==OBJ_TREND && StringSubstr(ObjectName(i),0,1)!="#")
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
         if(ObjectType(ObjectName(i))==OBJ_TREND && StringSubstr(ObjectName(i),0,1)!="#")
           {
            //Print(ObjectName(i));
            trend_lines[k].set_serial_number(i);
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
                  Alert("开仓!");
                  SendNotification("开仓");
                  SendNotification("开仓");
                  SendNotification("开仓");
                 }
              }
           }
         else
           {
            Print("close object name=",trend_lines[i].get_name());
            if(EA_function==operate_order || EA_function==alert_and_operate_order)
               OrderClose(OrderTicket(),OrderLots(),OrderType()?Ask:Bid,30,OrderType()?Red:Green);
            if(EA_function==alert_and_operate_order || EA_function==alert)
              {
               Alert("平仓!");
               SendNotification("平仓");
               SendNotification("平仓");
               SendNotification("平仓");
              }
           }
         refresh=1;
         return;
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool line_position(int number,double price)
  {
   if(price>ObjectGetValueByTime(0,ObjectName(number),Time[0],0))
      return 0;
   else return 1;
  }
//+------------------------------------------------------------------+
