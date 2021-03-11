WITH pairs AS (

  SELECT
    token0,
    erc20.decimals as decimals0,
    erc20.symbol as symbol0,
    token1,
    erc202.decimals as decimals1,
    erc202.symbol as symbol1,
    pair
  FROM uniswap_v2."Factory_evt_PairCreated" pairsraw
  LEFT JOIN erc20.tokens erc20 ON pairsraw.token0 = erc20.contract_address
  LEFT JOIN erc20.tokens erc202 ON pairsraw.token1 = erc202.contract_address
  WHERE token0 IN (SELECT DISTINCT contract_address FROM erc20.tokens WHERE decimals > 0)
    AND token1 IN (SELECT DISTINCT contract_address FROM erc20.tokens WHERE decimals > 0)

),

reserves AS (

  SELECT
    AVG(reserve0) AS reserve0,
    AVG(reserve1) AS reserve1,
    contract_address,
    date_trunc('day', evt_block_time) AS dt
  FROM uniswap_v2."Pair_evt_Sync" sync
  WHERE contract_address IN (SELECT DISTINCT pair FROM pairs)
  GROUP BY 3, 4

),

liquidity AS (

  SELECT
      r.*,
      p.*,
      r.reserve0 / 10^p.decimals0 AS amount0,
      r.reserve1 / 10^p.decimals1 AS amount1,
      u0.price AS token0_price,
      u1.price AS token1_price
  FROM reserves r
  INNER JOIN pairs p
      ON r.contract_address = p.pair
  LEFT JOIN prices.usd u0
      ON p.token0 = u0.contract_address AND r.dt = u0.minute
  LEFT JOIN prices.usd u1
      ON p.token1 = u1.contract_address AND r.dt = u1.minute

),

token0 AS (

  SELECT
    dt,
    pair,
    token0 AS token,
    amount0 AS amount,
    token0_price AS price,
    CASE
      WHEN token0_price IS NOT NULL THEN token0_price * amount0 * 2
      WHEN token1_price IS NOT NULL THEN token1_price * amount1 * 2
      ELSE NULL
    END AS liquidity
  FROM liquidity

),

token1 AS (

  SELECT
    dt,
    pair,
    token1 AS token,
    amount1 AS amount,
    token1_price AS price,
    CASE
      WHEN token1_price IS NOT NULL THEN token1_price * amount1 * 2
      WHEN token0_price IS NOT NULL THEN token0_price * amount0 * 2
      ELSE NULL
    END AS liquidity
  FROM liquidity

),

token_liquidity AS (

  SELECT
    *
  FROM token0

  UNION

  SELECT
    *
  FROM token1

)



-- need to aggregate at the token level
-- need to add ability to filter by contract address
-- start out with a chart of aggregate uniswap liquidity over time
