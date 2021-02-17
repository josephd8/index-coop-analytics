WITH eth_balance AS ( 

    -- outbound transfers
    SELECT "from" AS address, -tr.value AS amount, 'WETH' as "symbol"
    FROM ethereum.traces tr
    WHERE "from" IN ('\x9467cfadc9de245010df95ec6a585a506a8ad5fc', -- Treasury Wallet
                     '\xe2250424378b6a6dC912f5714cfd308a8D593986', -- Treasury Committee Wallet
                     '\x26e316f5b3819264DF013Ccf47989Fb8C891b088' -- Community Treasury Year 1 Vesting
                    )
    AND success
    AND (call_type NOT IN ('delegatecall', 'callcode', 'staticcall') OR call_type IS null)


    UNION ALL

    -- inbound transfers
    SELECT "to" AS address, value AS amount, 'WETH' as "symbol"
    FROM ethereum.traces
    WHERE "to" IN ('\x9467cfadc9de245010df95ec6a585a506a8ad5fc', -- Treasury Wallet
                     '\xe2250424378b6a6dC912f5714cfd308a8D593986', -- Treasury Committee Wallet
                     '\x26e316f5b3819264DF013Ccf47989Fb8C891b088' -- Community Treasury Year 1 Vesting
                    )
    AND success
    AND (call_type NOT IN ('delegatecall', 'callcode', 'staticcall') OR call_type IS null)

    UNION ALL
    
    -- gas costs
    SELECT "from" AS address, -gas_used * gas_price AS amount, 'WETH' as "symbol"
    FROM ethereum.transactions
    WHERE "from" IN ('\x9467cfadc9de245010df95ec6a585a506a8ad5fc', -- Treasury Wallet
                     '\xe2250424378b6a6dC912f5714cfd308a8D593986', -- Treasury Committee Wallet
                     '\x26e316f5b3819264DF013Ccf47989Fb8C891b088' -- Community Treasury Year 1 Vesting
                    )

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
        
        WHERE symbol IN ('WETH') 
    
    ) asset_prices    

    WHERE RowNumber = 1

)


/* --- Main Query --- */
SELECT 
    CASE 
        WHEN address = '\x9467cfadc9de245010df95ec6a585a506a8ad5fc' THEN 'Index Treasury' 
        WHEN address = '\xe2250424378b6a6dC912f5714cfd308a8D593986' THEN 'Index Treasury Committee'
        WHEN address = '\x26e316f5b3819264DF013Ccf47989Fb8C891b088' THEN 'Community Treasury Year 1 Vesting'
        END AS "wallet",
    address as wallet_address,
    mrp.symbol,
    mrp.contract_address,
    sum(amount) / 1e18 as units,
    price,
    sum(amount) / 1e18 * price as balance

FROM eth_balance eb 

LEFT JOIN most_recent_prices mrp ON eb.symbol = mrp.symbol

GROUP BY 
    CASE 
        WHEN address = '\x9467cfadc9de245010df95ec6a585a506a8ad5fc' THEN 'Index Treasury' 
        WHEN address = '\xe2250424378b6a6dC912f5714cfd308a8D593986' THEN 'Index Treasury Committee'
        WHEN address = '\x26e316f5b3819264DF013Ccf47989Fb8C891b088' THEN 'Community Treasury Year 1 Vesting'
        END,
    address,
    mrp.symbol,
    mrp.price,
    mrp.contract_address
    
ORDER BY 
    address,
    sum(amount) / 1e18 * price DESC
