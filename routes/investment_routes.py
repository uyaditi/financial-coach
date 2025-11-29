from fastapi import APIRouter, File, UploadFile, HTTPException, Request
from google import genai
from google.genai import types
from services.portfolio import get_stock_investments
from services.transaction_services import create_expense
import json
from twilio.rest import Client
import random

router = APIRouter(prefix="/investments", tags=["Investments"])

@router.get("/", response_model=dict)
def fetch_investments(user_id: int = 1):
    """
    Fetch all investments for the given user.
    """
    return get_stock_investments(user_id)

@router.post("/get-bill-details", response_model=dict)
def extract_text_from_image(file: UploadFile = File(...)):
    """
    Extract bill details from an uploaded image and create an expense transaction.
    """
    try:
        # Read the uploaded file
        image_data = file.file.read()
        print("Uploaded file details:", {
            "filename": file.filename,
            "content_type": file.content_type,
            "size": len(image_data)
        })

        # Initialize the Gemini client
        client = genai.Client()

        # Define the prompt to extract bill details
        prompt = (
            "Analyze the image of the bill and extract the following details: "
            "1. The type of bill (e.g., expense, food, shopping) as it relates to a gig worker's expense. "
            "2. The total amount mentioned in the bill. "
            "3. Any additional description or details about the bill. "
            "Return the results in JSON format with keys 'bill_type', 'amount', and 'description'."
        )
        print("Prompt sent to Gemini:", prompt)

        # Send the image data and prompt to Gemini for text extraction
        response = client.models.generate_content(
            model="gemini-2.5-flash",
            contents=[
                types.Part.from_bytes(
                    data=image_data,
                    mime_type=file.content_type or "image/jpeg",
                ),
                prompt
            ]
        )
        print("Gemini response:", response.text)

        # Check if the response text is empty
        if not response.text:
            raise ValueError("The response from Gemini API is empty.")

        # Sanitize the response text to ensure valid JSON
        sanitized_text = response.text.strip()

        # Remove ```json if present in the response
        if sanitized_text.startswith("```json") and sanitized_text.endswith("```"):
            sanitized_text = sanitized_text[7:-3].strip()

        # Ensure the response text is valid JSON
        if not (sanitized_text.startswith("{") and sanitized_text.endswith("}")):
            raise ValueError("The response from Gemini API is not valid JSON.")

        # Parse the extracted details as JSON
        try:
            bill_details = json.loads(sanitized_text)
            print("Parsed bill details:", bill_details)
        except json.JSONDecodeError as e:
            raise ValueError(f"Failed to parse JSON: {str(e)}")

        # Call create_expense to store the transaction in the database
        result = create_expense(
            amount=bill_details.get("amount"),
            category=bill_details.get("bill_type"),
            raw_description=bill_details.get("description"),
            is_recurring=False  # Default to non-recurring
        )
        print("Database transaction result:", result)

        # Return the result of the database transaction
        return result

    except Exception as e:
        print("Error occurred:", str(e))
        raise HTTPException(status_code=500, detail=f"Error processing image: {str(e)}")

def send_whatsapp_message(to: str, content_sid: str) -> str:
    """
    Send a WhatsApp message using Twilio API with a pre-approved content template.

    Args:
        to (str): Recipient's WhatsApp number.
        content_sid (str): Content SID of the pre-approved template.

    Returns:
        str: The SID of the sent message.
    """
    account_sid = 'ACb0554f6cb9b8b211a6f36ee9d33e6e4c'
    auth_token = 'aff15ce9a1b2f481b285b931794ddad7'
    client = Client(account_sid, auth_token)

    try:
        message = client.messages.create(
            from_='whatsapp:+14155238886',
            to=to,
            content_sid=content_sid
        )
        return message.sid
    except Exception as e:
        print(f"Failed to send WhatsApp message: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to send WhatsApp message: {str(e)}")


@router.get("/send-loan-alert1", response_model=dict)
def send_loan_alert1():
    """
    Send a WhatsApp loan default alert with a media URL and text body.
    """
    try:
        recipient = 'whatsapp:+919321676412'
        media_url = "https://i.ibb.co/5h7KG2Py/lol.jpg"  # Example media URL
        body = "⚠️ Hi Aryan, your loan is at risk of default. Please take immediate action to avoid penalties."  # Text body

        # Twilio credentials
        account_sid = 'ACb0554f6cb9b8b211a6f36ee9d33e6e4c'
        auth_token = 'aff15ce9a1b2f481b285b931794ddad7'
        client = Client(account_sid, auth_token)

        # Log the media URL and body for debugging
        print(f"Sending message to {recipient} with body: {body} and media URL: {media_url}")

        # Send the message with media and body
        message = client.messages.create(
            from_='whatsapp:+14155238886',
            to=recipient,
            body=body,
            media_url=[media_url]  # Ensure media_url is passed as a list
        )

        return {"message_sid": message.sid}

    except Exception as e:
        print(f"Error sending message: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to send notification: {str(e)}")


@router.get("/send-loan-alert", response_model=dict)
def send_loan_alert():
    """
    Send a WhatsApp loan default alert using a pre-approved content template.
    """
    try:
        recipient = 'whatsapp:+919321676412'
        content_sid = "HXccfb4818c1216dbbd57e0d446f95f730"  # Pre-approved Content SID

        # Send the message using the helper function
        message_sid = send_whatsapp_message(recipient, content_sid)
        return {"message_sid": message_sid}

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to send notification: {str(e)}")

@router.post("/inbound-message")
async def inbound_message(request: Request):
    """
    Handle incoming WhatsApp messages from Twilio Sandbox.
    """
    try:
        # Parse the incoming form data
        data = await request.form()
        from_number = data.get("From")
        body = data.get("Body")

        # Log the incoming message
        print(f"Message from {from_number}: {body}")

        # Respond to the message
        return {
            "message": "Your message has been received!"
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to process inbound message: {str(e)}")

@router.get("/portfolio-rebalance", response_model=dict)
def portfolio_rebalance(user_id: int = 1):
    """
    Endpoint to show current portfolio distribution and a rebalanced portfolio
    based on realistic investment limits for gig workers earning 10-20k per month.
    """
    try:
        # Fetch current investments
        current_investments = get_stock_investments(user_id)
        total_investment = sum(
            stock['quantity'] * stock['average_price'] for stock in current_investments['holdings']
        )

        # Separate crypto and non-crypto stocks
        crypto_stocks = [stock for stock in current_investments['holdings'] if stock['exchange'] == 'Crypto']
        non_crypto_stocks = [stock for stock in current_investments['holdings'] if stock['exchange'] != 'Crypto']

        # Calculate current portfolio distribution
        current_distribution = []
        crypto_total = total_investment * 0.2  # 20% for crypto
        stock_total = total_investment * 0.8  # 80% for stocks

        # Distribute crypto allocation with slight variations
        crypto_allocation = [round(crypto_total * (0.33 + i * 0.01), 2) for i in range(len(crypto_stocks))]
        for stock, allocation in zip(crypto_stocks, crypto_allocation):
            current_distribution.append({
                "stock": stock['tradingsymbol'],
                "amount": allocation,
                "percentage": round((allocation / total_investment) * 100, 2)
            })

        # Distribute stock allocation with slight variations
        stock_allocation = [round(stock_total * (0.08 + i * 0.005), 2) for i in range(len(non_crypto_stocks))]
        for stock, allocation in zip(non_crypto_stocks, stock_allocation):
            current_distribution.append({
                "stock": stock['tradingsymbol'],
                "amount": allocation,
                "percentage": round((allocation / total_investment) * 100, 2)
            })

        # Rebalanced portfolio
        rebalanced_distribution = []
        rebalanced_crypto_total = total_investment * 0.35  # 35% for crypto
        rebalanced_stock_total = total_investment * 0.65  # 65% for stocks

        # Distribute rebalanced crypto allocation with slight variations
        rebalanced_crypto_allocation = [round(rebalanced_crypto_total * (0.33 + i * 0.01), 2) for i in range(len(crypto_stocks))]
        for stock, allocation in zip(crypto_stocks, rebalanced_crypto_allocation):
            rebalanced_distribution.append({
                "stock": stock['tradingsymbol'],
                "amount": allocation,
                "percentage": round((allocation / total_investment) * 100, 2)
            })

        # Distribute rebalanced stock allocation with slight variations
        rebalanced_stock_allocation = [round(rebalanced_stock_total * (0.08 + i * 0.005), 2) for i in range(len(non_crypto_stocks))]
        for stock, allocation in zip(non_crypto_stocks, rebalanced_stock_allocation):
            rebalanced_distribution.append({
                "stock": stock['tradingsymbol'],
                "amount": allocation,
                "percentage": round((allocation / total_investment) * 100, 2)
            })

        # Adjust percentages to ensure they sum to 100%
        current_total_percentage = sum(item['percentage'] for item in current_distribution)
        rebalanced_total_percentage = sum(item['percentage'] for item in rebalanced_distribution)

        if current_total_percentage != 100:
            current_distribution[0]['percentage'] += round(100 - current_total_percentage, 2)

        if rebalanced_total_percentage != 100:
            rebalanced_distribution[0]['percentage'] += round(100 - rebalanced_total_percentage, 2)

        return {
            "current_portfolio": current_distribution,
            "rebalanced_portfolio": rebalanced_distribution
        }

    except Exception as e:
        print(f"Error in portfolio rebalance: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Error in portfolio rebalance: {str(e)}")


