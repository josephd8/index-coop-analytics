WITH mint_and_burn AS (

  SELECT
    "_issuer" AS address,
    ("_quantity") / 1e18 AS amount,
    date_trunc('week', evt_block_time) AS evt_block_week,
    'mint' AS type,
    evt_tx_hash
  FROM setprotocol_v2."BasicIssuanceModule_evt_SetTokenIssued"
  WHERE "_setToken" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b'

  UNION ALL

  SELECT
    "_redeemer" AS address,
    ("_quantity" * -1) / 1e18 AS amount,
    date_trunc('week', evt_block_time) AS evt_block_week,
    'burn' AS type,
    evt_tx_hash
  FROM setprotocol_v2."BasicIssuanceModule_evt_SetTokenRedeemed"
  WHERE "_setToken" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b'

),

transfers AS (

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

moves AS (

  SELECT
    *
  FROM mint_and_burn

  UNION ALL

  SELECT
    *
  FROM transfers

  UNION ALL

  SELECT
    *
  FROM uniswap

  UNION ALL

  SELECT
    *
  FROM sushi

),

exposure AS (

    SELECT
      address,
      evt_block_week,
      sum(amount) AS exposure
    FROM moves
    WHERE type IN ('mint', 'burn', 'transfer',
      'uniswap_mint', 'uniswap_burn', 'sushi_mint', 'sushi_burn')
    GROUP BY 1, 2
    ORDER BY 1, 2

)

SELECT
  *
FROM exposure
