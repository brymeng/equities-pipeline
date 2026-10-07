with prices as (
    select
        ticker,
        price_date,
        adj_close_price
    from {{ ref('fct_daily_prices') }}
),

with_prev as (
    select
        ticker,
        price_date,
        adj_close_price,
        lag(adj_close_price) over (
            partition by ticker
            order by price_date
        ) as prev_adj_close_price
    from prices
)

select
    ticker,
    price_date,
    adj_close_price,
    prev_adj_close_price,
    adj_close_price / nullif(prev_adj_close_price, 0) - 1 as daily_return
from with_prev