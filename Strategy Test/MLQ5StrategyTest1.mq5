//+------------------------------------------------------------------+
//|                  Simple MLQ5 Trading Bot                        |
//+------------------------------------------------------------------+
#property strict

// Input settings
input double LotSize = 0.1;         // Lot size
input int MA_Period = 50;           // Moving Average period
input double StopLoss = 30;         // Stop Loss in pips
input double TakeProfit = 50;       // Take Profit in pips
input string SymbolName = "EURUSD"; // Trading pair

// Function to check if a position exists
bool PositionExists(string symbol) {
    for (int i = 0; i < PositionsTotal(); i++) {
        if (PositionGetSymbol(i) == symbol) return true;
    }
    return false;
}

// Function to open a trade
void OpenTrade(int orderType) {
    MqlTradeRequest request;
    MqlTradeResult result;
    
    request.action = TRADE_ACTION_DEAL;
    request.type = orderType;
    request.symbol = SymbolName;
    request.volume = LotSize;
    request.deviation = 10; // Slippage control
    request.magic = 123456; // Unique ID for the order
    
    // Get current price
    double price = (orderType == ORDER_TYPE_BUY) ? SymbolInfoDouble(SymbolName, SYMBOL_ASK) : SymbolInfoDouble(SymbolName, SYMBOL_BID);
    request.price = price;

    // Set Stop Loss & Take Profit
    request.sl = (orderType == ORDER_TYPE_BUY) ? price - StopLoss * _Point : price + StopLoss * _Point;
    request.tp = (orderType == ORDER_TYPE_BUY) ? price + TakeProfit * _Point : price - TakeProfit * _Point;

    if (OrderSend(request, result)) {
        Print("Trade opened: ", result.order);
    } else {
        Print("Trade failed: ", result.comment);
    }
}

// Function to check for trade signals
void CheckTradeSignal() {
    double price = SymbolInfoDouble(SymbolName, SYMBOL_CLOSE);
    double ma = iMA(SymbolName, 0, MA_Period, 0, MODE_SMA, PRICE_CLOSE, 0);

    // Buy if price is above MA and no open position
    if (price > ma && !PositionExists(SymbolName)) {
        OpenTrade(ORDER_TYPE_BUY);
    }
    // Sell if price is below MA and no open position
    else if (price < ma && !PositionExists(SymbolName)) {
        OpenTrade(ORDER_TYPE_SELL);
    }
}

// Main function - runs continuously in an EA (Expert Advisor)
void OnTick() {
    CheckTradeSignal();
}
