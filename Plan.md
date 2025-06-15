


---

## 🗓️ **1: SETUP INFRASTRUCTURE & DEVELOPMENT FOUNDATION**

### 🔧 Local Setup

-  ✅ Install and test **Ollama** with **LLaMA 3.2**:
    
    - Command: `ollama run llama3`
        
    - Test: run a prompt in terminal and validate response time
        
-  ✅ Install **Whisper CLI or Python package** for speech-to-text
    
    - Command: `pip install openai-whisper`
        
-  ✅ Setup **ONNX Runtime** or **MobileNet** image classifier (basic pest image placeholder model)
    

### ⚙️ Dev Environment

-  ✅ Setup mono-repo (or split frontend/backend):
    
    - Use: `pnpm` or `yarn` workspaces, or simple GitHub folder structure
        
    - Example folders:
        
        ```
        ai-farmers-companion/
        ├── backend/
        ├── frontend/
        ├── ai-models/
        ├── database/
        └── docs/
        ```
        

### 📲 Install Core Tools

-  ✅ **Flutter** environment (for Android + PWA)
    
-  ✅ **FastAPI** backend setup:
    
    - Scaffold: `main.py`, `routers`, `models`, `schemas`
        
-  ✅ **PostgreSQL** (local or Supabase)
    
-  ✅ Setup **SQLite** for offline sync simulation
    
-  ✅ GitHub + GitHub Actions CI/CD skeleton
    

---

## 🗓️ **2: BUILD CORE MVP SCREENS & BACKEND ROUTES**

### 🖼️ Frontend (Flutter)

-  Create base **Tile-based Home Screen** (Advice, Weather, Prices, Ask AI)
    
-  Set up **Multilingual Support**:
    
    - Use `flutter_localizations` + `.arb` files
        
-  Build "Ask AI" Screen:
    
    - Text input
        
    - Voice input (mic button, connected to Whisper or Gemini)
        
-  Set up **local caching** and sync buttons (for offline simulation)
    

### 🔌 Backend (FastAPI)

-  Define schema: `Farmer`, `Query`, `CropAdvice`, `WeatherData`
    
-  Add route: `/ask` – handles questions
    
    - If online: send to Gemini
        
    - If offline: call LLaMA 3.2 via local Ollama subprocess
        
-  Add route: `/market-prices` – static JSON for now
    
-  Add route: `/weather` – mock weather data
    

---

## 🗓️ **3: ADD AI INTEGRATION, VOICE FEATURES, LOCAL DB**

### 🎤 Voice & AI Features

-  Integrate **Whisper STT** into frontend (offline)
    
-  Integrate **Google Gemini API**:
    
    - Enable on Google Cloud Console
        
    - Add API call to `/ask` route
        
    - Use for:
        
        - Text input Q&A
            
        - Voice-to-text fallback
            
        - Image classification fallback
            
-  Set up **Ollama integration with LLaMA 3.2**:
    
    - Backend POST to `http://localhost:11434/api/generate`
        
    - Basic prompt management with farmer profile context
        

### 🧠 Backend Improvements

-  Add MongoDB or PostgreSQL schema for storing historical questions
    
-  Add basic authentication:
    
    - Firebase Auth (preferred for fast dev)
        
    - Or Supabase + magic link
        
-  Create daily sync routine:
    
    - Schedule sync with backend for market/weather every 24h
        

---

## 🗓️ **4: TESTING, OFFLINE SUPPORT, PILOT PREP**

### 📳 Offline Simulation

-  Bundle basic data (pests, prices, crop tips) in local SQLite DB
    
-  Ensure app works in:
    
    - Airplane mode (cache fallback)
        
    - Delayed sync mode
        

### ✅ QA & Testing

-  Test full pipeline:
    
    - Voice -> STT -> Gemini -> reply (online)
        
    - Voice -> STT -> LLaMA3 -> reply (offline)
        
-  Test 3-language switching (Amharic, Afaan Oromo, English)
    
-  Add simple logging via Supabase or Sentry
    

### 👩🏽‍🌾 User Prep & Mock Pilot

-  Create mock data set: 5 farmers, 3 crops, 2 pests
    
-  Record 3–5 common voice questions per language
    
-  Simulate field use with 1–2 Android devices
    

---

## 🧱 PRIORITY COMPONENTS TO COMPLETE IN PARALLEL

|Component|Tool / Stack|Owner (You/team)|
|---|---|---|
|LLM Integration|Ollama + Gemini API|✅ Done / Partial|
|UI Screens|Flutter|Start Week 2|
|Backend Logic|FastAPI|Start Week 2|
|Local DB Sync|SQLite + Postgres|Week 3|
|Voice UI|Whisper / Gemini|Week 3|
|Multilingual UI|Flutter `.arb` i18n|Week 2–3|
|MVP Testing|Manual + Android|Week 4|

---

## 🔚 End of Month 1 Goal: Working MVP Demo

You should have:

- [✅] Flutter app with tile UI
    
- [✅] Ask AI working with voice and text
    
- [✅] Gemini and Ollama both functional
    
- [✅] Local caching with fallback to SQLite
    
- [✅] Weather & price screen (dummy data)
    
- [✅] Simple multilingual toggle
    

---
