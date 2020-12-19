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
      WHEN tr."to" = '\x4d5ef58aac27d99935e5b6b4a6778ff292059991' THEN 'uniswap_lp'
      WHEN tr."to" = '\x0bcaea3571448877ff875bc3825ccf54e5d04df0' THEN 'balancer_pool'
      WHEN tr."to" = '\x2a537fa9ffaea8c1a41d3c2b68a9cb791529366d' THEN 'cream'
      WHEN tr."to" = '\x34b13f8cd184f55d0bd4dd1fe6c07d46f245c7ed' THEN 'sushi_lp'
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
      WHEN tr."from" = '\x4d5ef58aac27d99935e5b6b4a6778ff292059991' THEN 'uniswap_lp'
      WHEN tr."from" = '\x0bcaea3571448877ff875bc3825ccf54e5d04df0' THEN 'balancer_pool'
      WHEN tr."from" = '\x2a537fa9ffaea8c1a41d3c2b68a9cb791529366d' THEN 'cream'
      WHEN tr."from" = '\x34b13f8cd184f55d0bd4dd1fe6c07d46f245c7ed' THEN 'sushi_lp'
      ELSE 'transfer'
    END AS type,
    evt_tx_hash
  FROM erc20."ERC20_evt_Transfer" tr
  WHERE contract_address = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b'

),

moves AS (

  SELECT
    *
  FROM mint_and_burn

  UNION ALL

  SELECT
    *
  FROM transfers

),

transferAmounts AS (

    SELECT
      address,
      sum(amount) AS holdings
    FROM moves
    WHERE type IN ('mint', 'burn', 'transfer')
    GROUP BY 1
    ORDER BY 2 DESC

)

SELECT
  COUNT(DISTINCT(address)) as holders
FROM transferAmounts
WHERE holdings > 0
