with source as (
    select * from {{ source('raw', 'raw_daily_prices') }}
),

renamed as (
    select
        upper(trim(ticker))     as ticker,
        date                    as price_date,
        round(open, 4)          as open_price,
        round(high, 4)          as high_price,
        round(low, 4)           as low_price,
        round(close, 4)         as close_price,
        round(adj_close, 4)     as adj_close_price,
        volume::number(38,0)    as volume
    from source
)

select * from renamed