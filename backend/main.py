# main.py
from fastapi import FastAPI, Request, HTTPException
from fastapi.responses import JSONResponse
from pydantic import Json
from .import db
import re
from .import generic

app = FastAPI()
inprogress_order = {}

@app.post("/")
async def webhook(request: Request):
    """
    Entry‑point for Dialogflow webhook calls.
    """
    payload = await request.json()
    intent = payload["queryResult"]["intent"]["displayName"]
    parameters = payload["queryResult"].get("parameters", {})
    output_contexts = payload['queryResult'].get('outputContexts', [])
    session_id = await generic.extract_session_id(output_contexts[0]['name'])
    intent_handler_dict = {
        "order.add - context: ongoing-order": add_to_order,
        "order.remove - context: ongoing-order": remove_from_order,
        "order.complete - context: ongoing-order": complete_order,
        "track.order - context: ongoing-tracking": track_order,
    }
    return await intent_handler_dict[intent](parameters,session_id)


async def track_order(parameters : dict,session_id: str):
    order_id = int(parameters.get("order_id"))
    order_status = await db.get_order_status(order_id)
    if order_status == "Order ID not found." :
        fullfillment_text = f"No order found with order id: {order_id}"
    elif order_status:
        fullfillment_text = f"The order status for order id: {order_id} is : {order_status}" 
    return JSONResponse(content={
            "fulfillmentText": fullfillment_text
        })

async def add_to_order(parameters : dict,session_id: str):
    food_item = parameters.get("food-item")
    quantities = parameters.get("number")
    if len(food_item) != len(quantities):
        fulfillment_text = "Sorry i didn't understand. Can you please specify food items and quantities clearly"
    else:
        new_food_dict = dict(zip(food_item,quantities))
        if session_id in inprogress_order:
            current_food_dict = inprogress_order[session_id]
            current_food_dict.update(new_food_dict)
            inprogress_order[session_id] = current_food_dict
        else:
            inprogress_order[session_id] = new_food_dict 
            
        order_string = await generic.get_str_from_food_dict(inprogress_order[session_id])
        fulfillment_text = f"So far you have {order_string}. Do you need anything else?"
    
    return JSONResponse(content={
            "fulfillmentText": fulfillment_text
        })
 
async def complete_order(parameters : dict,session_id: str):
    if session_id not in inprogress_order:
        fulfillment_text = "I'm having trouble finding your order. Sorry! Can you start a new order?"
    else:
        order = inprogress_order[session_id]
        order_id = await save_to_db(order)
        if order_id == -1:
            fulfillment_text = "Sorry, I couldn't process your order due to a system error. " \
                               "Please place the order again."
        else:
            order_total = await db.get_total_order_price(order_id)
            fulfillment_text = f"Awesome, we have placed your order. " \
                               f"Here is your order id # {order_id}. " \
                               f"Your total order is {order_total} which you can pay at the time of delivery !"
        
        del inprogress_order[session_id]
                               
    return JSONResponse(content= {
        "fulfillmentText" : fulfillment_text
    })
                
                
                
                
                
async def save_to_db(order: dict):
    next_order_id = await db.get_next_order_id()
    for food_item, quantity in order.items():
        rcode = await db.insert_order_item(food_item, quantity, next_order_id)
        if rcode == -1:
            return -1
        await db.insert_order_tracking(next_order_id,"in progress")
    return next_order_id

async def remove_from_order(parameters: dict, session_id: str):
    if session_id not in inprogress_order:
        return JSONResponse(content={
            "fulfillmentText": "I'm having trouble finding your order. Sorry! Can you start a new order?"
        })
        
    current_order = inprogress_order[session_id]
    food_items = parameters.get("food-item")
    removed_items  = []
    no_such_items = []
    for item in food_items:
        if item not in current_order:
            no_such_items.append(item)
        else:
            removed_items.append(item)
            del current_order[item]


    if len(removed_items)>0:
        fulfillment_text = f"Removed {', '.join(removed_items)} from your order. "
                               
    if len(no_such_items)>0:
        fulfillment_text = f"Sorry, we don't have {', '.join(no_such_items)} in your order. " 

    if len(current_order.keys()) == 0:
        fulfillment_text += "Your order is empty! Would you like to order something else?"
    else:
        order_string = await generic.get_str_from_food_dict(current_order)
        fulfillment_text += f"Here is what's left: {order_string}."
        
    return JSONResponse(content={
        "fulfillmentText" : fulfillment_text
    })  
        