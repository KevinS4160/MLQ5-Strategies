//+------------------------------------------------------------------+
//| Auto Trading Strategy: RSI & Moving Average                     |
//+------------------------------------------------------------------+
#property strict

input string symbol = "NVDA";
input double lot_size = 0.1;
input int rsi_period = 14;    // RSI Period
input int rsi_buy_threshold = 30;
input int rsi_sell_threshold = 70;
input int ma_period = 50;     // Moving Average Period

// Get RSI value
double GetRSI(string sym, int period) {
    double rsi_values[];
    if (CopyBuffer(iRSI(sym, PERIOD_M5, period, PRICE_CLOSE), 0, 1, 1, rsi_values) <= 0) {
        Print("Failed to get RSI value for ", sym);
        return 50; // Neutral value
    }
    return rsi_values[0];
}

// Get Moving Average
double GetMovingAverage(string sym, int period) {
    double ma_values[];
    if (CopyBuffer(iMA(sym, PERIOD_M5, period, 0, MODE_SMA, PRICE_CLOSE), 0, 1, 1, ma_values) <= 0) {
        Print("Failed to get MA value for ", sym);
        return 0;
    }
    return ma_values[0];
}

void OnTick() {
    double rsi_value = GetRSI(symbol, rsi_period);
    double ma_value = GetMovingAverage(symbol, ma_period);
    double price = SymbolInfoDouble(symbol, SYMBOL_BID);

    if (rsi_value == 50 || ma_value == 0) {
        Print("Error retrieving RSI or MA values.");
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

    // Buy Signal: RSI < 30 (oversold) & price > MA (uptrend confirmation)
    if (rsi_value < rsi_buy_threshold && price > ma_value && !hasPosition) {
        request.action = TRADE_ACTION_DEAL;
        request.type = ORDER_TYPE_BUY;
        request.symbol = symbol;
        request.volume = lot_size;
        request.price = price;
        request.deviation = 10;
        request.magic = 123456;
        request.comment = "RSI Buy";
        request.type_filling = (ENUM_ORDER_TYPE_FILLING)filling_mode;
        request.type_time = ORDER_TIME_GTC;

        if (!OrderSend(request, result)) {
            Print("Buy Order Failed: ", result.comment);
        } else {
            Print("Buy Order Placed!");
        }
    }

    // Sell Signal: RSI > 70 (overbought) & price < MA (downtrend confirmation)
    if (rsi_value > rsi_sell_threshold && price < ma_value && hasPosition) {
        request.action = TRADE_ACTION_DEAL;
        request.type = ORDER_TYPE_SELL;
        request.symbol = symbol;
        request.volume = lot_size;
        request.price = price;
        request.deviation = 10;
        request.magic = 123456;
        request.comment = "RSI Sell";
        request.type_filling = (ENUM_ORDER_TYPE_FILLING)filling_mode;
        request.type_time = ORDER_TIME_GTC;

        if (!OrderSend(request, result)) {
            Print("Sell Order Failed: ", result.comment);
        } else {
            Print("Sell Order Placed!");
        }
    }
}
