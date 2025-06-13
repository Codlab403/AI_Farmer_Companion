# AI Farmer's Companion

## 🧩 Product Overview

**Name**: AI Farmer’s Companion  
**Type**: Cross-platform mobile app + offline-capable AI assistant  
**Goal**: Provide Ethiopian farmers with multilingual, AI-driven agricultural support, available online or offline via smartphones, USSD, or voice.

This project aims to build a comprehensive tool to assist farmers with crop management, pest diagnosis, weather information, and market prices, with a strong emphasis on voice interaction and offline capabilities.

## Project Structure

*   `/frontend`: Flutter app (UI, state management, assets)
*   `/api`: FastAPI backend (API routes, business logic)
*   `/model`: Machine Learning models (loading, inference, local fallbacks)
*   `/infra`: Infrastructure (Docker, deployment scripts, CI/CD)

## Getting Started

1.  **Clone the repository.**
2.  **Set up the backend:**
    *   Navigate to the `/api` directory.
    *   Create a virtual environment: `python -m venv venv`
    *   Activate it: `source venv/bin/activate` (Linux/macOS) or `venv\Scripts\activate` (Windows)
    *   Install dependencies: `pip install -r requirements.txt`
    *   Copy `.env.example` to `.env` and fill in your API keys and credentials.
3.  **Set up the frontend:**
    *   Ensure you have Flutter SDK installed.
    *   Navigate to the `/frontend` directory.
    *   Get dependencies: `flutter pub get`
4.  **Run the application (details to be added).**

For detailed requirements, see the [Product Requirements Document (PRD)](<link_to_prd_if_available>).
