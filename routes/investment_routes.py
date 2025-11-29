from fastapi import APIRouter, File, UploadFile, HTTPException
from google import genai
from google.genai import types
from services.portfolio import get_stock_investments
from services.transaction_services import create_expense
import json

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

