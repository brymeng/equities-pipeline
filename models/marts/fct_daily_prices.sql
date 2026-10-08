select
    ticker || '-' || to_char(price_date, 'YYYY-MM-DD')  as price_key,
    ticker,
    price_date,
    open_price,
    high_price,
    low_price,
    close_price,
    adj_close_price,
    volume
from {{ ref('stg_prices') }}