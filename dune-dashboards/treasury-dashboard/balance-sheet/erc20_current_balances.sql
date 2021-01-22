/* 
    Etherscan URL: https://etherscan.io/address/0x9467cfadc9de245010df95ec6a585a506a8ad5fc

*/

WITH transfers AS (

    SELECT
        --evt_block_time,
        evt_tx_hash AS tx_hash,
        tr."from" AS address,
        -tr.value AS amount,
        contract_address
    
    FROM erc20."ERC20_evt_Transfer" tr
    
    WHERE contract_address IN ('\x0954906da0bf32d5479e25f46056d22f08464cab', '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b')
     
UNION ALL

    SELECT
        --evt_block_time,    
        evt_tx_hash AS tx_hash,
        tr."to" AS address,
        tr.value AS amount,
        contract_address
    
    FROM erc20."ERC20_evt_Transfer" tr 
    
    where contract_address IN ('\x0954906da0bf32d5479e25f46056d22f08464cab', '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b')
     
)

, transfer_amounts AS (

    SELECT 
        --evt_block_time,    
        'Index Token Treasury' AS "Wallet",
        address,
        
        CASE WHEN contract_address = '\x0954906da0bf32d5479e25f46056d22f08464cab' THEN 'INDEX'
             WHEN contract_address = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b' THEN 'DPI'
             END AS "Assets",
        
        contract_address,
        sum(amount)/1e18 AS "Units" 
    
    FROM transfers 
    
    GROUP BY 
        --evt_block_time,
        address,
        contract_address,
        
        CASE WHEN contract_address = '\x0954906da0bf32d5479e25f46056d22f08464cab' THEN 'INDEX'
             WHEN contract_address = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b' THEN 'DPI'
             END 
        
        
    ORDER BY "Units" DESC
)

SELECT *

FROM transfer_amounts tats

WHERE address = '\x9467cfadc9de245010df95ec6a585a506a8ad5fc'
