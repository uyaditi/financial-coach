from graph.graph_builder import build_graph

workflow = build_graph()

print("\n🤖 Financial AI Agent (type 'quit' to exit)\n")

while True:
    user = input("You: ")
    if user.lower() == "quit":
        break

    result = workflow.invoke({"input": user})
    print("RESULT:", result)
    # print("\n[AI]:", result["result"], "\n")
