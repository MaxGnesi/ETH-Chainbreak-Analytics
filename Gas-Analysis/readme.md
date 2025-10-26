# Ethereum Gas Price Evolution: A Brief History

## Timeline of Major Changes

**August 2021 - EIP-1559 (London Hard Fork)**
- Introduced base fee mechanism (replaces auction-style pricing)
- Made gas prices more predictable with algorithmic adjustments
- Separated base fee from priority tips

**March 2024 - Dencun Upgrade**
- Introduced "blobs" (EIP-4844) for L2 data availability
- Massive reduction in L2 transaction costs
- Fundamental restructuring of Ethereum block space economics

*(Note: There may be other upgrades between these dates, but these are the two most significant for gas pricing)*

---

## Key Findings: The Dencun Effect

### 📉 Dramatic Price Reduction
- **Mean gas price:** 42.81 → 6.98 Gwei (**-84%**)
- **Median gas price:** 26.95 → 2.84 Gwei (**-90%**)
- **P99 (extreme spikes):** 199.56 → 48.41 Gwei (**-76%**)

### 📊 Market Became Much More Stable
- **Volatility (std dev):** 77.83 → 12.04 Gwei (**-85%**)
- **Kurtosis:** 3,840 → 324 (**-92%** - far fewer black swan events)
- **Skewness:** 50.19 → 10.53 (**-79%** - more symmetric distribution)

### ✅ What This Means: **Much More Efficient Network**

**Before Dencun:** Wild volatility (1-200+ Gwei), frequent extreme spikes, users constantly overpaying or stuck

**After Dencun:** Stable baseline (~7 Gwei average) where:
- Users can reliably estimate transaction fees
- Fewer "stuck" transactions due to gas spikes
- Network capacity is more efficiently utilized
- L2 rollups are economically viable

---

## Implications for Machine Learning

### Our Study Conclusions:

1. **Persistence beats complex models** (0.10 vs 0.40 Gwei MAE)
   - Post-Dencun prices are so stable that "next = current" is hard to beat
   - Simple moving averages outperform ML models

2. **Smart features don't help** (time patterns, tx types, priority fees)
   - Adding contextual features actually made predictions worse
   - Pre-Dencun patterns (NFT mints causing spikes) no longer apply

3. **Small price movements have no patterns**
   - Deviations from the stable baseline are essentially random
   - Market is informationally efficient - no exploitable edges

### 🎯 Bottom Line:

**Stable prices + Random short-term movements = EFFICIENT MARKET**

The fact that ML models can't beat simple baselines shows:
- **Stable baseline:** Users know gas will be ~7 Gwei (predictable costs)
- **Random micro-movements:** No one can exploit patterns for profit (efficient pricing)
- No sophisticated trader has an edge over simple rules

---

## Final Takeaway

**Dencun made Ethereum both dramatically cheaper AND more stable.** 

The 84% drop in mean prices and 90% drop in median prices mean transactions cost a fraction of what they used to. The 85% reduction in volatility means these low costs are also predictable and reliable. The lack of exploitable patterns in remaining price movements indicates a mature, informationally-efficient market.

For traders/predictors: No patterns to exploit ✅  
For users: Low-cost, reliable transactions ✅
