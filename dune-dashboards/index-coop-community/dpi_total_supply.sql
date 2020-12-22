WITH mint_burn AS (

    SELECT
        date_trunc('day', evt_block_time) AS day,
        SUM("_quantity"/1e18) AS amount
        FROM setprotocol_v2."BasicIssuanceModule_evt_SetTokenIssued"
        WHERE "_setToken" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b'
        GROUP BY 1

    UNION ALL

    SELECT
        date_trunc('day', evt_block_time) AS day,
        -SUM("_quantity"/1e18) AS amount
    FROM setprotocol_v2."BasicIssuanceModule_evt_SetTokenRedeemed"
    WHERE "_setToken" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b'
    GROUP BY 1
)

SELECT
    day,
    SUM(amount) OVER (ORDER BY day) AS dpi_amount
FROM mint_burn
