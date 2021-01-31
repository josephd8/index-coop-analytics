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
        'Index Token Treasury' AS "wallet",
        address as wallet_address, 
        contract_address,
        sum(amount)/1e18 AS "units"
    
    FROM transfers 
    
    GROUP BY 
        --evt_block_time,
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


SELECT 
    wallet,
    wallet_address,
    symbol, 
    mrp.contract_address, 
    units, 
    price, 
    (units * price) as balance
    

FROM transfer_amounts tats

LEFT JOIN most_recent_prices mrp ON mrp.contract_address = tats.contract_address

WHERE wallet_address = '\x9467cfadc9de245010df95ec6a585a506a8ad5fc'



