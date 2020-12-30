-- SUSHI ADD LIQUIDITY

-- SELECT
-- *
-- FROM sushi."Router02_call_addLiquidityETH"
-- WHERE token = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b'

-- SELECT
-- *
-- FROM sushi."Router02_call_addLiquidity"
-- WHERE "tokenA" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b' OR "tokenB" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b'

-- SUSHI REMOVE LIQUIDITY

-- SELECT
-- *
-- FROM sushi."Router02_call_removeLiquidityETH"
-- WHERE token = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b'

-- SELECT
-- *
-- FROM sushi."Router02_call_removeLiquidityETHWithPermit"
-- WHERE token = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b'

-- SELECT
-- *
-- FROM sushi."Router02_call_removeLiquidity"
-- WHERE "tokenA" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b' OR "tokenB" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b'

-- SELECT
-- *
-- FROM sushi."Router02_call_removeLiquidityWithPermit"
-- WHERE "tokenA" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b' OR "tokenB" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b'

-- UNISWAP ADD LIQUIDITY

-- SELECT
-- *
-- FROM uniswap_v2."Router01_call_addLiquidity"
-- WHERE "tokenA" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b' OR "tokenB" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b'

-- SELECT
-- *
-- FROM uniswap_v2."Router02_call_addLiquidity"
-- WHERE "tokenA" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b' OR "tokenB" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b'

-- SELECT
-- *
-- FROM uniswap_v2."Router02_call_addLiquidityETH"
-- WHERE token = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b'

-- UNISWAP REMOVE LIQUIDITY

-- SELECT
-- *
-- FROM uniswap_v2."Router02_call_removeLiquidityETHWithPermit"
-- WHERE token = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b'

-- SELECT
-- *
-- FROM uniswap_v2."Router02_call_removeLiquidityETH"
-- WHERE token = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b'

-- SELECT
-- *
-- FROM uniswap_v2."Router01_call_removeLiquidity"
-- WHERE "tokenA" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b' OR "tokenB" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b'

-- SELECT
-- *
-- FROM uniswap_v2."Router02_call_removeLiquidity"
-- WHERE "tokenA" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b' OR "tokenB" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b'

-- SELECT
-- *
-- FROM uniswap_v2."Router02_call_removeLiquidityWithPermit"
-- WHERE "tokenA" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b' OR "tokenB" = '\x1494ca1f11d487c2bbe4543e90080aeba4ba3c2b'



-- Aggregated: uniswap."view_add_liquidity", uniswap."view_remove_liquidity" (https://github.com/duneanalytics/abstractions/blob/master/schema/uniswap/view_add_liquidity.sql & https://github.com/duneanalytics/abstractions/blob/master/schema/uniswap/view_remove_liquidity.sql)
