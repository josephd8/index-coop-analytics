WITH transfers AS (

    SELECT
        tr.evt_block_time,
        tr.evt_tx_hash AS tx_hash,
        tr."from" AS address,
        -tr.value AS amount,
        tr.contract_address
    
    FROM erc20."ERC20_evt_Transfer" tr
    
    WHERE 
    tr.contract_address IN ('\x0954906da0bf32d5479e25f46056d22f08464cab', '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b')
     
UNION ALL

    SELECT
        evt_block_time,
        evt_tx_hash AS tx_hash,
        tr."to" AS address,
        tr.value AS amount,
        tr.contract_address
    
    FROM erc20."ERC20_evt_Transfer" tr 
    
    WHERE tr.contract_address IN ('\x0954906da0bf32d5479e25f46056d22f08464cab', '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b')
     
)

, transfer_amounts AS (

    SELECT 
        --evt_block_time,    
        CASE 
            WHEN address = '\x9467cfadc9de245010df95ec6a585a506a8ad5fc' THEN 'Index Treasury' 
            WHEN address = '\xe2250424378b6a6dC912f5714cfd308a8D593986' THEN 'Index Treasury Committee'
            WHEN address = '\x26e316f5b3819264DF013Ccf47989Fb8C891b088' THEN 'Community Treasury Year 1 Vesting'
            END AS "wallet",
        address as wallet_address, 
        contract_address,
        sum(amount)/1e18 AS "units"
    
    FROM transfers 
    
    GROUP BY 
        CASE 
            WHEN address = '\x9467cfadc9de245010df95ec6a585a506a8ad5fc' THEN 'Index Treasury' 
            WHEN address = '\xe2250424378b6a6dC912f5714cfd308a8D593986' THEN 'Index Treasury Committee'
            WHEN address = '\x26e316f5b3819264DF013Ccf47989Fb8C891b088' THEN 'Community Treasury Year 1 Vesting'
            END,
        address,
        contract_address
)

, most_recent_prices AS (

    SELECT 
        symbol, 
        contract_address,
        price
    
    FROM (

        SELECT 
            symbol, 
            contract_address,
            price,
            minute,
            ROW_NUMBER() OVER (PARTITION BY contract_address ORDER BY minute DESC) AS RowNumber
            
        FROM prices.usd 
        
        WHERE symbol IN ('DPI', 'INDEX') 
    
    ) asset_prices    

    WHERE RowNumber = 1

)

/* --- Main Query --- */
SELECT 
    tats.wallet,
    tats.wallet_address,
    mrp.symbol, 
    mrp.contract_address, 
    tats.units, 
    mrp.price, 
    (tats.units * mrp.price) as balance
    

FROM transfer_amounts tats

LEFT JOIN most_recent_prices mrp ON mrp.contract_address = tats.contract_address

WHERE wallet_address IN ('\x9467cfadc9de245010df95ec6a585a506a8ad5fc', -- Treasury Wallet
                         '\xe2250424378b6a6dC912f5714cfd308a8D593986', -- Treasury Committee Wallet
                         '\x26e316f5b3819264DF013Ccf47989Fb8C891b088' -- Community Treasury Year 1 Vesting
                         )
                         
GROUP BY 
    tats.wallet,
    tats.wallet_address,
    mrp.symbol, 
    mrp.contract_address, 
    tats.units, 
    mrp.price, 
    (tats.units * mrp.price) 
    
ORDER BY 
    tats.wallet,
    (tats.units * mrp.price) DESC