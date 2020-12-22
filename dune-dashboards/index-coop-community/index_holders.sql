WITH transfers AS (

    SELECT
      evt_tx_hash AS tx_hash,
      tr."from" AS address,
      -tr.value AS amount,
      contract_address
    FROM erc20."ERC20_evt_Transfer" tr
    WHERE contract_address =  '\x0954906da0bf32d5479e25f46056d22f08464cab'

    UNION ALL

    SELECT
      evt_tx_hash AS tx_hash,
      tr."to" AS address,
      tr.value AS amount,
      contract_address
    FROM erc20."ERC20_evt_Transfer" tr
    WHERE contract_address = '\x0954906da0bf32d5479e25f46056d22f08464cab'
),

transferAmounts AS (

    SELECT
      address,
      sum(amount)/1e18 as poolholdings
    FROM transfers
    GROUP BY 1
    ORDER BY 2 DESC

)

SELECT
  COUNT(DISTINCT(address)) as holders
FROM transferAmounts
WHERE poolholdings > 0
