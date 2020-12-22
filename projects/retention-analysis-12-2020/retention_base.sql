# this is the INDEX token, not DPI (from the Liquidity Mining Program)
# need to replace this with the mint and burn of DPI from
# setprotocol_v2."BasicIssuanceModule_evt_SetTokenIssued" &
# setprotocol_v2."BasicIssuanceModule_evt_SetTokenRedeemed"


WITH mint_and_burn AS (

  SELECT
    "_issuer" AS address,
    ("_quantity") / 1e18 AS amount,
    date_trunc('week', evt_block_time) AS evt_block_week,
    'mint' AS type
  FROM setprotocol_v2."BasicIssuanceModule_evt_SetTokenIssued"
  WHERE "_setToken" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b'

  UNION ALL

  SELECT
    "_redeemer" AS address,
    ("_quantity" * -1) / 1e18 AS amount,
    date_trunc('week', evt_block_time) AS evt_block_week,
    'burn' AS type
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
      WHEN tr."to" = '\x0bcaea3571448877ff875bc3825ccf54e5d04df0' THEN 'balancer_lp'
      WHEN tr."to" = '\x2a537fa9ffaea8c1a41d3c2b68a9cb791529366d' THEN 'cream'
      ELSE 'transfer'
    END AS type
  FROM erc20."ERC20_evt_Transfer" tr
  WHERE contract_address = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b'

  UNION ALL

  SELECT
    tr."to" AS address,
    tr.value / 1e18 AS amount,
    date_trunc('week', evt_block_time) AS evt_block_week,
    CASE
      WHEN tr."from" = '\x4d5ef58aac27d99935e5b6b4a6778ff292059991' THEN 'uniswap_lp'
      WHEN tr."from" = '\x0bcaea3571448877ff875bc3825ccf54e5d04df0' THEN 'balancer_lp'
      WHEN tr."from" = '\x2a537fa9ffaea8c1a41d3c2b68a9cb791529366d' THEN 'cream'
      ELSE 'transfer'
    END AS type
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

agg AS (

  SELECT
    address,
    evt_block_week,
    sum(amount) AS amount
  FROM moves
  WHERE type IN ('mint', 'burn', 'transfer')
  GROUP BY 1,2

),

dates AS (

  SELECT
    generate_series(date '2020-08-01', CURRENT_DATE, '1 week') AS dt

),

address_dates_comb AS (

  SELECT DISTINCT
    m.address,
    date_trunc('week', d.dt) as evt_block_week
  FROM moves AS m
  CROSS JOIN dates AS d

),

address_by_week AS (

  SELECT
    a.address,
    a.evt_block_week,
    CASE WHEN
      b.amount IS NULL THEN 0
      ELSE b.amount/1e18
    END AS amount
  FROM address_dates_comb a
  LEFT JOIN agg b ON a.address = b.address
  AND a.evt_block_week = b.evt_block_week

)

SELECT
  *
FROM address_by_week
ORDER BY 1, 2

-- SELECT DISTINCT
-- address
-- FROM address_by_week
-- ORDER BY 1, 2
