#include <Trade/Trade.mqh>

class MLQ5StockStrategy
{
private:
    CTrade trade;
    int magicNumber;
    double atrMultiplier;
    int donchianPeriod;
    int fastSMAPeriod;
    int slowSMAPeriod;
    int macdFastPeriod;
    int macdSlowPeriod;
    int macdSignalPeriod;

public:
    MLQ5StockStrategy(int magic, double atrMult, int donchian, int fastSMA, int slowSMA, int macdFast, int macdSlow, int macdSignal)
    {
        magicNumber = magic;
        atrMultiplier = atrMult;
        donchianPeriod = donchian;
        fastSMAPeriod = fastSMA;
        slowSMAPeriod = slowSMA;
        macdFastPeriod = macdFast;
        macdSlowPeriod = macdSlow;
        macdSignalPeriod = macdSignal;
    }

    void OnTick()
    {
        double upperChannel = iHigh(_Symbol, PERIOD_D1, iHighest(_Symbol, PERIOD_D1, MODE_HIGH, donchianPeriod, 1));
        double lowerChannel = iLow(_Symbol, PERIOD_D1, iLowest(_Symbol, PERIOD_D1, MODE_LOW, donchianPeriod, 1));
        double fastSMA = iMA(_Symbol, PERIOD_D1, fastSMAPeriod, 0, MODE_SMA, PRICE_CLOSE, 0);
        double slowSMA = iMA(_Symbol, PERIOD_D1, slowSMAPeriod, 0, MODE_SMA, PRICE_CLOSE, 0);
        double macdMain, macdSignal, macdHist;
        IndicatorBuffers(3);
        macdMain = iMACD(_Symbol, PERIOD_D1, macdFastPeriod, macdSlowPeriod, macdSignalPeriod, PRICE_CLOSE, MODE_MAIN, 0);
        macdSignal = iMACD(_Symbol, PERIOD_D1, macdFastPeriod, macdSlowPeriod, macdSignalPeriod, PRICE_CLOSE, MODE_SIGNAL, 0);
        
        double atr = iATR(_Symbol, PERIOD_D1, 14, 0);
        double atrStop = atr * atrMultiplier;

        if (fastSMA > slowSMA && macdMain > macdSignal && Close[0] > upperChannel)
        {
            trade.Buy(1.0, _Symbol, 0, 0, 0, "Breakout Buy");
        }
        else if (fastSMA < slowSMA && macdMain < macdSignal && Close[0] < lowerChannel)
        {
            trade.Sell(1.0, _Symbol, 0, 0, 0, "Breakout Sell");
        }
    }
};

//+------------------------------------------------------------------+
//| Expert initialization function                                  |
//+------------------------------------------------------------------+
int OnInit()
{
    MLQ5StockStrategy strategy(10001, 1.5, 20, 50, 200, 12, 26, 9);
    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert tick function                                           |
//+------------------------------------------------------------------+
void OnTick()
{
    MLQ5StockStrategy strategy(10001, 1.5, 20, 50, 200, 12, 26, 9);
    strategy.OnTick();
}
