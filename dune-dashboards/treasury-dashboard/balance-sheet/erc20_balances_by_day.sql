/* 
    Etherscan URL: https://etherscan.io/address/0x9467cfadc9de245010df95ec6a585a506a8ad5fc

    TO-DO: 
        1. Join with USD prices to get Dollar value of Treasury 
            - Requires Dune Analytics and CoinPaprika to add INDEX and DPI as assets
        2. Create combined ETH + ERC-20 query

*/

WITH transfers AS (

    SELECT
        date_trunc('day', evt_block_time) AS day,
        evt_tx_hash AS tx_hash,
        tr."from" AS address,
        -tr.value AS amount,
        contract_address
    
    FROM erc20."ERC20_evt_Transfer" tr
    
    WHERE contract_address IN ('\x0954906da0bf32d5479e25f46056d22f08464cab', '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b')
     
UNION ALL

    SELECT
        date_trunc('day', evt_block_time) AS day,
        evt_tx_hash AS tx_hash,
        tr."to" AS address,
        tr.value AS amount,
        contract_address
    
    FROM erc20."ERC20_evt_Transfer" tr 
    
    where contract_address IN ('\x0954906da0bf32d5479e25f46056d22f08464cab', '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b')
     
)

, transfer_amounts AS (

    SELECT 
        day,
        'Index Token Treasury' AS "wallet",
        address,
        
        CASE WHEN contract_address = '\x0954906da0bf32d5479e25f46056d22f08464cab' THEN 'INDEX'
             WHEN contract_address = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b' THEN 'DPI'
             END AS "assets",
        
        contract_address,
        sum(amount)/1e18 AS "units" 
    
    FROM transfers 
    
    GROUP BY 
        day,
        address,
        contract_address,
        
        CASE WHEN contract_address = '\x0954906da0bf32d5479e25f46056d22f08464cab' THEN 'INDEX'
             WHEN contract_address = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b' THEN 'DPI'
             END
        
        
    ORDER BY "units" DESC
)


, days AS (

    SELECT generate_series('2020-07-01'::timestamp, date_trunc('day', NOW()), '1 day') AS day -- Generate all days since the first contract

)


, balances_with_gap_days AS (

    SELECT  t.day,
            t.wallet,
            address,
            t.contract_address,
            t.assets,
            SUM(units) OVER (PARTITION BY contract_address, address ORDER BY t.day) AS balance, -- balance per day with a transfer
            lead(day, 1, now()) OVER (PARTITION BY contract_address, address ORDER BY t.day) AS next_day -- the day after a day with a transfer
            
    FROM transfer_amounts t
    
)

, balance_all_days AS (
    SELECT  d.day,
            b.wallet,
            b.address,
            --erc.symbol,
            b.contract_address,
            b.assets,
            SUM(balance) AS balance
    FROM balances_with_gap_days b
    INNER JOIN days d ON b.day <= d.day AND d.day < b.next_day -- Yields an observation for every day after the first transfer until the next day with transfer
    --INNER JOIN erc20.tokens erc ON b.contract_address = erc.contract_address
    GROUP BY d.day, b.wallet,b.address, b.contract_address, b.assets
    ORDER BY b.assets, d.day DESC 
    )


/* --- Main Query --- */

SELECT *

FROM balance_all_days

WHERE address = '\x9467cfadc9de245010df95ec6a585a506a8ad5fc'

