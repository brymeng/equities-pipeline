# Equities Analytics Pipeline

An end-to-end analytics-engineering pipeline for daily equities data: raw prices
landed in **Snowflake**, transformed with **dbt** into tested and documented
staging and mart tables, and surfaced in a **Power BI** dashboard of performance
and risk metrics.

**Status:** In progress — see roadmap below.

## Problem

This project builds a repeatable, tested pipeline for tracking daily performance
and risk across a diversified basket of equities. Raw daily prices are landed in
Snowflake, transformed through dbt into analytics-ready tables (daily returns,
moving averages, sector performance, and return vs. a market benchmark), and
visualized in Power BI. It demonstrates a modern analytics-engineering workflow —
raw → staging → mart — with incremental processing, automated data tests, and
lineage documentation.

## Data

- ~2 years of daily OHLCV price history for 15 tickers across 4 sectors, plus
  SPY as a market benchmark.
- Source: Yahoo Finance via the [`yfinance`](https://pypi.org/project/yfinance/)
  Python library — see [`pull_prices.py`](./pull_prices.py).
- Loaded to Snowflake in batches to simulate new data arriving over time, which
  drives the incremental model.

**Basket:** AAPL, MSFT, NVDA, GOOGL (tech) · JPM, GS, BAC (financials) ·
XOM, CVX (energy) · JNJ, UNH, PFE (healthcare) · AMZN, WMT (consumer) ·
SPY (benchmark)

## Architecture (planned)

```
yfinance (Python)  ->  CSV files
                         |
                         v
   Snowflake  RAW schema            (raw daily price rows, loaded in batches)
                         |
                         v
   dbt Cloud
     staging/  stg_prices                       (clean, renamed; source() defined)
     marts/    dim_securities                    (ticker -> name, sector)
               fct_daily_prices  [INCREMENTAL]   (grain: ticker + date)
               mart_daily_returns
               mart_moving_averages              (50 / 200-day)
               mart_sector_performance
                         |
                         v
   dbt tests (not_null, unique, relationships) + dbt docs (DAG lineage)
                         |
                         v
   Power BI  ->  dashboard on the mart tables
```

## Tech stack

- **Snowflake** — cloud data warehouse (raw + transformed layers)
- **dbt Cloud** — transformations, data tests, documentation and lineage
- **Power BI** — dashboard on the mart tables
- **Python** (`yfinance`, `pandas`) — data extraction

## Roadmap

- [x] Pull daily price data to CSV
- [ ] Load raw data to Snowflake
- [ ] dbt staging + mart models with tests
- [ ] Incremental daily-price fact model
- [ ] dbt docs / lineage graph
- [ ] Power BI dashboard

## Next steps / parked

_Deliberately out of scope for the first version; recorded here to keep it focused:_

- (to be filled in as the build progresses)
