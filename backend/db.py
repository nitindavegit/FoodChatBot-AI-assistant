# db.py
import asyncpg
import logging
import os
from dotenv import load_dotenv

load_dotenv()

# Replace with your actual DB config
user = os.getenv("DB_USER")
password = os.getenv("DB_PASSWORD")
database_name = os.getenv("DB_NAME")
DB_CONFIG = {
    "user": user,
    "password": password,
    "database": database_name,
    "host": "localhost",
    "port": 5432
}

async def get_order_status(order_id: int) -> str:
    """
    Fetch the status of an order from the order_tracking table.
    """
    conn = await asyncpg.connect(**DB_CONFIG)
    try:
        result = await conn.fetchrow(
            "SELECT status FROM order_tracking WHERE order_id = $1", order_id
        )
        if result:
            return result["status"]
        return "Order ID not found."
    finally:
        await conn.close()
        
        
async def get_next_order_id() -> int:
    """
    Fetch the next available order_id from the order_tracking table.
    """
    conn = await asyncpg.connect(**DB_CONFIG)
    try:
        result = await conn.fetchrow(
            "SELECT MAX(order_id) + 1 AS next_order_id FROM order_tracking"
        )
        return result["next_order_id"] or 1  # If no orders exist, start with 1
    finally:
        await conn.close()
        
        
        
async def insert_order_item(food_item, quantity, order_id):
    """
    Calls the insert_order_item stored procedure in PostgreSQL.
    """
    conn = await asyncpg.connect(**DB_CONFIG)
    try:
        await conn.execute(
            "CALL insert_order_item($1, $2, $3);",
            food_item,
            quantity,
            order_id
        )
        print("Item inserted successfully.")
        return 1
    except Exception as e:
        logging.error(f"Error inserting item: {e}")
        return -1
    finally:
        await conn.close()
        
        
async def get_total_order_price(order_id):
    """
    Calls the get_total_order_price(order_id) SQL function.
    Returns:
        - total price as float if successful
        - -1.0 if an error occurs
    """
    try:
        conn = await asyncpg.connect(**DB_CONFIG)
        try:
            result = await conn.fetchval(
                "SELECT get_total_order_price($1);",
                order_id
            )
            if result is not None:
                return float(result)
            return 0.0  # No items in order, maybe?
        finally:
            await conn.close()
    except Exception as e:
        logging.error(f"Error getting total order price for order_id {order_id}: {e}")
        return -1.0


async def insert_order_tracking(order_id: int, status: str) -> int:
    """
    Directly inserts into the order_tracking table.
    Returns 1 if insert is successful, -1 if an error occurs.
    """
    try:
        conn = await asyncpg.connect(**DB_CONFIG)
        try:
            await conn.execute(
                """INSERT INTO order_tracking(order_id, status)
                VALUES ($1, $2)
                ON CONFLICT (order_id) DO UPDATE SET status = EXCLUDED.status;""",
                order_id, status
            )
            return 1
        finally:
            await conn.close()
    except Exception as e:
        logging.error(f"Error inserting into order_tracking: {e}")
        return -1