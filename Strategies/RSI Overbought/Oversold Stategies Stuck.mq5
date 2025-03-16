//+------------------------------------------------------------------+
//| RSI Strategy EA                                                  |
//+------------------------------------------------------------------+
input int RSIPeriod = 14;
input double RSIOverbought = 70.0;
input double RSIoversold = 30.0;
input double LotSize = 0.1;

int rsi_handle;
double rsi[];

void OnInit()
  {
   rsi_handle = iRSI(_Symbol, _Period, RSIPeriod, PRICE_CLOSE);
   ArraySetAsSeries(rsi, true);
  }

void OnTick()
  {
   CopyBuffer(rsi_handle, 0, 0, 2, rsi);

   if (PositionSelect(_Symbol) == false)
     {
      if (rsi[0] < RSIoversold)
        trade(ORDER_TYPE_BUY);

      if (rsi[0] > RSIOverbought)
        trade(ORDER_TYPE_SELL);
     }
  }

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
   request.deviation = 10;
   OrderSend(request, result);
  }
