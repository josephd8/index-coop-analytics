WITH sushi_add AS (

  SELECT
    "to" AS address,
    ("output_amountToken"/1e18) AS amount,
    date_trunc('week', call_block_time) AS evt_block_week,
    'sushi_add' AS type,
    call_tx_hash AS evt_tx_hash
  FROM sushi."Router02_call_addLiquidityETH"
  WHERE token = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b'

  UNION ALL

  SELECT
    "to" AS address,
    CASE
      WHEN "tokenA" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b' THEN ("output_amountA"/1e18)
      WHEN "tokenB" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b' THEN ("output_amountB"/1e18)
      ELSE 0
    END AS amount,
    date_trunc('week', call_block_time) AS evt_block_week,
    'sushi_add' AS type,
    call_tx_hash AS evt_tx_hash
  FROM sushi."Router02_call_addLiquidity"
  WHERE "tokenA" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b'
    OR "tokenB" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b'

),

sushi_remove AS (

  SELECT
    "to" AS address,
    -("output_amountToken"/1e18) AS amount,
    date_trunc('week', call_block_time) AS evt_block_week,
    'sushi_remove' AS type,
    call_tx_hash AS evt_tx_hash
  FROM sushi."Router02_call_removeLiquidityETH"
  WHERE token = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b'

  UNION ALL

  SELECT
    "to" AS address,
    -("output_amountToken"/1e18) AS amount,
    date_trunc('week', call_block_time) AS evt_block_week,
    'sushi_remove' AS type,
    call_tx_hash AS evt_tx_hash
  FROM sushi."Router02_call_removeLiquidityETHWithPermit"
  WHERE token = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b'

  UNION ALL

  SELECT
    "to" AS address,
    CASE
      WHEN "tokenA" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b' THEN -("output_amountA"/1e18)
      WHEN "tokenB" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b' THEN -("output_amountB"/1e18)
      ELSE 0
    END AS amount,
    date_trunc('week', call_block_time) AS evt_block_week,
    'sushi_remove' AS type,
    call_tx_hash AS evt_tx_hash
  FROM sushi."Router02_call_removeLiquidity"
  WHERE "tokenA" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b'
    OR "tokenB" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b'

  UNION ALL

  SELECT
    "to" AS address,
    CASE
      WHEN "tokenA" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b' THEN -("output_amountA"/1e18)
      WHEN "tokenB" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b' THEN -("output_amountB"/1e18)
      ELSE 0
    END AS amount,
    date_trunc('week', call_block_time) AS evt_block_week,
    'sushi_remove' AS type,
    call_tx_hash AS evt_tx_hash
  FROM sushi."Router02_call_removeLiquidityWithPermit"
  WHERE "tokenA" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b'
    OR "tokenB" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b'

),

uniswap_add AS (

  SELECT
    "to" AS address,
    ("output_amountToken"/1e18) AS amount,
    date_trunc('week', call_block_time) AS evt_block_week,
    'uniswap_add' AS type,
    call_tx_hash AS evt_tx_hash
  FROM uniswap_v2."Router02_call_addLiquidityETH"
  WHERE token = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b'

  UNION ALL

  SELECT
    "to" AS address,
    CASE
      WHEN "tokenA" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b' THEN ("output_amountA"/1e18)
      WHEN "tokenB" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b' THEN ("output_amountB"/1e18)
      ELSE 0
    END AS amount,
    date_trunc('week', call_block_time) AS evt_block_week,
    'uniswap_add' AS type,
    call_tx_hash AS evt_tx_hash
  FROM uniswap_v2."Router01_call_addLiquidity"
  WHERE "tokenA" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b'
    OR "tokenB" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b'

  UNION ALL

  SELECT
    "to" AS address,
    CASE
      WHEN "tokenA" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b' THEN ("output_amountA"/1e18)
      WHEN "tokenB" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b' THEN ("output_amountB"/1e18)
      ELSE 0
    END AS amount,
    date_trunc('week', call_block_time) AS evt_block_week,
    'uniswap_add' AS type,
    call_tx_hash AS evt_tx_hash
  FROM uniswap_v2."Router02_call_addLiquidity"
  WHERE "tokenA" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b'
    OR "tokenB" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b'

),

uniswap_remove AS (

  SELECT
    "to" AS address,
    -("output_amountToken"/1e18) AS amount,
    date_trunc('week', call_block_time) AS evt_block_week,
    'uniswap_remove' AS type,
    call_tx_hash AS evt_tx_hash
  FROM uniswap_v2."Router02_call_removeLiquidityETHWithPermit"
  WHERE token = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b'

  UNION ALL

  SELECT
    "to" AS address,
    -("output_amountToken"/1e18) AS amount,
    date_trunc('week', call_block_time) AS evt_block_week,
    'uniswap_remove' AS type,
    call_tx_hash AS evt_tx_hash
  FROM uniswap_v2."Router02_call_removeLiquidityETH"
  WHERE token = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b'

  UNION ALL

  SELECT
    "to" AS address,
    CASE
      WHEN "tokenA" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b' THEN -("output_amountA"/1e18)
      WHEN "tokenB" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b' THEN -("output_amountB"/1e18)
      ELSE 0
    END AS amount,
    date_trunc('week', call_block_time) AS evt_block_week,
    'uniswap_remove' AS type,
    call_tx_hash AS evt_tx_hash
  FROM uniswap_v2."Router01_call_removeLiquidity"
  WHERE "tokenA" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b'
    OR "tokenB" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b'

  UNION ALL

  SELECT
    "to" AS address,
    CASE
      WHEN "tokenA" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b' THEN -("output_amountA"/1e18)
      WHEN "tokenB" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b' THEN -("output_amountB"/1e18)
      ELSE 0
    END AS amount,
    date_trunc('week', call_block_time) AS evt_block_week,
    'uniswap_remove' AS type,
    call_tx_hash AS evt_tx_hash
  FROM uniswap_v2."Router02_call_removeLiquidity"
  WHERE "tokenA" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b'
    OR "tokenB" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b'

  UNION ALL

  SELECT
    "to" AS address,
    CASE
      WHEN "tokenA" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b' THEN -("output_amountA"/1e18)
      WHEN "tokenB" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b' THEN -("output_amountB"/1e18)
      ELSE 0
    END AS amount,
    date_trunc('week', call_block_time) AS evt_block_week,
    'uniswap_remove' AS type,
    call_tx_hash AS evt_tx_hash
  FROM uniswap_v2."Router02_call_removeLiquidityWithPermit"
  WHERE "tokenA" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b'
    OR "tokenB" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b'

),

lp AS (

  SELECT
    *
  FROM sushi_add

  UNION ALL

  SELECT
    *
  FROM sushi_remove

  UNION ALL

  SELECT
    *
  FROM uniswap_add

  UNION ALL

  SELECT
    *
  FROM uniswap_remove

),

contracts AS (

  SELECT
    address,
    "type"
  FROM labels.labels
  WHERE "type" = 'contract_name'

),

temp AS (

  SELECT
    l.*,
    CASE c.type
      WHEN 'contract_name' THEN 'contract'
      ELSE 'non-contract'
    END AS contract
  FROM lp l
  LEFT JOIN contracts c ON l.address = c.address

)

SELECT * FROM temp


-- SUSHI ADD LIQUIDITY

-- SELECT
-- *
-- FROM sushi."Router02_call_addLiquidityETH"
-- WHERE token = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b'

-- SELECT
-- *
-- FROM sushi."Router02_call_addLiquidity"
-- WHERE "tokenA" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b' OR "tokenB" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b'

-- SUSHI REMOVE LIQUIDITY

-- SELECT
-- *
-- FROM sushi."Router02_call_removeLiquidityETH"
-- WHERE token = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b'

-- SELECT
-- *
-- FROM sushi."Router02_call_removeLiquidityETHWithPermit"
-- WHERE token = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b'

-- SELECT
-- *
-- FROM sushi."Router02_call_removeLiquidity"
-- WHERE "tokenA" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b' OR "tokenB" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b'

-- SELECT
-- *
-- FROM sushi."Router02_call_removeLiquidityWithPermit"
-- WHERE "tokenA" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b' OR "tokenB" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b'

-- UNISWAP ADD LIQUIDITY

-- SELECT
-- *
-- FROM uniswap_v2."Router01_call_addLiquidity"
-- WHERE "tokenA" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b' OR "tokenB" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b'

-- SELECT
-- *
-- FROM uniswap_v2."Router02_call_addLiquidity"
-- WHERE "tokenA" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b' OR "tokenB" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b'

-- SELECT
-- *
-- FROM uniswap_v2."Router02_call_addLiquidityETH"
-- WHERE token = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b'

-- UNISWAP REMOVE LIQUIDITY

-- SELECT
-- *
-- FROM uniswap_v2."Router02_call_removeLiquidityETHWithPermit"
-- WHERE token = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b'

-- SELECT
-- *
-- FROM uniswap_v2."Router02_call_removeLiquidityETH"
-- WHERE token = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b'

-- SELECT
-- *
-- FROM uniswap_v2."Router01_call_removeLiquidity"
-- WHERE "tokenA" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b' OR "tokenB" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b'

-- SELECT
-- *
-- FROM uniswap_v2."Router02_call_removeLiquidity"
-- WHERE "tokenA" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b' OR "tokenB" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b'

-- SELECT
-- *
-- FROM uniswap_v2."Router02_call_removeLiquidityWithPermit"
-- WHERE "tokenA" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b' OR "tokenB" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b'



-- Aggregated: uniswap."view_add_liquidity", uniswap."view_remove_liquidity" (https://github.com/duneanalytics/abstractions/blob/master/schema/uniswap/view_add_liquidity.sql & https://github.com/duneanalytics/abstractions/blob/master/schema/uniswap/view_remove_liquidity.sql)
