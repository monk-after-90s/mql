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
input string open_line_name="Trade line";//Line name for opening an order
input double lots=0.1;//Order lots
input direction operation;//Market order type
                          //input string comment="0";//Deal the order only with this comment
input string stoploss_line_name="Stoploss line";//Line name for stoploss
input string takeprofit_line_name="takeprofit line";//Line name for stoploss
int magic=9843;//Order magic number
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class lines
  {
private:
   string            line_name;
   bool              line_position;
   bool              initial_line_position;
public:
   void set(string name)
     {
      line_name=name;
      line_position=line_position(line_name,operation?Ask:Bid);
      static bool first=1;
      if(first)
        {
         initial_line_position=line_position;
         first=0;
        }
     }
   bool get_position()
     {
      return line_position;
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
   bool order_exist=0;
   for(int i=0;i<OrdersTotal();i++)
     {
      if(OrderSelect(i,SELECT_BY_POS) && OrderSymbol()==Symbol() && OrderMagicNumber()==magic && OrderComment()==(string)ChartID())
         order_exist=1;
     }
   if(order_exist)
     {
      static lines close_lines[];
      ArrayResize(close_lines,4);
      int j=0;
      for(int i=0;i<ObjectsTotal();i++)
        {
         if(ObjectType(ObjectName(i))==OBJ_TREND && ObjectName(i)!="Trade line")
           {
            close_lines[j].set(ObjectName(i));
            j++;
           }
        }
      bool close_order=0;
      for(int i=0;i<j;i++)
        {
         if();
        }
      return;
     }
//opne an order
//static char prev_above_open_line=2;
/*bool above_open_line=0;
   if((operation?Bid:Ask)>ObjectGetValueByTime(0,"Trade line",Time[0],0))
      above_open_line=0;
   else above_open_line=1;*/
//if(prev_above_open_line==2)prev_above_open_line=above_open_line;
  }
//+------------------------------------------------------------------+
bool line_position(string line_name,double price)
  {
   if(price>ObjectGetValueByTime(0,line_name,Time[0],0))
      return 0;
   else return 1;
  }
//+------------------------------------------------------------------+
