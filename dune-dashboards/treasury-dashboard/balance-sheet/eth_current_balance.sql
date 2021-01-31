WITH eth_balance AS ( 

    -- outbound transfers
    SELECT "from" AS address, -tr.value AS amount, 'WETH' as "symbol"
    FROM ethereum.traces tr
    WHERE "from" = '\x9467cfadc9de245010df95ec6a585a506a8ad5fc'
    AND success
    AND (call_type NOT IN ('delegatecall', 'callcode', 'staticcall') OR call_type IS null)


    UNION ALL

    -- inbound transfers
    SELECT "to" AS address, value AS amount, 'WETH' as "symbol"
    FROM ethereum.traces
    WHERE "to" = '\x9467cfadc9de245010df95ec6a585a506a8ad5fc'
    AND success
    AND (call_type NOT IN ('delegatecall', 'callcode', 'staticcall') OR call_type IS null)

    UNION ALL
    
    -- gas costs
    SELECT "from" AS address, -gas_used * gas_price AS amount, 'WETH' as "symbol"
    FROM ethereum.transactions
    WHERE "from" = '\x9467cfadc9de245010df95ec6a585a506a8ad5fc'

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
    'Index Token Treasury' as wallet, 
    address as wallet_address,
    mrp.symbol,
    mrp.contract_address,
    sum(amount) / 1e18 as units,
    price,
    sum(amount) / 1e18 * price as balance

FROM eth_balance eb 

LEFT JOIN most_recent_prices mrp ON eb.symbol = mrp.symbol

GROUP BY 
    address,
    mrp.symbol,
    mrp.price,
    mrp.contract_address
