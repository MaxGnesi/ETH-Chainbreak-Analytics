/*
==============================================
COMPREHENSIVE WALLET FEATURE EXTRACTION v2.0
Strategy: Hybrid Approach
- 90 days: Detailed behavioral features
- Lifetime: Context features (age, total activity)
- Special focus: Old wallets with large holdings
Purpose: Maximum diversity for wallet classification
Estimated Cost: ~45-50 GB
Output: 50,000 diverse wallets with 40+ features
FIX: INT64 overflow handled with FLOAT64 casting
==============================================
*/

-- DEX addresses for labeling
WITH dex_addresses AS (
  SELECT address FROM UNNEST([
    '0x7a250d5630b4cf539739df2c5dacb4c659f2488d',  -- Uniswap V2
    '0xe592427a0aece92de3edee1f18e0157c05861564',  -- Uniswap V3
    '0x68b3465833fb72a70ecdf485e0e4c7bd8665fc45',  -- Uniswap V3 Router 2
    '0xef1c6e67703c7bd7107eed8303fbe6ec2554bf6b',  -- Uniswap Universal
    '0x3fc91a3afd70395cd496c647d5a6cc9d4b2b7fad',  -- Uniswap Universal 2
    '0xd9e1ce17f2641f24ae83637ab66a2cca9c378b9f',  -- SushiSwap
    '0x1b02da8cb0d097eb8d57a175b88c7d8b47997506',  -- SushiSwap V2
    '0xbebc44782c7db0a1a60cb6fe97d0b483032ff1c7',  -- Curve 3pool
    '0x8e764be4288b842791989db5b8ec067279829809',  -- Curve Router
    '0xba12222222228d8ba445958a75a0704d566bf2c8',  -- Balancer V2
    '0x1111111254eeb25477b68fb85ed929f73a960582',  -- 1inch V5
    '0x1111111254fb6c44bac0bed2854e76f90643097d',  -- 1inch V4
    '0xdef1c0ded9bec7f1a1670819833240f027b25eff',  -- 0x Protocol
    '0x9aab3f75489902f3a48495025729a0af77d4b11e',  -- Kyber
    '0x2f9ec37d6ccfff1cab21733bdadede11c823ccb0',  -- Bancor
    '0x9008d19f58aabd9ed0d60971565aa8510560ab41',  -- CoW Swap
    '0xeff92a263d31888d860bd50809a8d171709b7b1c',  -- PancakeSwap
    '0x1e0447b19bb6ecfdae1e4ae1694b0c3659614e4e',  -- dYdX
    '0x0baba1ad5be3a5c0a66e7ac838a129bf948f1ea4',  -- Loopring
    '0xb3999f658c0391d94a37f7ff328f3fec942bcadc'   -- Hashflow
  ]) AS address
),

-- ========================================
-- PART 1: 90-DAY DETAILED BEHAVIOR
-- ========================================

-- Sender stats (90 days)
sender_stats_90d AS (
  SELECT 
    from_address as wallet,
    COUNT(*) as tx_count_sent_90d,
    COUNT(DISTINCT DATE(block_timestamp)) as active_days_90d,
    SUM(value) / 1e18 as total_eth_sent_90d,
    AVG(value) / 1e18 as avg_tx_size_sent_90d,
    MAX(value) / 1e18 as max_tx_sent_90d,
    MIN(value) / 1e18 as min_tx_sent_90d,
    STDDEV(value / 1e18) as stddev_tx_size_90d,
    
    -- Gas behavior (FIXED: FLOAT64 casting)
    AVG(gas_price) / 1e9 as avg_gas_price_gwei_90d,
    SUM((CAST(gas_price AS FLOAT64) * receipt_gas_used) / 1e18) as total_gas_spent_eth_90d,
    AVG(receipt_gas_used) as avg_gas_used_90d,
    
    -- Network behavior
    COUNT(DISTINCT to_address) as unique_recipients_90d,
    
    -- Time
    MIN(block_timestamp) as first_tx_90d,
    MAX(block_timestamp) as last_tx_90d,
    
    -- DEX activity
    COUNTIF(to_address IN (SELECT address FROM dex_addresses)) as dex_tx_count_90d,
    SUM(IF(to_address IN (SELECT address FROM dex_addresses), value, 0)) / 1e18 as dex_volume_eth_90d
    
  FROM `bigquery-public-data.crypto_ethereum.transactions`
  WHERE 
    block_timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 90 DAY)
    AND receipt_status = 1
  GROUP BY from_address
  HAVING tx_count_sent_90d >= 3  -- Minimum activity threshold
),

-- Receiver stats (90 days)
receiver_stats_90d AS (
  SELECT 
    to_address as wallet,
    COUNT(*) as tx_count_received_90d,
    SUM(value) / 1e18 as total_eth_received_90d,
    AVG(value) / 1e18 as avg_tx_size_received_90d,
    MAX(value) / 1e18 as max_tx_received_90d,
    COUNT(DISTINCT from_address) as unique_senders_90d
  FROM `bigquery-public-data.crypto_ethereum.transactions`
  WHERE 
    block_timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 90 DAY)
    AND to_address IS NOT NULL
    AND receipt_status = 1
  GROUP BY to_address
),

-- Token activity (90 days)
token_stats_90d AS (
  SELECT 
    from_address as wallet,
    COUNT(*) as token_transfer_count_90d,
    COUNT(DISTINCT token_address) as unique_tokens_90d,
    COUNT(DISTINCT to_address) as token_unique_recipients_90d
  FROM `bigquery-public-data.crypto_ethereum.token_transfers`
  WHERE block_timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 90 DAY)
  GROUP BY from_address
),

-- Temporal patterns (90 days)
temporal_stats_90d AS (
  SELECT 
    from_address as wallet,
    APPROX_TOP_COUNT(EXTRACT(HOUR FROM block_timestamp), 1)[OFFSET(0)].value as most_active_hour_90d,
    APPROX_TOP_COUNT(EXTRACT(DAYOFWEEK FROM block_timestamp), 1)[OFFSET(0)].value as most_active_day_90d,
    COUNTIF(EXTRACT(DAYOFWEEK FROM block_timestamp) IN (1, 7)) / COUNT(*) as weekend_ratio_90d
  FROM `bigquery-public-data.crypto_ethereum.transactions`
  WHERE block_timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 90 DAY)
  GROUP BY from_address
),

-- ========================================
-- PART 2: LIFETIME CONTEXT
-- ========================================

-- Lifetime stats (for wallets in 90-day sample)
lifetime_stats AS (
  SELECT 
    from_address as wallet,
    
    -- Temporal
    MIN(block_timestamp) as first_tx_ever,
    MAX(block_timestamp) as last_tx_ever,
    DATE_DIFF(CURRENT_DATE(), DATE(MIN(block_timestamp)), DAY) as wallet_age_days,
    DATE_DIFF(DATE(MAX(block_timestamp)), DATE(MIN(block_timestamp)), DAY) as wallet_lifespan_days,
    
    -- Activity
    COUNT(*) as lifetime_tx_count,
    COUNT(DISTINCT DATE(block_timestamp)) as lifetime_active_days,
    
    -- Value
    SUM(value) / 1e18 as lifetime_eth_sent,
    AVG(value) / 1e18 as lifetime_avg_tx_size,
    MAX(value) / 1e18 as lifetime_max_tx
    
  FROM `bigquery-public-data.crypto_ethereum.transactions`
  WHERE 
    from_address IN (SELECT wallet FROM sender_stats_90d)
    AND receipt_status = 1
  GROUP BY from_address
),

-- Lifetime received (for balance calculation)
lifetime_received AS (
  SELECT 
    to_address as wallet,
    SUM(value) / 1e18 as lifetime_eth_received,
    COUNT(*) as lifetime_tx_received
  FROM `bigquery-public-data.crypto_ethereum.transactions`
  WHERE 
    to_address IN (SELECT wallet FROM sender_stats_90d)
    AND receipt_status = 1
  GROUP BY to_address
),

-- ========================================
-- PART 3: COMBINED FEATURES
-- ========================================

all_features AS (
  SELECT 
    s.wallet,
    
    -- ===== 90-DAY FEATURES =====
    
    -- Transaction counts
    s.tx_count_sent_90d,
    COALESCE(r.tx_count_received_90d, 0) as tx_count_received_90d,
    s.tx_count_sent_90d + COALESCE(r.tx_count_received_90d, 0) as tx_count_total_90d,
    s.active_days_90d,
    
    -- ETH value (90d)
    s.total_eth_sent_90d,
    COALESCE(r.total_eth_received_90d, 0) as total_eth_received_90d,
    COALESCE(r.total_eth_received_90d, 0) - s.total_eth_sent_90d as balance_change_90d,
    s.avg_tx_size_sent_90d,
    COALESCE(r.avg_tx_size_received_90d, 0) as avg_tx_size_received_90d,
    s.max_tx_sent_90d,
    COALESCE(r.max_tx_received_90d, 0) as max_tx_received_90d,
    s.min_tx_sent_90d,
    s.stddev_tx_size_90d,
    
    -- Ratios (90d)
    SAFE_DIVIDE(COALESCE(r.total_eth_received_90d, 0), NULLIF(s.total_eth_sent_90d, 0)) as eth_in_out_ratio_90d,
    
    -- Gas (90d)
    s.avg_gas_price_gwei_90d,
    s.total_gas_spent_eth_90d,
    s.avg_gas_used_90d,
    SAFE_DIVIDE(s.total_gas_spent_eth_90d, s.tx_count_sent_90d) as gas_per_tx_90d,
    
    -- Behavior (90d)
    ROUND(s.tx_count_sent_90d / s.active_days_90d, 2) as tx_frequency_per_day_90d,
    s.unique_recipients_90d,
    COALESCE(r.unique_senders_90d, 0) as unique_senders_90d,
    SAFE_DIVIDE(s.unique_recipients_90d, s.tx_count_sent_90d) as recipient_diversity_90d,
    
    -- Tokens (90d)
    COALESCE(t.token_transfer_count_90d, 0) as token_transfer_count_90d,
    COALESCE(t.unique_tokens_90d, 0) as unique_tokens_90d,
    COALESCE(t.token_unique_recipients_90d, 0) as token_unique_recipients_90d,
    SAFE_DIVIDE(COALESCE(t.token_transfer_count_90d, 0), s.tx_count_sent_90d) as token_to_eth_ratio_90d,
    
    -- DEX (90d) - LABELS!
    s.dex_tx_count_90d,
    s.dex_volume_eth_90d,
    IF(s.dex_tx_count_90d > 0, 1, 0) as is_dex_user,
    SAFE_DIVIDE(s.dex_tx_count_90d, s.tx_count_sent_90d) as dex_tx_ratio_90d,
    
    -- Temporal (90d)
    COALESCE(temp.most_active_hour_90d, 12) as most_active_hour_90d,
    COALESCE(temp.most_active_day_90d, 1) as most_active_day_90d,
    COALESCE(temp.weekend_ratio_90d, 0) as weekend_ratio_90d,
    
    -- ===== LIFETIME FEATURES =====
    
    -- Age & lifespan
    l.wallet_age_days,
    l.wallet_lifespan_days,
    l.first_tx_ever,
    l.last_tx_ever,
    DATE_DIFF(CURRENT_DATE(), DATE(l.last_tx_ever), DAY) as days_since_last_tx,
    
    -- Lifetime activity
    l.lifetime_tx_count,
    l.lifetime_active_days,
    l.lifetime_eth_sent,
    COALESCE(lr.lifetime_eth_received, 0) as lifetime_eth_received,
    COALESCE(lr.lifetime_tx_received, 0) as lifetime_tx_received,
    
    -- Lifetime balance (CRITICAL FOR OLD WHALES!)
    COALESCE(lr.lifetime_eth_received, 0) - l.lifetime_eth_sent as lifetime_balance_estimate,
    
    -- Lifetime averages
    l.lifetime_avg_tx_size,
    l.lifetime_max_tx,
    SAFE_DIVIDE(l.lifetime_tx_count, l.lifetime_active_days) as lifetime_tx_per_active_day,
    
    -- ===== HYBRID FEATURES (90d vs Lifetime) =====
    
    -- Activity comparison
    SAFE_DIVIDE(s.tx_count_sent_90d, l.lifetime_tx_count) as recent_to_lifetime_tx_ratio,
    SAFE_DIVIDE(s.total_eth_sent_90d, l.lifetime_eth_sent) as recent_to_lifetime_volume_ratio,
    SAFE_DIVIDE(s.active_days_90d, l.lifetime_active_days) as recent_to_lifetime_active_ratio,
    
    -- Dormancy indicators
    SAFE_DIVIDE(DATE_DIFF(CURRENT_DATE(), DATE(l.last_tx_ever), DAY), l.wallet_age_days) as dormancy_ratio,
    
    -- Old whale indicator (SPECIAL FEATURE!)
    CASE 
      WHEN l.wallet_age_days > 1000 
           AND COALESCE(lr.lifetime_eth_received, 0) - l.lifetime_eth_sent > 5 
           AND SAFE_DIVIDE(s.tx_count_sent_90d, l.lifetime_tx_count) < 0.1 
      THEN 1 
      ELSE 0 
    END as is_old_whale

  FROM sender_stats_90d s
  LEFT JOIN receiver_stats_90d r ON s.wallet = r.wallet
  LEFT JOIN token_stats_90d t ON s.wallet = t.wallet
  LEFT JOIN temporal_stats_90d temp ON s.wallet = temp.wallet
  LEFT JOIN lifetime_stats l ON s.wallet = l.wallet
  LEFT JOIN lifetime_received lr ON s.wallet = lr.wallet
  
  WHERE 
    l.wallet_age_days IS NOT NULL  -- Must have lifetime data
    AND s.total_eth_sent_90d > 0.001  -- Filter dust
),

-- ========================================
-- PART 4: STRATIFIED SAMPLING
-- ========================================

-- Sample 1: Most ACTIVE (recent traders, bots, DeFi users)
most_active AS (
  SELECT *, 'high_activity' as sample_type
  FROM all_features
  ORDER BY tx_count_total_90d DESC
  LIMIT 15000
),

-- Sample 2: OLD WHALES (ancient wallets, big balance, low recent activity) ⭐ SPECIAL!
old_whales AS (
  SELECT *, 'old_whale' as sample_type
  FROM all_features
  WHERE 
    wallet_age_days > 730  -- At least 2 years old
    AND lifetime_balance_estimate > 1  -- At least 1 ETH positive balance
    AND recent_to_lifetime_tx_ratio < 0.2  -- Mostly dormant recently
  ORDER BY 
    wallet_age_days DESC,  -- Oldest first
    lifetime_balance_estimate DESC  -- Then by balance
  LIMIT 12000
),

-- Sample 3: HIGH BALANCE (current rich wallets regardless of age)
high_balance AS (
  SELECT *, 'high_balance' as sample_type
  FROM all_features
  WHERE lifetime_balance_estimate > 0.5
  ORDER BY lifetime_balance_estimate DESC
  LIMIT 10000
),

-- Sample 4: LARGE TX (whales by transaction size)
large_tx AS (
  SELECT *, 'large_tx' as sample_type
  FROM all_features
  ORDER BY max_tx_sent_90d DESC
  LIMIT 8000
),

-- Sample 5: RANDOM DIVERSITY
random_sample AS (
  SELECT *, 'random' as sample_type
  FROM all_features
  WHERE RAND() < 0.02  -- 2% random
  LIMIT 5000
)

-- ========================================
-- FINAL OUTPUT: UNION ALL SAMPLES
-- ========================================

SELECT * FROM most_active
UNION DISTINCT
SELECT * FROM old_whales
UNION DISTINCT
SELECT * FROM high_balance
UNION DISTINCT
SELECT * FROM large_tx
UNION DISTINCT
SELECT * FROM random_sample

ORDER BY wallet_age_days DESC, lifetime_balance_estimate DESC