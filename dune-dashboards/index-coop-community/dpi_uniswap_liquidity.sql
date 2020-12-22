WITH mint_data as (

  SELECT
    (amount0/1e18) as dpi_amount,
    (amount1/1e18) as eth_amount,
    date_trunc('minute', m.evt_block_time) as day
  FROM uniswap_v2."Pair_evt_Mint" m
  WHERE m.contract_address = '\x4d5ef58aac27d99935e5b6b4a6778ff292059991'

),

burn_data as (

  SELECT
    (amount0/1e18) as dpi_amount,
    (amount1/1e18) as eth_amount,
    date_trunc('minute', evt_block_time) as day
  FROM uniswap_v2."Pair_evt_Burn"
  WHERE contract_address = '\x4d5ef58aac27d99935e5b6b4a6778ff292059991'

),

swap_data AS (

  SELECT
    ("amount0In" - "amount0Out")/1e18 as dpi_amount,
    ("amount1In" - "amount1Out")/1e18 as eth_amount,
    date_trunc('minute', evt_block_time) as day
  FROM uniswap_v2."Pair_evt_Swap"
  WHERE contract_address = '\x4d5ef58aac27d99935e5b6b4a6778ff292059991'

),

mint_grouped AS (

  SELECT
    day,
    SUM(mint_data.dpi_amount) as dpi_amount , SUM(mint_data.eth_amount) as eth_amount
  FROM mint_data
  GROUP BY 1

),

burn_grouped AS (

  SELECT
    day,
    SUM(-1*burn_data.dpi_amount) as dpi_amount,
    SUM(-1*burn_data.eth_amount) as eth_amount
  FROM burn_data
  GROUP BY 1

),


swap_grouped AS (

  SELECT
    day,
    SUM(swap_data.dpi_amount) as dpi_amount,
    SUM(swap_data.eth_amount) as eth_amount
  FROM swap_data
  GROUP BY 1

),

eth_difference AS (

  SELECT
    day,
    eth_amount
  FROM mint_grouped

  UNION

  SELECT
    day,
    eth_amount
  FROM burn_grouped

  UNION

  SELECT
    day,
    eth_amount
  FROM swap_grouped

),

eth_time AS (

  SELECT
    day,
    SUM(eth_amount) OVER (ORDER BY day) as eth_amt
  FROM eth_difference

),

eth_with_price AS (

  SELECT
    day,
    eth_amt * eth.price as eth_usd
  FROM eth_time t
  INNER JOIN prices."layer1_usd_eth" eth ON t.day = eth.minute

)

SELECT
  e.day,
  eth_usd + eth_usd as pair_usd
FROM eth_with_price e
WHERE e.day >= now() - interval '6 months'
