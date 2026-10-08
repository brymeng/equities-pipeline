with prices as (
    select
        ticker,
        price_date,
        adj_close_price
    from {{ ref('fct_daily_prices') }}
),

windowed as (
    select
        ticker,
        price_date,
        adj_close_price,

        avg(adj_close_price) over (
            partition by ticker order by price_date
            rows between 49 preceding and current row
        ) as ma_50_raw,
        count(adj_close_price) over (
            partition by ticker order by price_date
            rows between 49 preceding and current row
        ) as n_50,

        avg(adj_close_price) over (
            partition by ticker order by price_date
            rows between 199 preceding and current row
        ) as ma_200_raw,
        count(adj_close_price) over (
            partition by ticker order by price_date
            rows between 199 preceding and current row
        ) as n_200
    from prices
)

select
    ticker,
    price_date,
    adj_close_price,
    case when n_50  = 50  then ma_50_raw  end as ma_50,
    case when n_200 = 200 then ma_200_raw end as ma_200
from windowed