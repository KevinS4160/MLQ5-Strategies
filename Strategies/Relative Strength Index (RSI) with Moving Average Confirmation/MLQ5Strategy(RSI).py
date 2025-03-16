import MetaTrader5 as mt5
import time

if not mt5.initialize():
    print("Failed to initialize MT5")
    exit()

SYMBOL = "NVDA"
LOT_SIZE = 0.1
RSI_PERIOD = 14
RSI_BUY_THRESHOLD = 30
RSI_SELL_THRESHOLD = 70
MA_PERIOD = 50

# Function to get RSI
def get_rsi(symbol, period):
    rates = mt5.copy_rates_from_pos(symbol, mt5.TIMEFRAME_M5, 0, period)
    if rates is None:
        print(f"Failed to get RSI for {symbol}")
        return 50
    gains = [max(0, rates[i]['close'] - rates[i-1]['close']) for i in range(1, len(rates))]
    losses = [max(0, rates[i-1]['close'] - rates[i]['close']) for i in range(1, len(rates))]
    avg_gain = sum(gains) / period
    avg_loss = sum(losses) / period
    if avg_loss == 0:
        return 100
    rs = avg_gain / avg_loss
    return 100 - (100 / (1 + rs))

# Function to get Moving Average
def get_moving_average(symbol, period):
    rates = mt5.copy_rates_from_pos(symbol, mt5.TIMEFRAME_M5, 0, period)
    if rates is None:
        print(f"Failed to get MA for {symbol}")
        return None
    return sum(rate['close'] for rate in rates) / len(rates)

def trade_bot():
    rsi_value = get_rsi(SYMBOL, RSI_PERIOD)
    ma_value = get_moving_average(SYMBOL, MA_PERIOD)
    price = mt5.symbol_info_tick(SYMBOL).bid

    if rsi_value is None or ma_value is None:
        print("Error retrieving RSI or MA values.")
        return

    positions = mt5.positions_get(symbol=SYMBOL)
    has_position = len(positions) > 0

    # Buy Signal: RSI < 30 and price > MA
    if rsi_value < RSI_BUY_THRESHOLD and price > ma_value and not has_position:
        order = {
            "action": mt5.TRADE_ACTION_DEAL,
            "symbol": SYMBOL,
            "volume": LOT_SIZE,
            "type": mt5.ORDER_TYPE_BUY,
            "price": price,
            "deviation": 10,
            "magic": 123456,
            "comment": "RSI Buy",
            "type_filling": mt5.ORDER_FILLING_IOC,
            "type_time": mt5.ORDER_TIME_GTC
        }
        mt5.order_send(order)
        print("Buy Order Placed!")

    # Sell Signal: RSI > 70 and price < MA
    if rsi_value > RSI_SELL_THRESHOLD and price < ma_value and has_position:
        order = {
            "action": mt5.TRADE_ACTION_DEAL,
            "symbol": SYMBOL,
            "volume": LOT_SIZE,
            "type": mt5.ORDER_TYPE_SELL,
            "price": price,
            "deviation": 10,
            "magic": 123456,
            "comment": "RSI Sell",
            "type_filling": mt5.ORDER_FILLING_IOC,
            "type_time": mt5.ORDER_TIME_GTC
        }
        mt5.order_send(order)
        print("Sell Order Placed!")

while True:
    trade_bot()
    time.sleep(60)
