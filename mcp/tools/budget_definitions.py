budget_tools_schema = [
    {
        "type": "function",
        "function": {
            "name": "create_budget_tool",
            "description": "Create a budget and return a natural language summary.",
            "parameters": {
                "type": "object",
                "properties": {
                    "user_id": {"type": "integer"},
                    "category": {"type": "string"},
                    "max_limit": {"type": "number"},
                    "time_period": {"type": "string"},
                },
                "required": ["user_id", "category", "max_limit"]
            }
        }
    },
    {
        "type": "function",
        "function": {
            "name": "get_budgets_tool",
            "description": "Fetch budgets and return a natural language summary.",
            "parameters": {
                "type": "object",
                "properties": {"user_id": {"type": "integer"}},
                "required": ["user_id"]
            }
        }
    },
    {
        "type": "function",
        "function": {
            "name": "update_budget_tool",
            "description": "Update a budget and return a natural language summary.",
            "parameters": {
                "type": "object",
                "properties": {
                    "user_id": {"type": "integer"},
                    "category": {"type": "string"},
                    "amount": {"type": "number"},
                    "time_period": {"type": "string"}
                },
                "required": ["user_id", "category", "amount"]
            }
        }
    }
]
