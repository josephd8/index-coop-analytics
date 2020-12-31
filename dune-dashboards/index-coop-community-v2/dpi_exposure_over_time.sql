WITH transfers AS (

  SELECT
    tr."from" AS address,
    -tr.value / 1e18 AS amount,
    date_trunc('week', evt_block_time) AS evt_block_week,
    CASE
      -- WHEN tr."to" = '\x4d5ef58aac27d99935e5b6b4a6778ff292059991' THEN 'uniswap_lp'
      WHEN tr."to" = '\x0bcaea3571448877ff875bc3825ccf54e5d04df0' THEN 'balancer_pool'
      WHEN tr."to" = '\x2a537fa9ffaea8c1a41d3c2b68a9cb791529366d' THEN 'cream'
      -- WHEN tr."to" = '\x34b13f8cd184f55d0bd4dd1fe6c07d46f245c7ed' THEN 'sushi_lp'
      ELSE 'transfer'
    END AS type,
    evt_tx_hash
  FROM erc20."ERC20_evt_Transfer" tr
  WHERE contract_address = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b'

  UNION ALL

  SELECT
    tr."to" AS address,
    tr.value / 1e18 AS amount,
    date_trunc('week', evt_block_time) AS evt_block_week,
    CASE
      -- WHEN tr."from" = '\x4d5ef58aac27d99935e5b6b4a6778ff292059991' THEN 'uniswap_lp'
      WHEN tr."from" = '\x0bcaea3571448877ff875bc3825ccf54e5d04df0' THEN 'balancer_pool'
      WHEN tr."from" = '\x2a537fa9ffaea8c1a41d3c2b68a9cb791529366d' THEN 'cream'
      -- WHEN tr."from" = '\x34b13f8cd184f55d0bd4dd1fe6c07d46f245c7ed' THEN 'sushi_lp'
      ELSE 'transfer'
    END AS type,
    evt_tx_hash
  FROM erc20."ERC20_evt_Transfer" tr
  WHERE contract_address = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b'

),

uniswap AS (

  SELECT
    sender AS address,
    (amount0/1e18) AS amount,
    date_trunc('week', evt_block_time) AS evt_block_week,
    'uniswap_mint' AS type,
    evt_tx_hash
  FROM uniswap_v2."Pair_evt_Mint"
  WHERE contract_address = '\x4d5ef58aac27d99935e5b6b4a6778ff292059991'

  UNION ALL

  SELECT
    "to" AS address,
    -(amount0/1e18) AS amount,
    date_trunc('week', evt_block_time) AS evt_block_week,
    'uniswap_burn' AS type,
    evt_tx_hash
  FROM uniswap_v2."Pair_evt_Burn"
  WHERE contract_address = '\x4d5ef58aac27d99935e5b6b4a6778ff292059991'
      AND "to" != '\x7a250d5630B4cF539739dF2C5dAcb4c659F2488D'

),

sushi AS (

  SELECT
    sender AS address,
    (amount0/1e18) AS amount,
    date_trunc('week', evt_block_time) AS evt_block_week,
    'sushi_mint' AS type,
    evt_tx_hash
  FROM sushi."Pair_evt_Mint"
  WHERE contract_address = '\x34b13f8cd184f55d0bd4dd1fe6c07d46f245c7ed'

  UNION ALL

  SELECT
    "to" AS address,
    -(amount0/1e18) AS amount,
    date_trunc('week', evt_block_time) AS evt_block_week,
    'sushi_burn' AS type,
    evt_tx_hash
  FROM sushi."Pair_evt_Burn"
  WHERE contract_address = '\x34b13f8cd184f55d0bd4dd1fe6c07d46f245c7ed'
    AND "to" != '\xd9e1ce17f2641f24ae83637ab66a2cca9c378b9f'

),

sushi_add AS (

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

liquidity_providing AS (

  SELECT
    l.*,
    CASE c.type
      WHEN 'contract_name' THEN 'contract'
      ELSE 'non-contract'
    END AS contract
  FROM lp l
  LEFT JOIN contracts c ON l.address = c.address

),

moves AS (

  SELECT
    *
  FROM transfers

  UNION ALL

  SELECT
    address,
    amount,
    evt_block_week,
    type,
    evt_tx_hash
  FROM liquidity_providing
  WHERE contract = 'non-contract'

),

exposure AS (

    SELECT
      m.address,
      evt_block_week,
      sum(amount) AS exposure
    FROM moves m
    LEFT JOIN contracts c ON m.address = c.address
    WHERE c.type IS NULL
      AND m.type IN ('mint', 'burn', 'transfer',
      'uniswap_add', 'uniswap_remove', 'sushi_add', 'sushi_remove')
    GROUP BY 1, 2
    ORDER BY 1, 2

),

address_by_date  AS (

    SELECT
        DISTINCT
        t1.address,
        t2.evt_block_week
    FROM exposure t1
    CROSS JOIN (
        SELECT
            DISTINCT(evt_block_week)
        FROM exposure
    ) t2

),

temp AS (

  SELECT
    a.address,
    a.evt_block_week,
    CASE e.exposure
        WHEN NULL THEN 0
        ELSE e.exposure
    END AS exposure
  FROM address_by_date a
  LEFT JOIN exposure e ON a.address = e.address AND a.evt_block_week = e.evt_block_week

),

address_over_time AS (

    SELECT
        address,
        evt_block_week,
        sum(exposure) OVER (PARTITION BY address ORDER BY evt_block_week ASC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS exposure
    FROM temp

)

SELECT
    evt_block_week,
    COUNT(DISTINCT(address))
FROM address_over_time
WHERE exposure > 0
GROUP BY 1
