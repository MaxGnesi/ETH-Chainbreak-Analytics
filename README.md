# 🔍 ETH-Chainbreak-Analytics

**Machine Learning & Blockchain Analytics for Ethereum Security Intelligence**

[![Python](https://img.shields.io/badge/Python-3.9+-blue.svg)](https://www.python.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![BigQuery](https://img.shields.io/badge/BigQuery-Ethereum-orange.svg)](https://cloud.google.com/bigquery)

---

## 🎯 Project Overview

ETH-Chainbreak-Analytics is a comprehensive machine learning framework for analyzing Ethereum blockchain data to understand market microstructure, track wallet development patterns, and provide actionable intelligence for digital asset trading and security. This project bridges quantitative finance methodologies with blockchain analytics to uncover hidden patterns in on-chain data.

### 🚀 Motivation

With over \ locked in DeFi protocols and increasing market complexity, there's a critical need for advanced analytics that can:
- **Understand supply microstructure** - Map token distribution and concentration patterns
- **Track wallet development** - Monitor large holder behavior and accumulation/distribution phases
- **Gain market intelligence** - Derive macro indicators from on-chain activity for trading signals
- **Detect security threats** - Identify rug pulls, contract fraud, and malicious patterns
- **Bridge TradFi + DeFi** - Apply institutional risk management to blockchain analytics

---

## 📊 Current Modules

### 1. Wallet Clustering & Supply Microstructure Analysis 🔗
**Status:** ✅ Complete

Advanced clustering analysis of Ethereum addresses to understand the microstructure of token supply distribution and monitor wallet development patterns for market intelligence.

**Key Features:**
- BigQuery ETL pipeline for extracting wallet transaction data
- Feature engineering: transaction frequency, volumes, timing patterns, holder concentration
- PCA dimensionality reduction for visualization
- Multiple clustering algorithms (K-Means, DBSCAN, hierarchical)
- Supply distribution analysis across wallet clusters
- Large holder tracking and behavior pattern identification
- Interactive visualizations of wallet relationships and supply dynamics

**Use Cases:**
- Understanding token holder concentration and distribution patterns
- Tracking whale accumulation/distribution phases
- Identifying institutional vs. retail wallet behaviors
- Monitoring wallet development over time for market timing
- Detecting coordinated wallet activity (Sybil patterns, wash trading)

**Dataset:** ~47,000 wallet addresses with transaction metrics from Ethereum mainnet

[📁 View Module](./wallet-clustering/)

### 2. Rug Pull Detection & Contract Fraud Analysis 🚨
**Status:** 🚧 In Development

Machine learning models to detect potential rug pulls in DeFi protocols using on-chain signals, liquidity patterns, and smart contract analysis. Additionally, building macro indicators from blockchain data for market intelligence.

**Planned Features:**
- **Rug Pull Detection:**
  - Real-time monitoring of liquidity pool changes
  - Token holder concentration analysis
  - Contract code pattern detection for common fraud patterns
  - Historical rug pull pattern learning
  - Risk scoring system for new tokens
  
- **Smart Contract Fraud Review:**
  - Automated contract analysis for malicious code patterns
  - Honeypot detection (can buy but can't sell patterns)
  - Hidden mint functions and backdoors
  - Ownership centralization risks
  - Proxy contract upgrade vulnerabilities

- **Macro Market Intelligence Indicators:**
  - Network activity and transaction velocity metrics
  - Smart money flow tracking (exchange inflows/outflows)
  - Whale accumulation/distribution indices
  - DeFi TVL momentum and liquidity depth changes
  - Gas price dynamics as market sentiment indicator
  - Stablecoin supply growth as liquidity proxy

---

## 🛠️ Technical Stack

**Data Infrastructure:**
- **Google BigQuery** - Ethereum public dataset (\igquery-public-data.crypto_ethereum\)
- **SQL** - Complex on-chain data extraction and transformation

**Machine Learning & Analytics:**
- **Python 3.9+** - Core programming language
- **Pandas & NumPy** - Data manipulation and numerical computing
- **Scikit-learn** - ML algorithms and preprocessing
- **HDBSCAN** - Density-based clustering
- **PCA** - Dimensionality reduction

**Visualization:**
- **Matplotlib & Seaborn** - Statistical visualizations
- **Plotly** - Interactive dashboards

---

## 📁 Project Structure

\\\
ETH-Chainbreak-Analytics/
├── wallet-clustering/           # Supply microstructure & wallet analysis
│   ├── queries/                 # BigQuery SQL queries
│   │   └── ethereum_wallet_clustering.sql
│   ├── data/                    # Extracted datasets
│   │   └── ethererum_blockchain_wallets.csv
│   ├── results/                 # Analysis outputs
│   │   └── pca_analysis.png
│   ├── wallets_clustesring.ipynb  # Main analysis notebook
│   ├── requirements.txt         # Module dependencies
│   └── README.md               # Module documentation
│
├── rug-pull-detection/         # [Coming Soon] Security & market intelligence
│   └── ...
│
├── README.md                   # This file
├── requirements.txt            # Project-wide dependencies
└── .gitignore                 # Git ignore rules
\\\

---

## 🚀 Quick Start

### Prerequisites
- Python 3.9 or higher
- Google Cloud account with BigQuery access (for data extraction)
- Jupyter Notebook

### Installation

1. **Clone the repository**
\\\ash
git clone https://github.com/MaxGnesi/ETH-Chainbreak-Analytics.git
cd ETH-Chainbreak-Analytics
\\\

2. **Install dependencies**
\\\ash
pip install -r requirements.txt
\\\

3. **Set up BigQuery credentials** (optional, if you want to re-run data extraction)
\\\ash
# Set your Google Cloud project
export GOOGLE_CLOUD_PROJECT="your-project-id"

# Authenticate
gcloud auth application-default login
\\\

### Usage

**Wallet Clustering & Supply Analysis:**
\\\ash
cd wallet-clustering
jupyter notebook wallets_clustesring.ipynb
\\\

The notebook includes:
- Data loading and preprocessing
- Exploratory data analysis
- Feature engineering
- Supply distribution analysis
- Clustering algorithms comparison
- Whale behavior tracking
- Results visualization

---

## 📈 Key Results

### Wallet Clustering & Supply Microstructure

<img src="wallet-clustering/results/pca_analysis.png" width="600" alt="PCA Wallet Clustering">

**Key Insights:**
- Identified distinct clusters of wallet behaviors and holder types
- Supply concentration metrics across different wallet segments
- High-frequency trading wallets vs. long-term holders (HODLers)
- Whale accumulation patterns and distribution phases
- Transaction timing patterns suggesting institutional vs. retail behavior
- Potential coordinated activity in densely connected clusters

---

## 🎓 Background & Expertise

This project combines:
- **20 years** of institutional finance experience (Credit Suisse, Vontobel, CSAM)
- **3 years** deep dive into digital assets and DeFi protocols
- **MIT Blockchain Certification** + **Berkeley ML/AI Specialization**
- Quantitative trading and risk management methodologies
- Systematic approach to cryptocurrency derivatives and volatility analysis
- Market microstructure expertise from traditional finance applied to blockchain

---

## 🗺️ Roadmap

- [x] Wallet clustering analysis with ML
- [x] BigQuery data pipeline setup
- [x] PCA visualization of wallet relationships
- [x] Supply microstructure analysis
- [ ] Rug pull detection model (Q4 2024)
- [ ] Smart contract fraud pattern detection
- [ ] Macro market intelligence indicators (on-chain activity, whale tracking, liquidity metrics)
- [ ] Real-time monitoring dashboard with Grafana
- [ ] Integration with DeFi security APIs
- [ ] MEV (Maximal Extractable Value) analysis
- [ ] Flash loan attack pattern detection
- [ ] Exchange flow analysis (smart money tracking)

---

## 🤝 Contributing

Interested in collaborating? This project welcomes contributions!

**Areas of Interest:**
- Advanced graph neural networks for wallet relationship mapping
- Real-time data streaming from Ethereum nodes
- Integration with additional DeFi protocols
- Smart contract vulnerability detection
- Market microstructure indicators and trading signals

---

## 📫 Contact

**Max Gnesi**  
Digital Assets & Quantitative Finance  
[GitHub](https://github.com/MaxGnesi) | [LinkedIn](https://linkedin.com/in/max-gnesi)

**Professional Focus:**
- Digital Asset Trading & Strategy
- DeFi Security Analytics & Market Microstructure
- Quantitative Finance & Risk Management
- Blockchain Infrastructure & Analytics

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **Google BigQuery** for providing public Ethereum dataset
- **Ethereum Foundation** for blockchain infrastructure
- **Berkeley Data Science** program for ML/AI methodologies
- **MIT Blockchain Labs** for certification and education

---

## 📚 References & Resources

- [Google BigQuery Ethereum Dataset](https://console.cloud.google.com/marketplace/product/ethereum/crypto-ethereum-blockchain)
- [Ethereum Yellow Paper](https://ethereum.github.io/yellowpaper/paper.pdf)
- [DeFi Security Best Practices](https://github.com/crytic/building-secure-contracts)
- [Glassnode On-Chain Analytics](https://glassnode.com/)
- [Nansen Blockchain Intelligence](https://nansen.ai/)

---

<div align="center">
  <sub>Built with 🧠 by <a href="https://github.com/MaxGnesi">Max Gnesi</a></sub>
</div>
