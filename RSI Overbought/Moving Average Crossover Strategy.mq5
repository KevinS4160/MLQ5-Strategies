//+------------------------------------------------------------------+
//| Moving Average Crossover EA                                      |
//+------------------------------------------------------------------+
input int FastMA = 12;
input int SlowMA = 26;
input int StopLoss = 100;  // Points
input int TakeProfit = 200; // Points
input double LotSize = 0.1;

int fast_handle, slow_handle;
double fast_ma[], slow_ma[];

//+------------------------------------------------------------------+
void OnInit()
  {
   fast_handle = iMA(_Symbol, _Period, FastMA, 0, MODE_EMA, PRICE_CLOSE);
   slow_handle = iMA(_Symbol, _Period, SlowMA, 0, MODE_EMA, PRICE_CLOSE);
   ArraySetAsSeries(fast_ma, true);
   ArraySetAsSeries(slow_ma, true);
  }

//+------------------------------------------------------------------+
void OnTick()
  {
   CopyBuffer(fast_handle, 0, 0, 3, fast_ma);
   CopyBuffer(slow_handle, 0, 0, 3, slow_ma);

   if (PositionSelect(_Symbol) == false)
     {
      // Check for Buy Signal
      if (fast_ma[1] < slow_ma[1] && fast_ma[0] > slow_ma[0])
        {
         trade(ORDER_TYPE_BUY);
        }
      // Check for Sell Signal
      if (fast_ma[1] > slow_ma[1] && fast_ma[0] < slow_ma[0])
        {
         trade(ORDER_TYPE_SELL);
        }
     }
  }

//+------------------------------------------------------------------+
void trade(ENUM_ORDER_TYPE type)
  {
   MqlTradeRequest request;
   MqlTradeResult result;
   ZeroMemory(request);
   request.action = TRADE_ACTION_DEAL;
   request.symbol = _Symbol;
   request.volume = LotSize;
   request.type = type;
   request.price = (type == ORDER_TYPE_BUY) ? SymbolInfoDouble(_Symbol, SYMBOL_ASK) : SymbolInfoDouble(_Symbol, SYMBOL_BID);
   request.sl = (type == ORDER_TYPE_BUY) ? request.price - StopLoss * _Point : request.price + StopLoss * _Point;
   request.tp = (type == ORDER_TYPE_BUY) ? request.price + TakeProfit * _Point : request.price - TakeProfit * _Point;
   request.deviation = 10;
   OrderSend(request, result);
  }
