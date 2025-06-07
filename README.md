# Food Ordering Assistant (Dialogflow + FastAPI)
## Overview
This project is a conversational food ordering assistant built using Dialogflow for natural language understanding and FastAPI as the backend server.
Users can add, remove, view, and complete their food orders through conversational commands.

## Features
Natural language interaction using Dialogflow
Add items to order (with quantity and variants)
Remove items from order (handles case insensitive matching)
View current order status
Complete order and reset session
Session management with FastAPI backend

## Tech Stack
Dialogflow CX / ES (for building conversational agents)
FastAPI (Python framework for REST API backend)
Uvicorn (ASGI server to run FastAPI)
Ngrok (optional, for local tunneling to expose your server to Dialogflow)
Python 3.9+
