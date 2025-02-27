const Binance = require('node-binance-api');
const binance = new Binance().options({
    APIKEY: 'your_api_key',
    APISECRET: 'your_api_secret'
});

// Configurations
const symbol = 'BTCUSDT';
const lotSize = 0.1;
const stopLoss = 30;
const takeProfit = 60;

// Indicators
const fastEMA = 50;
const slowEMA = 200;
const macdFast = 12;
const macdSlow = 26;
const macdSignal = 9;
const rsiPeriod = 14;

// Machine Learning Placeholder (Random Buy/Sell)
function machineLearningSignal() {
    return Math.random() < 0.5;  // Random true/false
}

// Get historical data and calculate indicators
async function getIndicators() {
    let candles = await binance.candlesticks(symbol, '15m', { limit: 200 });
    let closes = candles.map(candle => parseFloat(candle[4])); // Close prices

    let emaFast = calculateEMA(closes, fastEMA);
    let emaSlow = calculateEMA(closes, slowEMA);
    let [macdMain, macdSignal] = calculateMACD(closes, macdFast, macdSlow, macdSignal);
    let rsi = calculateRSI(closes, rsiPeriod);

    return { emaFast, emaSlow, macdMain, macdSignal, rsi };
}

// Trade execution
async function trade() {
    let { emaFast, emaSlow, macdMain, macdSignal, rsi } = await getIndicators();
    let buyCondition = emaFast > emaSlow && macdMain > macdSignal && rsi > 50 && machineLearningSignal();
    let sellCondition = emaFast < emaSlow && macdMain < macdSignal && rsi < 50 && machineLearningSignal();

    if (buyCondition) {
        await binance.marketBuy(symbol, lotSize);
        console.log("Buy Order Placed!");
    }
    else if (sellCondition) {
        await binance.marketSell(symbol, lotSize);
        console.log("Sell Order Placed!");
    }
}

// Run trading bot
setInterval(trade, 60 * 1000); // Runs every 1 minute

// Utility functions
function calculateEMA(data, period) {
    let multiplier = 2 / (period + 1);
    return data.reduce((acc, val, index) => {
        return index === 0 ? val : (val - acc) * multiplier + acc;
    });
}

function calculateMACD(data, fast, slow, signal) {
    let macdFast = calculateEMA(data, fast);
    let macdSlow = calculateEMA(data, slow);
    let macdLine = macdFast - macdSlow;
    let signalLine = calculateEMA([macdLine], signal);
    return [macdLine, signalLine];
}

function calculateRSI(data, period) {
    let gains = 0, losses = 0;
    for (let i = 1; i < period; i++) {
        let diff = data[i] - data[i - 1];
        if (diff > 0) gains += diff;
        else losses -= diff;
    }
    let rs = gains / losses;
    return 100 - (100 / (1 + rs));
}
