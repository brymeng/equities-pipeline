{{
    config(
        materialized='incremental',
        unique_key='price_key',
        incremental_strategy='merge'
    )
}}

select
    ticker || '-' || to_char(price_date, 'YYYY-MM-DD')  as price_key,
    ticker,
    price_date,
    open_price,
    high_price,
    low_price,
    close_price,
    adj_close_price,
    volume,
    current_timestamp()                                  as dbt_loaded_at
from {{ ref('stg_prices') }}

{% if is_incremental() %}
where price_date > (select max(price_date) from {{ this }})
{% endif %}