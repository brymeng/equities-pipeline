with securities as (
    select * from {{ ref('securities') }}
)

select
    ticker,
    company_name,
    sector,
    ticker = 'SPY' as is_benchmark
from securities