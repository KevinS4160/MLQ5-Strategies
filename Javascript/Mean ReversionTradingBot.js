const Binance = require('node-binance-api');
const binance = new Binance().options({
    APIKEY: 'your_api_key',
    APISECRET: 'your_api_secret'
});

const symbol = 'BTCUSDT';
const lotSize = 0.001;  // Adjust based on your risk

async function getSMA(period = 20) {
    let candles = await binance.candlesticks(symbol, '15m', { limit: period });
    let closes = candles.map(c => parseFloat(c[4])); // Closing prices
    let sma = closes.reduce((a, b) => a + b, 0) / period;
    return { price: closes[closes.length - 1], sma };
}

async function trade() {
    let { price, sma } = await getSMA();
    
    if (price < sma) {
        console.log(`Buying at ${price}, SMA: ${sma}`);
        await binance.marketBuy(symbol, lotSize);
    } else if (price > sma) {
        console.log(`Selling at ${price}, SMA: ${sma}`);
        await binance.marketSell(symbol, lotSize);
    }
}

setInterval(trade, 60 * 1000); // Runs every minute
