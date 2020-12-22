WITH volume AS (

  SELECT
    "_quantity"/1e18 as quantity,
    evt_block_time
  FROM setprotocol_v2."BasicIssuanceModule_evt_SetTokenIssued"
  WHERE "_setToken" IN ('\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b')

  UNION ALL

  SELECT
    "_quantity"/1e18 as quantity,
    evt_block_time
  FROM setprotocol_v2."BasicIssuanceModule_evt_SetTokenRedeemed"
  WHERE "_setToken" IN ('\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b')

)

SELECT
  SUM(quantity) as dpi_units,
  date_trunc('day', evt_block_time) as day
FROM volume GROUP BY 2;
