WITH miners AS (

    SELECT DISTINCT
      count(DISTINCT("to")) as LP
    FROM erc20."ERC20_evt_Transfer"
    WHERE "from" IN ('\x8f06FBA4684B5E0988F215a47775Bb611Af0F986')
      AND contract_address = '\x0954906da0Bf32d5479e25f46056d22f08464cab'

),

transfers AS (

    SELECT
      evt_tx_hash AS tx_hash,
      tr."from" AS address,
      -tr.value AS amount,
      contract_address
    FROM erc20."ERC20_evt_Transfer" tr
      WHERE contract_address =  '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b'

UNION ALL

    SELECT
      evt_tx_hash AS tx_hash,
      tr."to" AS address,
      tr.value AS amount,
      contract_address
    FROM erc20."ERC20_evt_Transfer" tr
    WHERE contract_address = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b'

),

transferAmounts AS (

    SELECT
      address,
      sum(amount)/1e18 as holdings FROM transfers
    GROUP BY 1
    ORDER BY 2 DESC
)

SELECT (
    SELECT
      COUNT(DISTINCT(address)) as holders
    FROM transferAmounts
    WHERE holdings > 0
) + LP
FROM miners;
