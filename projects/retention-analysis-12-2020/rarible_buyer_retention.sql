-- https://explore.duneanalytics.com/queries/11852/source#23560
with purchase as (
    select buyer, seller, token, "tokenId", '\xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2'::bytea buy_token, price/1e18 as amount, evt_block_time
      from rarible."TokenSale_evt_Buy"
     union all
    select buyer, seller, token, "tokenId", '\xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2'::bytea buy_token, price/1e18 as amount, evt_block_time
      from rarible_v1."ERC721Sale_v1_evt_Buy"
     union all
    select buyer, owner as seller, token, "tokenId", '\xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2'::bytea buy_token, (price * value)/1e18 as amount, evt_block_time
      from rarible_v1."ERC1155Sale_v1_evt_Buy"
     union all
    select buyer, seller, token, "tokenId", '\xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2'::bytea buy_token, price/1e18 as amount, evt_block_time
      from rarible_v1."ERC721Sale_v2_evt_Buy"
     union all
    select buyer, owner as seller, token, "tokenId", '\xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2'::bytea buy_token, (price * value)/1e18 as amount, evt_block_time
      from rarible_v1."ERC1155Sale_v2_evt_Buy"
), purchase_by_buyer_period as (
    select date_trunc('month', evt_block_time) period, buyer as acct, sum(amount) amount, count(1) count
      from purchase
     group by 1, 2
     order by 1, 2
), acct_by_period as (
    select acct, min(period) over (partition by acct) as start_period, period, extract(month from age(period, min(period) over (partition by acct))) as num, amount, count
      from purchase_by_buyer_period
), cohort as (
    select to_char(start_period, 'YYYY-MM') as start_period, num, count(1)
      from acct_by_period
     where extract(year from start_period) >= 2020
     group by 1, 2
)
    select start_period,
           num,
           count,
           count || '/' || (100 * cast(count as DECIMAL) / (max(count) over (partition by start_period)))::integer || '%' res
      from cohort;
