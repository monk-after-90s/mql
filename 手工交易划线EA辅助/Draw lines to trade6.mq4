//+------------------------------------------------------------------+
//|                                           Draw line to trade.mq4 |
//|                                                         Antasann |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "QQ:907333918"
#property version   "6.00"
#property strict
#property description "本EA能感知除黄色外的趋势线、水平线、竖直线和角度线!开平仓线自动变色."
#property description "一个图表,一个单子!一个单子,一个图表!"
#property description "EA运行时手动移动线条最好不要越过报价，否则可能会被判定为K线触及线条!"
#property description "开仓线默认是一次性的,触发后变黄色;平仓线默认是重复触发的!"
#property description "定义线条的属性，在线条属性对话框的\"描述\"一栏进行文本输入，若是检测到以下字样:"
#property description "     \"一次性\"，表示线条只触发一次操作，之后变成黄色；\"重复使用\"表示线条重复触发动作;"
#property description "     \"用后即删\"，表示触发操作后即刻删除；"
#property description "     \"多\"或者\"空\"，表示开仓类型；"
#property description "     数字，表示触发开仓或者平仓的单量，没有数字则开仓单量进行风控计算,平仓单量为全部；"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum active_style
  {
   alert,//报警
   operate_order,//开平仓
   alert_and_operate_order//兼而有之
  };
input active_style EA_function=0;//触发功能
input color open_color=clrLime;//开仓线颜色
input color close_color=clrViolet;//平仓线颜色

                                  //input double lots=0.1;//单量
//input string comment="0";//Deal the order only with this comment
bool refresh;
bool action=1;
//bool object_event=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class lines
  {
public:
   int               serial_number;
   bool              initial_line_position;
   bool              one_time;
   bool              del;
   double            lot;
   int               order_type;
   string            name;
   int get_number()
     {
      return serial_number;
     }
   void set_serial_number(int number)
     {
      serial_number=number;
      name=ObjectName(number);
      if(number>=0)initial_line_position=get_position();
      string lin_description=ObjectGetString(0,name,OBJPROP_TEXT);
/*if(ObjectName(number)==open_line_name)ObjectSet(open_line_name,OBJPROP_COLOR,(color)Green);
      else ObjectSet(ObjectName(number),OBJPROP_COLOR,(color)Red);*/
      if(StringFind(lin_description,"多")>=0)
        {
         order_type=0;
         ObjectSet(name,6,open_color);
         ChartRedraw();
        }
      else if(StringFind(lin_description,"空")>=0)
        {
         order_type=1;
         ObjectSet(name,6,open_color);
         ChartRedraw();
        }
      else
        {
         order_type=10;
         ObjectSet(name,6,close_color);
         ChartRedraw();
        }
      Sleep(100);
      //Alert(ObjectName(number),"属性\"描述\"没有指明开仓方向，默认是做多单！");

      lot=double_in_string(lin_description);
      //lots=lot;
      if(ObjectGet(name,6)==open_color && lot==0)
        {
         MessageBox(name+"属性\"描述\"没有指明单量，采用风控算法。","提示");
         lot=AccountEquity()*0.02/(100*MarketInfo(NULL,MODE_TICKVALUE));
        }
      else if(ObjectGet(name,6)==close_color && lot>0)
        {
         MessageBox("只指明单量,未指明开仓方向!\n\r如果是平仓指定单量请忽视.","警告");
        }
      if(ObjectGet(name,6)==open_color)
         one_time=1;
      else if(ObjectGet(name,6)==close_color)
         one_time=0;
      if(StringFind(lin_description,"一次性")>=0)
         one_time=1;
      if(StringFind(lin_description,"重复使用")>=0)
         one_time=0;

      if(StringFind(lin_description,"用后即删")>=0)
         del=1;
      else del=0;
     }
   string get_name()
     {
      return name;
     }
   bool get_position()
     {
      mend_order_ticket();
      if(OrderSelect(EA_order.get_ticket(),SELECT_BY_TICKET) && OrderSymbol()==Symbol() && OrderCloseTime()==0 && EA_order.get_chart_id()==ChartID())
        {
         return line_position(serial_number,(ObjectGet(name,6)==open_color)?(OrderType()?Bid:Ask):(OrderType()?Ask:Bid));
        }
      else if(ObjectGet(name,6)==open_color)
         return line_position(serial_number,order_type?Bid:Ask);
      else
         return line_position(serial_number,Bid);
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
struct order
  {
private:
   int               ticket;
   long              chart_id;
public:
   void set_chart_id(long id)
     {
      chart_id=id;
     }
   long get_chart_id()
     {
      return chart_id;
     }
   int               get_ticket()
     {
      return            ticket;
     }
   void set_ticket(int a)
     {
      ticket=a;
     }
public:
                     order(){}
                     order(int order_ticket)
     {
      ticket=order_ticket;
     }
                    ~order(void)
     {
     }
  }
EA_order(0);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
//Print(EA_order.get_ticket());
//Print(OrderSelect(EA_order.get_ticket(),SELECT_BY_TICKET));
   if(!OrderSelect(EA_order.get_ticket(),SELECT_BY_TICKET))
     {
      int handle=FileOpen("order of chart "+ChartID()+".bin",FILE_READ|FILE_BIN);
      //Print("handle=",handle);
      FileReadStruct(handle,EA_order);
      //FileSeek(handle,1,SEEK_CUR);
      FileClose(handle);
     }
//Print(EA_order.get_ticket());
   refresh=1;
//Print("refresh=",refresh);
   ChartSetInteger(0,CHART_EVENT_OBJECT_CREATE,1);
   ChartSetInteger(0,CHART_EVENT_OBJECT_DELETE,1);
   Print(EA_order.get_ticket());
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
//Print("保存条件:",OrderSelect(EA_order.get_ticket(),SELECT_BY_TICKET) && OrderSymbol()==Symbol() && OrderCloseTime()==0 && EA_order.get_chart_id()==ChartID());
   if(OrderSelect(EA_order.get_ticket(),SELECT_BY_TICKET) && OrderSymbol()==Symbol() && OrderCloseTime()==0 && EA_order.get_chart_id()==ChartID())
     {
      int handle=FileOpen("order of chart "+ChartID()+".bin",FILE_WRITE|FILE_BIN);
      if(0<FileWriteStruct(handle,EA_order))
         FileFlush(handle);
      FileClose(handle);
     }
   else
     {
      string name="order of chart "+ChartID()+".bin";
      FileDelete(name);
      //Print("name=",name," 删除结果:",FileDelete(name));
     }
   Sleep(1000);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   if((id==CHARTEVENT_OBJECT_DRAG && (ObjectType(sparam)==OBJ_TREND || ObjectType(sparam)==OBJ_VLINE || ObjectType(sparam)==OBJ_HLINE || ObjectType(sparam)==OBJ_TRENDBYANGLE) && StringSubstr(sparam,0,1)!="#" && (ObjectGet(sparam,6)!=Yellow)) || 
      id==CHARTEVENT_OBJECT_DELETE || 
      (id==CHARTEVENT_OBJECT_CREATE && (ObjectType(sparam)==OBJ_TREND || ObjectType(sparam)==OBJ_VLINE || ObjectType(sparam)==OBJ_HLINE || ObjectType(sparam)==OBJ_TRENDBYANGLE)&&StringSubstr(sparam,0,1)!="#"&& (ObjectGet(sparam,6)!=Yellow)) ||
      (id==CHARTEVENT_OBJECT_CHANGE&&(ObjectType(sparam)==OBJ_TREND || ObjectType(sparam)==OBJ_VLINE || ObjectType(sparam)==OBJ_HLINE || ObjectType(sparam)==OBJ_TRENDBYANGLE)&&StringSubstr(sparam,0,1)!="#"&& (ObjectGet(sparam,6)!=Yellow))/*||
      (id==CHARTEVENT_OBJECT_CLICK && ObjectType(sparam)==OBJ_TREND&&StringSubstr(sparam,0,1)!="#")*/)
     {
      //object_event=1;
      //Print(object_event);
      //Print("Object event:",id);
      refresh=1;
     }
   if(id==CHARTEVENT_OBJECT_DRAG && (ObjectType(sparam)==OBJ_TREND || ObjectType(sparam)==OBJ_VLINE || ObjectType(sparam)==OBJ_HLINE || ObjectType(sparam)==OBJ_TRENDBYANGLE) && StringSubstr(sparam,0,1)!="#" && (ObjectGet(sparam,6)!=Yellow))
     {
      action=0;
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
      ChartRedraw();
      ArrayFree(trend_lines);
/*for(int i=0;i<ArraySize(trend_lines);i++)
        {
         trend_lines[i].set_serial_number(NULL);
        }*/
      int j=0;
      for(int i=0;i<ObjectsTotal();i++)
        {
         if((ObjectType(ObjectName(i))==OBJ_TREND || ObjectType(ObjectName(i))==OBJ_VLINE || ObjectType(ObjectName(i))==OBJ_HLINE || ObjectType(ObjectName(i))==OBJ_TRENDBYANGLE) && StringSubstr(ObjectName(i),0,1)!="#" && (ObjectGet(ObjectName(i),6)!=Yellow))
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
         if((ObjectType(ObjectName(i))==OBJ_TREND || ObjectType(ObjectName(i))==OBJ_VLINE || ObjectType(ObjectName(i))==OBJ_HLINE || ObjectType(ObjectName(i))==OBJ_TRENDBYANGLE) && StringSubstr(ObjectName(i),0,1)!="#" && (ObjectGet(ObjectName(i),6)!=Yellow))
           {
            Print(ObjectName(i));
            trend_lines[k].set_serial_number(i);
            k++;
           }
        }
     }
   for(int i=0;i<ArraySize(trend_lines);i++)
     {
      if(trend_lines[i].get_position()!=trend_lines[i].get_initial_position() && action)//touch a line
        {
         //string name=trend_lines[i].get_name();
         //trend_lines[i].set_initial_line_position(trend_lines[i].get_position());
         mend_order_ticket();
         //Print("Position=",trend_lines[i].get_position()," initial position=",trend_lines[i].get_initial_position());
         if(ObjectGet(trend_lines[i].get_name(),6)==open_color)//trend_lines[i].get_name()==open_line_name)
           {
            if(OrderSelect(EA_order.get_ticket(),SELECT_BY_TICKET) && OrderSymbol()==Symbol() && OrderCloseTime()==0 && EA_order.get_chart_id()==ChartID());
            else
              {
               if((EA_function==operate_order || EA_function==alert_and_operate_order) && trend_lines[i].order_type<=1)
                 {
                  int ticket;
                  RefreshRates();
                  while(0>(ticket=OrderSend(NULL,trend_lines[i].order_type,trend_lines[i].lot,trend_lines[i].order_type?Bid:Ask,30,0,0,NULL,0,0,trend_lines[i].order_type?Red:Green)))
                     RefreshRates();
                  EA_order.set_ticket(ticket);
                  EA_order.set_chart_id(ChartID());
                  //Print(EA_order.get_ticket());
                 }
              }
            if(EA_function==alert_and_operate_order || EA_function==alert)
              {
               Alert("第"+chart_serial_number()+"个图表 "+Symbol()+" 开仓!");
               SendNotification("第"+chart_serial_number()+"个图表 "+Symbol()+" 开仓!");
               SendNotification("第"+chart_serial_number()+"个图表 "+Symbol()+" 开仓!");
               SendNotification("第"+chart_serial_number()+"个图表 "+Symbol()+" 开仓!");
              }
           }
         else
           {
            //Print("close object name=",trend_lines[i].get_name());
            if((EA_function==operate_order || EA_function==alert_and_operate_order) && OrderSelect(EA_order.get_ticket(),SELECT_BY_TICKET) && OrderSymbol()==Symbol() && OrderCloseTime()==0 && EA_order.get_chart_id()==ChartID())
              {
               OrderClose(OrderTicket(),(trend_lines[i].lot>0)?trend_lines[i].lot:OrderLots(),OrderType()?Ask:Bid,30,OrderType()?Red:Green);
              }
            if(EA_function==alert_and_operate_order || EA_function==alert)
              {
               Alert("第"+chart_serial_number()+"个图表 "+Symbol()+" 平仓!");
               SendNotification("第"+chart_serial_number()+"个图表 "+Symbol()+" 平仓!");
               SendNotification("第"+chart_serial_number()+"个图表 "+Symbol()+" 平仓!");
               SendNotification("第"+chart_serial_number()+"个图表 "+Symbol()+" 平仓!");
              }
           }
         //ObjectSet(trend_lines[i].get_name(),6,White);
         //Print(trend_lines[i].get_name()," 用后即删",trend_lines[i].del," 一次性:",trend_lines[i].one_time);
         //ObjectDelete(trend_lines[i].get_name()+"a");
         if(trend_lines[i].del)
           {
            ObjectDelete(trend_lines[i].get_name());
           }
         if(trend_lines[i].one_time)
           {
            //Print(trend_lines[i].one_time);
            while(!ObjectSet(trend_lines[i].get_name(),6,Yellow) || Yellow!=(color)ObjectGet(trend_lines[i].get_name(),6))
              {
               ChartRedraw();
               Sleep(100);
              }
            //Print(trend_lines[i].get_name(),j," 次设置黄色,当前颜色为:",(ColorToString(ObjectGet(trend_lines[i].get_name(),6)))," 错误是:",GetLastError());
           }
         ChartRedraw();
         Sleep(100);
         refresh=1;
         mend_order_ticket();
         return;
        }
     }
   if(action==0)action=1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool line_position(int number,double price)
  {
   if(ObjectType(ObjectName(number))==OBJ_TREND || ObjectType(ObjectName(number))==OBJ_TRENDBYANGLE)
     {
      if(price>ObjectGetValueByTime(0,ObjectName(number),Time[0],0))
         return 0;
      else return 1;
     }
   else if(ObjectType(ObjectName(number))==OBJ_HLINE)
     {
      if(price>ObjectGet(ObjectName(number),OBJPROP_PRICE1))
         return 0;
      else return 1;
     }
   else if(ObjectType(ObjectName(number))==OBJ_VLINE)
     {
      if(ObjectGet(ObjectName(number),OBJPROP_TIME1)>TimeCurrent())
         return  0;
      else return 1;
     }
   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void mend_order_ticket()
  {
   if(OrderSelect(EA_order.get_ticket(),SELECT_BY_TICKET) && OrderSymbol()==Symbol() && OrderCloseTime()>0 && EA_order.get_chart_id()==ChartID())
     {
      EA_order.set_ticket(StrToInteger(StringSubstr(OrderComment(),4)));
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double double_in_string(string s)
  {
   int pos_start=-100,pos_end=-100;
   for(int i=0;i<StringLen(s);i++)
     {
      if(StringGetCharacter(s,i)=='0' || StringGetCharacter(s,i)=='1' || StringGetCharacter(s,i)=='2' || StringGetCharacter(s,i)=='3' || StringGetCharacter(s,i)=='4' || StringGetCharacter(s,i)=='5' || StringGetCharacter(s,i)=='6' || StringGetCharacter(s,i)=='7' || StringGetCharacter(s,i)=='8' || StringGetCharacter(s,i)=='9')
        {
         if(pos_start<0)
            pos_start=i;
         pos_end=i;
        }
     }
   return StrToDouble(StringSubstr(s,pos_start,pos_end-pos_start+1));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
uchar chart_serial_number()
  {
   long id=ChartFirst();
   for(uchar i=1;;i++)
     {
      if(id==ChartID())
         return i;
      id=ChartNext(id);
     }
  }
//+------------------------------------------------------------------+
