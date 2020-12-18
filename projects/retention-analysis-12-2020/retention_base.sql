WITH miners AS (

  SELECT
    "to" AS address,
    value AS amount,
    date_trunc('week', evt_block_time) AS evt_block_week
   FROM erc20."ERC20_evt_Transfer"
   WHERE "from" IN ('\x8f06FBA4684B5E0988F215a47775Bb611Af0F986')
     AND contract_address = '\x0954906da0Bf32d5479e25f46056d22f08464cab'

),

transfers AS (

  SELECT
    tr."from" AS address,
    -tr.value AS amount,
    date_trunc('week', evt_block_time) AS evt_block_week
  FROM erc20."ERC20_evt_Transfer" tr
  WHERE contract_address = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b'

  UNION ALL

  SELECT
    tr."to" AS address,
    tr.value AS amount,
    date_trunc('week', evt_block_time) AS evt_block_week
  FROM erc20."ERC20_evt_Transfer" tr
  WHERE contract_address = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b'

),

moves AS (

  SELECT
    *
  FROM miners

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
