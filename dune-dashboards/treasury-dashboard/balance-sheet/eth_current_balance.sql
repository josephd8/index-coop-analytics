/* 
    Etherscan URL: https://etherscan.io/address/0x9467cfadc9de245010df95ec6a585a506a8ad5fc

*/


SELECT address, sum(amount) / 1e18 as amount
FROM (

    -- outbound transfers
    SELECT "from" AS address, -tr.value AS amount
    FROM ethereum.traces tr
    WHERE "from" = '\x9467cfadc9de245010df95ec6a585a506a8ad5fc'
    AND success
    AND (call_type NOT IN ('delegatecall', 'callcode', 'staticcall') OR call_type IS null)


    UNION ALL

    -- inbound transfers
    SELECT "to" AS address, value AS amount
    FROM ethereum.traces
    WHERE "to" = '\x9467cfadc9de245010df95ec6a585a506a8ad5fc'
    AND success
    AND (call_type NOT IN ('delegatecall', 'callcode', 'staticcall') OR call_type IS null)

    UNION ALL
    
    -- gas costs
    SELECT "from" AS address, -gas_used * gas_price AS amount
    FROM ethereum.transactions
    WHERE "from" = '\x9467cfadc9de245010df95ec6a585a506a8ad5fc'
    
) t
GROUP BY 1