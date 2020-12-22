SELECT
  "to" as LP,
  sum(value/1e18) as INDEX_mined
FROM erc20."ERC20_evt_Transfer"
WHERE "from" IN ('\x8f06FBA4684B5E0988F215a47775Bb611Af0F986')
AND contract_address = '\x0954906da0Bf32d5479e25f46056d22f08464cab'
GROUP BY 1
ORDER BY 2 desc
LIMIT 100
