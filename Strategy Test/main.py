import MetaTrader5 as mt5
import pandas as pd
import time

# Strategy parameters
symbol = "EURUSD"             # Change to your desired symbol
fast_period = 10              # Fast SMA period
slow_period = 50              # Slow SMA period
lot_size = 0.1                # Trading volume per order
timeframe = mt5.TIMEFRAME_M1  # 1-minute chart

# Initialize connection to MetaTrader 5
if not mt5.initialize():
    print("initialize() failed, error code =", mt5.last_error())
    quit()

# Ensure the symbol is available for trading
if not mt5.symbol_select(symbol, True):
    print("symbol_select() failed for", symbol)
    mt5.shutdown()
    quit()

# Function to calculate Simple Moving Average (SMA)
def calculate_sma(data, period):
    return data['close'].rolling(window=period).mean()

prev_fast_sma = None
prev_slow_sma = None

while True:
    # Retrieve the last 100 bars
    rates = mt5.copy_rates_from_pos(symbol, timeframe, 0, 100)
    if rates is None:
        print("Failed to retrieve rates:", mt5.last_error())
        time.sleep(60)
        continue

    # Convert the rates data into a pandas DataFrame
    df = pd.DataFrame(rates)
    df['time'] = pd.to_datetime(df['time'], unit='s')
    
    # Calculate the moving averages
    df['fast_sma'] = calculate_sma(df, fast_period)
    df['slow_sma'] = calculate_sma(df, slow_period)
    
    # Get the latest SMA values
    current_fast_sma = df['fast_sma'].iloc[-1]
    current_slow_sma = df['slow_sma'].iloc[-1]
    
    # Ensure we have previous SMA values for crossover detection
    if prev_fast_sma is not None and prev_slow_sma is not None:
        # Buy signal: fast SMA crosses above slow SMA
        if prev_fast_sma < prev_slow_sma and current_fast_sma > current_slow_sma:
            # Check for open positions on the symbol
            positions = mt5.positions_get(symbol=symbol)
            if positions is None or len(positions) == 0:
                request = {
                    "action": mt5.TRADE_ACTION_DEAL,
                    "symbol": symbol,
                    "volume": lot_size,
                    "type": mt5.ORDER_TYPE_BUY,
                    "price": mt5.symbol_info_tick(symbol).ask,
                    "deviation": 20,
                    "magic": 234000,
                    "comment": "Python EA open buy",
                    "type_time": mt5.ORDER_TIME_GTC,
                    "type_filling": mt5.ORDER_FILLING_IOC,
                }
                result = mt5.order_send(request)
                print("Buy order result:", result)
        
        # Sell signal: fast SMA crosses below slow SMA
        elif prev_fast_sma > prev_slow_sma and current_fast_sma < current_slow_sma:
            positions = mt5.positions_get(symbol=symbol)
            if positions and len(positions) > 0:
                for pos in positions:
                    if pos.type == mt5.ORDER_TYPE_BUY:
                        request = {
                            "action": mt5.TRADE_ACTION_DEAL,
                            "symbol": symbol,
                            "volume": pos.volume,
                            "type": mt5.ORDER_TYPE_SELL,
                            "position": pos.ticket,
                            "price": mt5.symbol_info_tick(symbol).bid,
                            "deviation": 20,
                            "magic": 234000,
                            "comment": "Python EA close sell",
                            "type_time": mt5.ORDER_TIME_GTC,
                            "type_filling": mt5.ORDER_FILLING_IOC,
                        }
                        result = mt5.order_send(request)
                        print("Sell order result:", result)
    
    # Update the previous SMA values for the next iteration
    prev_fast_sma = current_fast_sma
    prev_slow_sma = current_slow_sma

    # Pause before the next cycle (e.g., wait 60 seconds)
    time.sleep(60)
    
# When finished, shutdown the MetaTrader 5 connection
mt5.shutdown()
