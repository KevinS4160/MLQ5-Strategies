//+------------------------------------------------------------------+
//| Auto Trading Strategy: Golden Cross & Death Cross               |
//+------------------------------------------------------------------+
#property strict

input string symbol = "NVDA";  // Update to "AMD" if needed
input double lot_size = 0.1;   // Adjust lot size
input int ma_short = 50;       // Short Moving Average
input int ma_long = 200;       // Long Moving Average

// Get Moving Average values
double GetMovingAverage(string sym, int period) {
    double ma_val[];
    if (CopyBuffer(iMA(sym, PERIOD_M5, period, 0, MODE_SMA, PRICE_CLOSE), 0, 1, 1, ma_val) <= 0) {
        Print("Failed to get MA value for ", sym);
        return 0;
    }
    return ma_val[0];
}

void OnTick() {
    double fastMA = GetMovingAverage(symbol, ma_short);
    double slowMA = GetMovingAverage(symbol, ma_long);

    if (fastMA == 0 || slowMA == 0) {
        Print("Error retrieving MA values.");
        return;
    }

    // Check for open positions
    bool hasPosition = false;
    for (int i = 0; i < PositionsTotal(); i++) {
        if (PositionGetSymbol(i) == symbol) {
            hasPosition = true;
            break;
        }
    }

    MqlTradeRequest request;
    MqlTradeResult result;
    ZeroMemory(request);

    int filling_mode = SYMBOL_FILLING_MODE;
    double price = SymbolInfoDouble(symbol, SYMBOL_BID);

    if (fastMA > slowMA && !hasPosition) {
        // Golden Cross - Buy
        request.action = TRADE_ACTION_DEAL;
        request.type = ORDER_TYPE_BUY;
        request.symbol = symbol;
        request.volume = lot_size;
        request.price = price;
        request.deviation = 10;
        request.magic = 123456;
        request.comment = "Golden Cross Buy";
        request.type_filling = (ENUM_ORDER_TYPE_FILLING)filling_mode;
        request.type_time = ORDER_TIME_GTC;

        if (!OrderSend(request, result)) {
            Print("Buy Order Failed: ", result.comment);
        } else {
            Print("Buy Order Placed!");
        }
    }

    if (fastMA < slowMA && hasPosition) {
        // Death Cross - Sell
        request.action = TRADE_ACTION_DEAL;
        request.type = ORDER_TYPE_SELL;
        request.symbol = symbol;
        request.volume = lot_size;
        request.price = price;
        request.deviation = 10;
        request.magic = 123456;
        request.comment = "Death Cross Sell";
        request.type_filling = (ENUM_ORDER_TYPE_FILLING)filling_mode;
        request.type_time = ORDER_TIME_GTC;

        if (!OrderSend(request, result)) {
            Print("Sell Order Failed: ", result.comment);
        } else {
            Print("Sell Order Placed!");
        }
    }
}
