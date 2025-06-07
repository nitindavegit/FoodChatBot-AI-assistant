
# Food Ordering Assistant (Dialogflow + FastAPI)

## Overview

This project is a conversational food ordering assistant built using **Dialogflow** for natural language understanding and **FastAPI** as the backend server.  
Users can add, remove, view, and complete their food orders through conversational commands.

---

## Features

- Natural language interaction using Dialogflow
- Add items to order (with quantity and variants)
- Remove items from order (handles case insensitive matching)
- View current order status
- Complete order and reset session
- Session management with FastAPI backend

---

## Tech Stack

- **Dialogflow CX / ES** (for building conversational agents)
- **FastAPI** (Python framework for REST API backend)
- **Uvicorn** (ASGI server to run FastAPI)
- **Ngrok** (optional, for local tunneling to expose your server to Dialogflow)
- **Python 3.9+**

---

## Getting Started

### Prerequisites

- Python 3.9 or higher installed
- Dialogflow agent created in Google Cloud Console
- Ngrok installed (optional for local development)

### Installation

1. Clone the repo:
   ```bash
   git clone https://github.com/yourusername/FoodChatBot-AI-assistant.git
   cd FoodChatBot-AI-assistant
   ```

2. Create and activate a virtual environment:
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

### Running the Server

```bash
uvicorn main:app --reload
```

- The FastAPI server will start on `http://127.0.0.1:8000`.
- Use ngrok to expose this endpoint to Dialogflow:
  ```bash
  ngrok http 8000
  ```
- Copy the public HTTPS URL from ngrok and set it as the webhook URL in your Dialogflow fulfillment.

---

## Dialogflow Setup

- Create intents for adding, removing, viewing, and completing orders.
- Set up webhook fulfillment pointing to your FastAPI server URL.
- Use session IDs to maintain order state per user.
- Map user expressions to respective intent actions.

---

## Usage

- Start a conversation in Dialogflow simulator or integrated platform.
- Add food items by saying:  
  *“Add 2 masala dosas”*  
- Remove items by saying:  
  *“Remove dosa”* (case insensitive handling)
- Check your order status:  
  *“What’s in my order?”*  
- Complete your order:  
  *“Complete order”*

---

## Troubleshooting

- Make sure your webhook URL is HTTPS and reachable from Dialogflow.
- Use consistent session IDs to track user orders.
- Handle case insensitive matching to improve user experience.
- Review Dialogflow logs for webhook errors.

---

## License

MIT License
