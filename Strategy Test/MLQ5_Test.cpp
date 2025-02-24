//+------------------------------------------------------------------+
//|                                                    SMA_Crossover |
//|                        Sample EA for MetaTrader 5                |
//+------------------------------------------------------------------+
//| This EA uses a simple moving average (SMA) crossover strategy.   |
//| When the fast SMA crosses above the slow SMA, it opens a buy order.|
//| When the fast SMA crosses below the slow SMA, it closes the position|
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>

input int    FastMAPeriod   = 10;               // Fast Moving Average period
input int    SlowMAPeriod   = 50;               // Slow Moving Average period
input ENUM_APPLIED_PRICE PriceType = PRICE_CLOSE; // Price type for MA calculation
input double LotSize        = 0.1;              // Lot size for trading

CTrade trade;

// Variables to hold previous MA values
double prevFastMA = 0, prevSlowMA = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   Print("SMA Crossover EA Initialized");
   // Initialize previous MA values using the previous completed bar
   prevFastMA = iMA(_Symbol, _Period, FastMAPeriod, 0, MODE_SMA, PriceType, 1);
   prevSlowMA = iMA(_Symbol, _Period, SlowMAPeriod, 0, MODE_SMA, PriceType, 1);
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   Print("SMA Crossover EA Deinitialized");
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   // Calculate current moving averages using the latest bar
   double currentFastMA = iMA(_Symbol, _Period, FastMAPeriod, 0, MODE_SMA, PriceType, 0);
   double currentSlowMA = iMA(_Symbol, _Period, SlowMAPeriod, 0, MODE_SMA, PriceType, 0);
   
   // Check for a buy signal: fast MA crossing above slow MA
   if(prevFastMA < prevSlowMA && currentFastMA > currentSlowMA)
   {
      // If no position is open, then open a buy position
      if(!PositionSelect(_Symbol))
      {
         if(trade.Buy(LotSize))
            Print("Buy order placed on ", _Symbol, " at Price: ", SymbolInfoDouble(_Symbol, SYMBOL_BID));
         else
            Print("Buy order failed. Error: ", GetLastError());
      }
   }
   // Check for a sell signal: fast MA crossing below slow MA
   else if(prevFastMA > prevSlowMA && currentFastMA < currentSlowMA)
   {
      // If there is an open position, then close it
      if(PositionSelect(_Symbol))
      {
         ulong ticket = PositionGetInteger(POSITION_TICKET);
         if(trade.PositionClose(ticket))
            Print("Position closed on ", _Symbol, " at Price: ", SymbolInfoDouble(_Symbol, SYMBOL_ASK));
         else
            Print("Position close failed. Error: ", GetLastError());
      }
   }
   
   // Update the previous MA values for the next tick
   prevFastMA = currentFastMA;
   prevSlowMA = currentSlowMA;
}
