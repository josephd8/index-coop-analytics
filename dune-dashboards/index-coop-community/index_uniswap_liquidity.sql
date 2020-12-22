WITH mint_data as (
  SELECT
    (amount0/1e18) as index_amount,
    (amount1/1e18) as eth_amount,
    date_trunc('minute', m.evt_block_time) as day
  FROM uniswap_v2."Pair_evt_Mint" m
  WHERE m.contract_address = '\x3452a7f30a712e415a0674c0341d44ee9d9786f9'

),

burn_data as (

  SELECT
    (amount0/1e18) as index_amount,
    (amount1/1e18) as eth_amount,
    date_trunc('minute', evt_block_time) as day
  FROM uniswap_v2."Pair_evt_Burn"
  WHERE contract_address = '\x3452a7f30a712e415a0674c0341d44ee9d9786f9'

),

swap_data AS (

  SELECT
    ("amount0In" - "amount0Out")/1e18 as index_amount,
    ("amount1In" - "amount1Out")/1e18 as eth_amount,
    date_trunc('minute', evt_block_time) as day
  FROM uniswap_v2."Pair_evt_Swap"
  WHERE contract_address = '\x3452a7f30a712e415a0674c0341d44ee9d9786f9'

),

mint_grouped AS (

  SELECT
    day,
    SUM(mint_data.index_amount) as index_amount ,
    SUM(mint_data.eth_amount) as eth_amount
  FROM mint_data
  GROUP BY 1

),

burn_grouped AS (

  SELECT
    day,
    SUM(-1*burn_data.index_amount) as index_amount,
    SUM(-1*burn_data.eth_amount) as eth_amount
  FROM burn_data
  GROUP BY 1

),


swap_grouped AS (

  SELECT
    day,
    SUM(swap_data.index_amount) as index_amount,
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

eth_time as (

  SELECT
    day,
    SUM(eth_amount) OVER (ORDER BY day) as eth_amt
  FROM eth_difference

),

eth_with_price as (

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
