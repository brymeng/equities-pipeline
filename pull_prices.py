"""
Week 0 - pull ~2 years of daily OHLCV prices for the frozen basket to CSV.

Produces three tidy (long-format) files:
  equities_prices.csv         full ~2-year dataset (for inspection / sanity)
  equities_prices_batch1.csv  older data  -> loaded to Snowflake in Week 1
  equities_prices_batch2.csv  recent data -> drives the incremental demo in Week 3
"""

import yfinance as yf
import pandas as pd
from datetime import date, timedelta

TICKERS = [
    "AAPL", "MSFT", "NVDA", "GOOGL",   # tech
    "JPM", "GS", "BAC",                # financials
    "XOM", "CVX",                      # energy
    "JNJ", "UNH", "PFE",               # healthcare
    "AMZN", "WMT",                     # consumer
    "SPY",                             # benchmark
]

END = date.today()
START = END - timedelta(days=365 * 2 + 5)    # ~2 years + small buffer
BATCH_CUTOFF = END - timedelta(days=182)     # ~6 months ago; batch1 < cutoff <= batch2

# --- pull ---
raw = yf.download(
    TICKERS, start=START, end=END,
    auto_adjust=False,      # keep unadjusted OHLC AND a separate Adj Close
    group_by="ticker",
    progress=False,
)

# --- reshape wide multi-index -> tidy long (one row per ticker per date) ---
available = set(raw.columns.get_level_values(0))
frames = []
for t in TICKERS:
    if t not in available:
        print(f"WARNING: no data returned for {t}")
        continue
    df = raw[t].reset_index()
    df["ticker"] = t
    frames.append(df)

tidy = pd.concat(frames, ignore_index=True)
tidy = tidy.rename(columns={
    "Date": "date", "Open": "open", "High": "high", "Low": "low",
    "Close": "close", "Adj Close": "adj_close", "Volume": "volume",
})
tidy = tidy[["date", "ticker", "open", "high", "low", "close", "adj_close", "volume"]]
tidy = tidy.dropna(subset=["close"])                    # drop non-trading / empty rows
tidy["date"] = pd.to_datetime(tidy["date"]).dt.date
tidy = tidy.sort_values(["ticker", "date"]).reset_index(drop=True)

# --- split into batches ---
batch1 = tidy[tidy["date"] < BATCH_CUTOFF]
batch2 = tidy[tidy["date"] >= BATCH_CUTOFF]

tidy.to_csv("equities_prices.csv", index=False)
batch1.to_csv("equities_prices_batch1.csv", index=False)
batch2.to_csv("equities_prices_batch2.csv", index=False)

# --- sanity output ---
print(f"Tickers returned : {tidy['ticker'].nunique()} / {len(TICKERS)}")
print(f"Date range       : {tidy['date'].min()} -> {tidy['date'].max()}")
print(f"Full rows        : {len(tidy):,}")
print(f"Batch 1 rows     : {len(batch1):,}  (< {BATCH_CUTOFF})")
print(f"Batch 2 rows     : {len(batch2):,}  (>= {BATCH_CUTOFF})")
