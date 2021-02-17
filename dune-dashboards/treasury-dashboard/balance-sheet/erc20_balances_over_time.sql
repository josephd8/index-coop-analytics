/* 
    Etherscan URL: https://etherscan.io/address/0x9467cfadc9de245010df95ec6a585a506a8ad5fc

    TO-DO: 
        1. Join with USD prices to get Dollar value of Treasury 
            - Requires Dune Analytics and CoinPaprika to add INDEX and DPI as assets
        2. Create combined ETH + ERC-20 query
        3. Join to a table of calendar dates to get latest balances by week, month, year, etc.

*/

WITH transfers AS (

    SELECT
        evt_block_time,
        evt_tx_hash AS tx_hash,
        tr."from" AS address,
        -tr.value AS amount,
        contract_address
    
    FROM erc20."ERC20_evt_Transfer" tr
    
    WHERE contract_address IN ('\x0954906da0bf32d5479e25f46056d22f08464cab', '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b')
     
UNION ALL

    SELECT
        evt_block_time,
        evt_tx_hash AS tx_hash,
        tr."to" AS address,
        tr.value AS amount,
        contract_address
    
    FROM erc20."ERC20_evt_Transfer" tr 
    
    where contract_address IN ('\x0954906da0bf32d5479e25f46056d22f08464cab', '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b')
     
)

, transfer_amounts AS (

    SELECT 
        evt_block_time,
        'Index Token Treasury' AS "wallet",
        address,
        
        CASE WHEN contract_address = '\x0954906da0bf32d5479e25f46056d22f08464cab' THEN 'INDEX'
             WHEN contract_address = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b' THEN 'DPI'
             END AS "assets",
        
        contract_address,
        sum(amount)/1e18 AS "units" 
    
    FROM transfers 
    
    GROUP BY 
        evt_block_time,
        address,
        contract_address,
        
        CASE WHEN contract_address = '\x0954906da0bf32d5479e25f46056d22f08464cab' THEN 'INDEX'
             WHEN contract_address = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b' THEN 'DPI'
             END
        
        
    ORDER BY "units" DESC
)

/* --- Main Query --- */
SELECT 
    tats.evt_block_time, 
    to_char(tats.evt_block_time, 'YYYY-MM') AS "Year-Month",
    tats.Wallet,
    tats.address,
    tats.Assets,
    tats.contract_address,
    tats.Units, 
    sum(tats.Units) OVER (PARTITION BY tats.Assets ORDER BY tats.evt_block_time ASC) AS Balance 
    
FROM transfer_amounts tats

WHERE address = '\x9467cfadc9de245010df95ec6a585a506a8ad5fc'

GROUP BY
    tats.Wallet,
    tats.address,
    tats.Assets,
    tats.contract_address,
    tats.Units, 
    tats.evt_block_time,
    to_char(tats.evt_block_time, 'YYYY-MM')
    
ORDER BY
    tats.Wallet,
    tats.address,
    tats.Assets,
    tats.contract_address,
    tats.evt_block_time ASC