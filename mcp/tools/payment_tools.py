
import razorpay 
import os 

razorpay_client = razorpay.Client(auth=(os.getenv("RAZORPAY_TEST_API_KEY"), os.getenv("RAZORPAY_TEST_SECRET_KEY")))

def execute_payment(amount: float, payee: str):
   """
   Create a Razorpay UPI order
   """
   try: 
        order_data = {
            "amount": int(amount * 100), 
            "currency": "INR",
            "payment_capture": 1,
            "notes": {
                "payee": payee
            }
        }
      
        order = razorpay_client.order.create(order_data)

        return {
            "status": "pending", 
            "order_id": order["id"], 
            "upi_link": f"https://rzp.io/i/{order['id']}",
            "message": f"UPI payment link generated for ₹{amount}. Ask user to complete payment."
        }
   except Exception as e:
        return {"status": "error", "message": str(e)}
