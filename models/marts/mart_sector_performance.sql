with returns as (
    select
        ticker,
        price_date,
        daily_return
    from {{ ref('mart_daily_returns') }}
    where daily_return is not null
),

securities as (
    select
        ticker,
        sector
    from {{ ref('dim_securities') }}
),

sector_daily as (
    select
        s.sector,
        r.price_date,
        count(*)            as num_securities,
        avg(r.daily_return) as sector_daily_return
    from returns r
    join securities s
        on r.ticker = s.ticker
    group by s.sector, r.price_date
)

select
    sector,
    price_date,
    num_securities,
    sector_daily_return,
    exp(sum(ln(1 + sector_daily_return)) over (
        partition by sector
        order by price_date
        rows between unbounded preceding and current row
    )) - 1 as cumulative_return
from sector_daily