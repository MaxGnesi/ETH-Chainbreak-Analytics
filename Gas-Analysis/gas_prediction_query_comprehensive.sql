-- ============================================================================
-- ETH-Chainbreak-Analytics: MEMORY-OPTIMIZED (No ORDER BY, No Window Functions)
-- ============================================================================

WITH 

base_blocks AS (
  SELECT
    number AS block_number,
    timestamp AS block_timestamp,
    gas_used,
    gas_limit,
    size AS block_size_bytes,
    transaction_count,
    base_fee_per_gas,
    
    SAFE_DIVIDE(gas_used, gas_limit) AS gas_utilization,
    
    -- Temporal features
    EXTRACT(HOUR FROM timestamp) AS hour_of_day,
    EXTRACT(DAYOFWEEK FROM timestamp) AS day_of_week,
    EXTRACT(DATE FROM timestamp) AS block_date,
    
    CASE WHEN EXTRACT(DAYOFWEEK FROM timestamp) IN (1, 7) THEN 1 ELSE 0 END AS is_weekend,
    CASE WHEN EXTRACT(HOUR FROM timestamp) BETWEEN 14 AND 22 THEN 1 ELSE 0 END AS is_us_peak,
    CASE WHEN EXTRACT(HOUR FROM timestamp) BETWEEN 7 AND 15 THEN 1 ELSE 0 END AS is_eu_peak,
    CASE WHEN EXTRACT(HOUR FROM timestamp) BETWEEN 0 AND 8 THEN 1 ELSE 0 END AS is_asia_peak
    
  FROM 
    `bigquery-public-data.crypto_ethereum.blocks`
  WHERE 
    timestamp >= '2021-08-05 00:00:00 UTC'
    AND timestamp <= CURRENT_TIMESTAMP()
    AND gas_limit > 0
    AND gas_used > 0
    AND base_fee_per_gas IS NOT NULL
    AND MOD(number, 5) = 0  -- ADD THIS LINE FOR EVERY 5TH BLOCK
),

transaction_features AS (
  SELECT
    block_number,
    
    -- Gas price stats
    AVG(gas_price) AS avg_gas_price,
    MIN(gas_price) AS min_gas_price,
    MAX(gas_price) AS max_gas_price,
    STDDEV(gas_price) AS stddev_gas_price,
    APPROX_QUANTILES(gas_price, 100)[OFFSET(50)] AS median_gas_price,
    APPROX_QUANTILES(gas_price, 100)[OFFSET(25)] AS q25_gas_price,
    APPROX_QUANTILES(gas_price, 100)[OFFSET(75)] AS q75_gas_price,
    
    -- Priority fee stats
    AVG(max_priority_fee_per_gas) AS avg_priority_fee,
    MIN(max_priority_fee_per_gas) AS min_priority_fee,
    MAX(max_priority_fee_per_gas) AS max_priority_fee,
    STDDEV(max_priority_fee_per_gas) AS stddev_priority_fee,
    APPROX_QUANTILES(max_priority_fee_per_gas, 100)[OFFSET(50)] AS median_priority_fee,
    APPROX_QUANTILES(max_priority_fee_per_gas, 100)[OFFSET(75)] AS q75_priority_fee,
    APPROX_QUANTILES(max_priority_fee_per_gas, 100)[OFFSET(90)] AS q90_priority_fee,
    APPROX_QUANTILES(max_priority_fee_per_gas, 100)[OFFSET(95)] AS q95_priority_fee,
    
    -- Transaction counts
    COUNT(*) AS total_transactions,
    COUNTIF(to_address IS NULL) AS contract_creation_count,
    COUNTIF(value > 0 AND input = '0x') AS simple_transfer_count,
    COUNTIF(LENGTH(input) > 10 AND STARTS_WITH(input, '0xa9059cbb')) AS erc20_transfer_count,
    COUNTIF(LENGTH(input) > 10 AND STARTS_WITH(input, '0x23b872dd')) AS erc20_transfer_from_count,
    
    -- DEX swaps
    COUNTIF(
      STARTS_WITH(input, '0x38ed1739') OR STARTS_WITH(input, '0x7ff36ab5') 
      OR STARTS_WITH(input, '0x18cbafe5') OR STARTS_WITH(input, '0x8803dbee')
      OR STARTS_WITH(input, '0x128acb08') OR STARTS_WITH(input, '0xc04b8d59')
    ) AS dex_swap_count,
    
    -- NFT transfers
    COUNTIF(
      STARTS_WITH(input, '0x23b872dd') OR STARTS_WITH(input, '0x42842e0e') 
      OR STARTS_WITH(input, '0xf242432a')
    ) AS nft_transfer_count,
    
    -- Value metrics
    SUM(value) / 1e18 AS total_eth_transferred,
    AVG(value) / 1e18 AS avg_eth_per_tx,
    MAX(value) / 1e18 AS max_eth_in_block,
    
    -- Gas metrics
    SUM(gas) AS total_gas_requested,
    AVG(gas) AS avg_gas_per_tx,
    MAX(gas) AS max_gas_in_tx
    
  FROM 
    `bigquery-public-data.crypto_ethereum.transactions`
  WHERE 
    block_timestamp >= '2021-08-05 00:00:00 UTC'
    AND block_timestamp <= CURRENT_TIMESTAMP()
  GROUP BY 
    block_number
)

-- FINAL SELECT - NO ORDER BY, NO LIMIT!
SELECT
  b.block_number,
  b.block_timestamp,
  b.block_date,
  b.gas_used,
  b.gas_limit,
  b.gas_utilization,
  b.block_size_bytes,
  b.transaction_count,
  b.base_fee_per_gas,
  
  b.hour_of_day,
  b.day_of_week,
  b.is_weekend,
  b.is_us_peak,
  b.is_eu_peak,
  b.is_asia_peak,
  
  t.avg_gas_price,
  t.min_gas_price,
  t.max_gas_price,
  t.stddev_gas_price,
  t.median_gas_price,
  t.q25_gas_price,
  t.q75_gas_price,
  
  t.avg_priority_fee,
  t.min_priority_fee,
  t.max_priority_fee,
  t.stddev_priority_fee,
  t.median_priority_fee,
  t.q75_priority_fee,
  t.q90_priority_fee,
  t.q95_priority_fee,
  
  t.total_transactions,
  t.contract_creation_count,
  t.simple_transfer_count,
  t.erc20_transfer_count,
  t.erc20_transfer_from_count,
  t.dex_swap_count,
  t.nft_transfer_count,
  
  t.total_eth_transferred,
  t.avg_eth_per_tx,
  t.max_eth_in_block,
  t.total_gas_requested,
  t.avg_gas_per_tx,
  t.max_gas_in_tx

FROM 
  base_blocks b
LEFT JOIN 
  transaction_features t ON b.block_number = t.block_number;

-- No ORDER BY - data comes naturally ordered from blocks table
-- No LIMIT - get everything
-- Block time will be computed in Python from timestamps