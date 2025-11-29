# 📌 ezMoney — Financial Coach (INIT 0, Mumbai Hacks 2025)

## 🎥 Demo & Documentation
[![Watch Demo](https://img.shields.io/badge/YouTube-Demo-red?style=for-the-badge&logo=youtube)](YOUR_YOUTUBE_LINK_HERE)

[![Read More](https://img.shields.io/badge/Notion-Documentation-black?style=for-the-badge&logo=notion)](YOUR_NOTION_LINK_HERE)

## 📸 Screenshots

<table>
  <tr>
    <td><img src="images/WhatsApp%20Image%202025-11-29%20at%2011.29.47%20(1).jpeg" width="200"></td>
    <td><img src="images/WhatsApp%20Image%202025-11-29%20at%2011.29.47%20(2).jpeg" width="200"></td>
    <td><img src="images/WhatsApp%20Image%202025-11-29%20at%2011.29.47.jpeg" width="200"></td>
    <td><img src="images/WhatsApp%20Image%202025-11-29%20at%2011.29.48%20(1).jpeg" width="200"></td>
  </tr>
  <tr>
    <td><img src="images/WhatsApp%20Image%202025-11-29%20at%2011.29.48%20(2).jpeg" width="200"></td>
    <td><img src="images/WhatsApp%20Image%202025-11-29%20at%2011.29.48.jpeg" width="200"></td>
    <td><img src="images/WhatsApp%20Image%202025-11-29%20at%2011.29.49%20(1).jpeg" width="200"></td>
    <td><img src="images/WhatsApp%20Image%202025-11-29%20at%2011.29.49.jpeg" width="200"></td>
  </tr>
  <tr>
    <td><img src="images/WhatsApp%20Image%202025-11-29%20at%2011.29.50%20(1).jpeg" width="200"></td>
    <td><img src="images/WhatsApp%20Image%202025-11-29%20at%2011.29.50%20(2).jpeg" width="200"></td>
    <td><img src="images/WhatsApp%20Image%202025-11-29%20at%2011.29.50.jpeg" width="200"></td>
    <td><img src="images/WhatsApp%20Image%202025-11-29%20at%2011.29.51%20(1).jpeg" width="200"></td>
  </tr>
  <tr>
    <td><img src="images/WhatsApp%20Image%202025-11-29%20at%2011.29.51%20(2).jpeg" width="200"></td>
    <td><img src="images/WhatsApp%20Image%202025-11-29%20at%2011.29.51%20(3).jpeg" width="200"></td>
    <td><img src="images/WhatsApp%20Image%202025-11-29%20at%2011.29.51.jpeg" width="200"></td>
    <td><img src="images/WhatsApp%20Image%202025-11-29%20at%2011.29.52.jpeg" width="200"></td>
  </tr>
  <tr>
    <td><img src="images/WhatsApp%20Image%202025-11-29%20at%2011.33.40.jpeg" width="200"></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
</table>


ezMoney is an AI-powered, voice-first, autonomous financial coaching agent designed for India's gig workers, freelancers, and users in low-connectivity regions. This repository contains the INIT 0 prototype built for Mumbai Hacks 2025.

## 🎯 Problem Statement

Even with hundreds of fintech apps, managing money in India is still:

- **Too hard** → complex UIs, manual tracking
- **Too stressful** → no proactive guidance
- **Too reactive** → apps show dashboards, not decisions
- **Too inaccessible** → doesn't work for gig workers or low-connectivity users
- **Too risky** → storing PII creates compliance & trust issues

People still struggle to understand:

- "Am I overspending?"
- "Can I afford rent?"
- "Will I run short this month?"
- "If I save/invest differently, how does my future change?"

There is no intelligent, offline-capable, privacy-first financial companion — especially for India's 115M gig workers.

## 🚀 What We're Building

**ezMoney = Self-Driving Finances.** A voice-first, agentic AI that listens, understands, predicts, and acts to manage your money.

The prototype includes:

### 🧠 1. Agentic AI Coaching
- Voice → intent understanding
- Personalized recommendations
- Real-time nudges (overspend, bills, risk alerts)

### 📈 2. Financial Twin Simulation
- "What-if" scenarios
- Cashflow forecasting
- Goal planning & outcomes

### 💸 3. Expense + Income Understanding
- Categorization
- Budget health
- Behavior insights

### 📡 4. Offline BLE Mesh Payments (UPI Relay Concept)
- Designed for low-connectivity areas
- UPI payload → BLE mesh → settlement once any device connects

### 🔐 5. Zero-PII, On-Device First
- No Aadhaar, PAN, phone number stored
- Local inference via lightweight models

## 🧩 Project Structure (Minimal & Clear)
```
financial-coach/
│
├── config/             # Global settings, defaults, thresholds
├── graph/              # (Future) decision graphs & Financial Twin flows
├── mcp/                # BLE mesh & offline UPI relay logic (scaffolding)
├── models/             # AI models: voice→intent, forecasting, agent logic
├── routes/             # API endpoints (for local/server use)
├── schemas/            # Data models for expenses, incomes, forecasts, alerts
├── services/           # Core financial logic: budgets, predictions, nudges
├── utils/              # Helpers: storage, encryption, logging, BLE utils
│
├── chat.py             # CLI chat interface to test the financial agent
├── main.py             # Main entry to run agent workflows
├── test_request.py     # Example test input/output flow
└── requirements.txt
```

## 📝 Explanation (Short Version)

- **config/** — core settings for the agent
- **models/** — intelligence: forecasting, categorization, advice
- **services/** — business logic powering calculations & coaching
- **schemas/** — strict data structures for clean flow
- **mcp/** — offline BLE payment prototype scaffold
- **chat.py** — quick text interface to talk to the agent
- **main.py** — prototype runner

## ▶️ Running the Prototype
```bash
git clone https://github.com/uyaditi/financial-coach
cd financial-coach
pip install -r requirements.txt

# Run the agent demo
python chat.py
```

This allows you to:

- Ask financial questions
- Try "what-if" simulations
- Test forecasting logic
- Inspect the agent's decision-making flow

## 🏆 Built for Mumbai Hacks 2025

This is an early-stage prototype showcasing the vision for autonomous financial coaching in India. We're excited to iterate and expand based on feedback!

---

**Made with 💙 for India's financial future**
