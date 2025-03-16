<?php
function getBinanceData($symbol, $interval = "5m", $limit = 50) {
    $url = "https://api.binance.com/api/v3/klines?symbol={$symbol}&interval={$interval}&limit={$limit}";
    $json = file_get_contents($url);
    return json_decode($json, true);
}

// Calculate RSI
function calculateRSI($closes, $period = 14) {
    $gains = [];
    $losses = [];
    
    for ($i = 1; $i < count($closes); $i++) {
        $diff = $closes[$i] - $closes[$i - 1];
        if ($diff > 0) {
            $gains[] = $diff;
            $losses[] = 0;
        } else {
            $gains[] = 0;
            $losses[] = abs($diff);
        }
    }

    $avg_gain = array_sum(array_slice($gains, 0, $period)) / $period;
    $avg_loss = array_sum(array_slice($losses, 0, $period)) / $period;
    
    for ($i = $period; $i < count($gains); $i++) {
        $avg_gain = ($avg_gain * ($period - 1) + $gains[$i]) / $period;
        $avg_loss = ($avg_loss * ($period - 1) + $losses[$i]) / $period;
    }
    
    if ($avg_loss == 0) return 100;
    $rs = $avg_gain / $avg_loss;
    return 100 - (100 / (1 + $rs));
}

// Calculate Simple Moving Average (SMA)
function calculateSMA($closes, $period = 50) {
    return array_sum(array_slice($closes, -$period)) / $period;
}

// Fetch data & compute signals
$symbol = "BTCUSDT";  // Example: Bitcoin
$data = getBinanceData($symbol);
$closes = array_map(fn($candle) => (float)$candle[4], $data);

if (count($closes) < 50) {
    die("Not enough data.");
}

$rsi = calculateRSI($closes, 14);
$sma = calculateSMA($closes, 50);
$latest_price = end($closes);

echo "RSI: $rsi\n";
echo "SMA: $sma\n";
echo "Latest Price: $latest_price\n";

// Generate Trading Signal
if ($rsi < 30 && $latest_price > $sma) {
    echo "🔹 BUY SIGNAL\n";
} elseif ($rsi > 70 && $latest_price < $sma) {
    echo "🔻 SELL SIGNAL\n";
} else {
    echo "📉 No trade\n";
}
?>
