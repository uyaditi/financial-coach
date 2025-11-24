from datetime import datetime, timedelta
from typing import Dict, Any 

class ComplianceEngine:
    MAX_TRANSACTIiON_AMOUNT = 1000.0
    MAX_DAILY_LIMIT = 2000.0
    MAX_MONTHLY_LIMIT = 10000.0

    SUSPICIOUS_KEYWORDS = [
        "betting", "gambling", "crypto scam", "hack", "fraud", "darkweb", "adult services"
    ]

    BANNED_CATEGORIES = ["illelgal", "restricted", "fraudalent"]

    RAPID_TXN_LIMIT = 5
    RAPID_TXN_WINDOW = 2

    def check_payment(self, *, amount: float, user, payee: str, recent_transactions: list) -> Dict[str, Any]:
        
        # Rule 1: Hard cap of Transaction Amount
        if amount > self.MAX_TRANSACTIiON_AMOUNT:
            return {
                "status": "rejected", 
                "reason": "AMOUNT_TOO_HIGH", 
                "message": f"Payment of amount {amount} is too high. Max allowed is {self.MAX_TRANSACTIiON_AMOUNT}."
            }
        
        # Rule 2: Check for suspicious payee or notes 
        for word in self.SUSPICIOUS_KEYWORDS:
            if word in payee.lower():
                return {
                    "status": "rejected", 
                    "reason": "SUSPICIOUS_PAYEE", 
                    "message": f"Payment to {payee} is suspicious. Transaction flagged for safety."
                }

        # Rule 3: Daily spend limit check    
        today_spend = sum(t.amount for t in recent_transactions if t.timestamp.date() == datetime.now.date())

        if today_spend + amount > self.MAX_DAILY_LIMIT:
            return {
                "status": "rejected", 
                "reason": "DAILY_LIMIT_EXCEEDED", 
                "message": f"Daily spend limit exceeded. You have spent Rs.{today_spend} today."
            }
        
        # Rule 4: Rapid transaction check (Fraud Defense)
        now = datetime.now()
        rapid_txns = [
            t for t in recent_transactions
            if now - t.timestamp <= timedelta(minutes=self.RAPID_TXN_WINDOW)
        ]

        if len(rapid_txns) >= self.RAPID_TXN_LIMIT:
            return {
                "status": "rejected", 
                "reason": "RAPID_TXN_LIMIT_EXCEEDED", 
                "message": f"Rapid transaction limit exceeded. You have made {len(rapid_txns)} transactions in the last {self.RAPID_TXN_WINDOW} minutes."
            }
        
        
        return {"status": "approved"}