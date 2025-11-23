
class ChatMessage {
  final String message;
  final bool isUser;
  final DateTime timestamp;
  final List<String>? suggestions;

  ChatMessage({
    required this.message,
    required this.isUser,
    required this.timestamp,
    this.suggestions,
  });
}

class ChatViewModel {
  List<ChatMessage> chatMessages = [];

  void addUserMessage(String message) {
    chatMessages.add(ChatMessage(
      message: message,
      isUser: true,
      timestamp: DateTime.now(),
    ));
  }

  void generateAIResponse(String userMessage) {
    String response;
    List<String>? suggestions;

    final lowerMessage = userMessage.toLowerCase();

    // Pattern matching for different types of questions
    if (lowerMessage.contains('save') && (lowerMessage.contains('5000') || lowerMessage.contains('more'))) {
      response = 'Great question! Saving an additional ₹5,000 per month would give you:\n\n'
          '💰 Extra ₹60,000 per year\n'
          '📈 Your ₹10L goal achieved 3-4 months earlier\n'
          '🎯 Total savings of ₹8.1L in 18 months\n\n'
          'Would you like me to run a detailed simulation?';
      suggestions = ['Run simulation', 'Compare with other options', 'Show me a plan'];
    } else if (lowerMessage.contains('gold')) {
      response = 'Investing in gold is a good diversification strategy! Here\'s what you should know:\n\n'
          '✨ Gold typically returns 8-12% annually\n'
          '🛡️ Acts as a hedge against inflation\n'
          '⚖️ Recommended allocation: 10-15% of portfolio\n\n'
          'Current gold price is around ₹6,200/gram. Want to explore gold investment options?';
      suggestions = ['Gold ETFs', 'Digital gold', 'Sovereign Gold Bonds'];
    } else if (lowerMessage.contains('eating out') || lowerMessage.contains('restaurant')) {
      response = 'Cutting down on dining out is one of the easiest ways to save! Average Indian households spend ₹3,000-8,000/month eating out.\n\n'
          '💡 If you reduce by 50%: Save ₹2,500/month\n'
          '💡 If you stop completely: Save ₹5,000/month\n'
          '📊 Annual savings: ₹30,000-60,000\n\n'
          'This could achieve your goal 2-3 months earlier!';
      suggestions = ['Calculate my savings', 'Meal planning tips', 'Set a budget'];
    } else if (lowerMessage.contains('sip') || lowerMessage.contains('mutual fund')) {
      response = 'Starting a SIP is excellent for long-term wealth creation!\n\n'
          '📈 Average mutual fund returns: 12-15% p.a.\n'
          '🎯 Best for goals 3+ years away\n'
          '💪 Rupee cost averaging benefit\n\n'
          'A ₹5,000 monthly SIP for 10 years at 12% return = ₹11.6 lakhs!\n'
          'Would you like me to suggest some funds?';
      suggestions = ['Top rated funds', 'Calculate SIP returns', 'Start SIP guide'];
    } else if (lowerMessage.contains('loan') || lowerMessage.contains('debt')) {
      response = 'Paying off loans early can save significant interest! Let me help you analyze:\n\n'
          '🏦 What type of loan? (Home/Personal/Car)\n'
          '💰 Outstanding amount?\n'
          '📊 Current interest rate?\n\n'
          'I\'ll calculate how much you can save by prepaying!';
      suggestions = ['Personal loan', 'Home loan', 'Car loan'];
    } else if (lowerMessage.contains('retire') || lowerMessage.contains('retirement')) {
      response = 'Planning early retirement? Smart thinking! Here\'s what matters:\n\n'
          '🎯 Retirement corpus needed = 25-30x annual expenses\n'
          '📈 Start investing more aggressively now\n'
          '💡 Consider NPS for tax benefits\n\n'
          'Tell me your target retirement age and monthly expenses, and I\'ll create a plan!';
      suggestions = ['Calculate corpus', 'Investment strategy', 'Tax saving tips'];
    } else if (lowerMessage.contains('house') || lowerMessage.contains('property')) {
      response = 'Buying vs waiting is a big decision! Key factors to consider:\n\n'
          '🏠 NOW: Lock current prices, start building equity\n'
          '⏳ LATER: More savings, potentially better rates\n'
          '💰 Down payment ready? Aim for 20-30%\n'
          '📊 EMI should be <40% of income\n\n'
          'What\'s your current savings and target property price?';
      suggestions = ['Calculate EMI', 'Down payment needed', 'Compare rent vs buy'];
    } else if (lowerMessage.contains('job') || lowerMessage.contains('salary')) {
      response = 'A higher salary can accelerate all your financial goals!\n\n'
          '💼 Even a 20% increase = Major impact\n'
          '🎯 Use raise wisely: 50% to savings/investments\n'
          '📈 Update financial goals with new income\n\n'
          'What salary increase are you expecting? Let me show the impact!';
      suggestions = ['Show impact of 20% raise', '30% raise', '50% raise'];
    } else if (lowerMessage.contains('invest') || lowerMessage.contains('investment')) {
      response = 'Great that you\'re thinking about investing! Here\'s a quick guide:\n\n'
          '📊 Stocks/Equity MF: High returns (12-15%), higher risk\n'
          '🏦 Debt/Fixed Deposits: Lower returns (6-8%), safer\n'
          '🏠 Real Estate: Long-term, needs large capital\n'
          '💎 Gold: 8-10%, hedge against inflation\n\n'
          'Diversification is key! What\'s your risk appetite?';
      suggestions = ['Conservative', 'Moderate', 'Aggressive'];
    } else if (lowerMessage.contains('expense') || lowerMessage.contains('reduce')) {
      response = 'Smart move! Here are top ways to reduce expenses:\n\n'
          '🍽️ Reduce dining out: Save ₹3-5k/month\n'
          '📱 Cancel unused subscriptions: Save ₹1-2k/month\n'
          '🚗 Use public transport more: Save ₹2-4k/month\n'
          '⚡ Reduce utility bills: Save ₹500-1k/month\n\n'
          'Total potential savings: ₹6,500-12,000/month!';
      suggestions = ['Create a budget', 'Track expenses', 'Set spending limits'];
    } else if (lowerMessage.contains('tax') || lowerMessage.contains('80c')) {
      response = 'Tax saving is important! Here are Section 80C options:\n\n'
          '💰 PPF: 7.1% return, tax-free, 15 years lock-in\n'
          '📈 ELSS: 12-15% returns, 3 years lock-in\n'
          '🏦 NSC: 7% return, 5 years lock-in\n'
          '🏠 Home Loan Principal: Deduction up to ₹1.5L\n\n'
          'Max deduction: ₹1.5 lakh under 80C. Which interests you?';
      suggestions = ['PPF vs ELSS', 'Calculate tax savings', 'More tax options'];
    } else if (lowerMessage.contains('emergency') || lowerMessage.contains('fund')) {
      response = 'Emergency fund is crucial! Here\'s what you need:\n\n'
          '🎯 Target: 6 months of expenses\n'
          '💵 Keep it liquid (savings account/liquid fund)\n'
          '🚨 Use only for real emergencies\n'
          '📈 Build gradually - even ₹5k/month helps\n\n'
          'If you spend ₹40k/month, aim for ₹2.4L emergency fund!';
      suggestions = ['Calculate my target', 'Where to keep it?', 'Start building now'];
    } else if (lowerMessage.contains('how') && lowerMessage.contains('save')) {
      response = 'Here are proven ways to save more money:\n\n'
          '1️⃣ Pay yourself first - Auto-transfer to savings\n'
          '2️⃣ Follow 50-30-20 rule (needs-wants-savings)\n'
          '3️⃣ Track every expense for 1 month\n'
          '4️⃣ Set specific savings goals\n'
          '5️⃣ Automate your SIPs\n\n'
          'Even saving ₹5,000 extra per month = ₹60,000 per year!';
      suggestions = ['50-30-20 rule', 'Set a goal', 'Start tracking'];
    } else {
      response = 'I\'m here to help with your financial planning! I can help you with:\n\n'
          '💰 Savings strategies\n'
          '📊 Investment advice\n'
          '🎯 Goal planning\n'
          '💳 Debt management\n'
          '🏠 Major purchases\n'
          '📈 Tax planning\n\n'
          'Try asking me a specific question about any of these topics!';
      suggestions = [
        'Save ₹5,000 more',
        'Start investing',
        'Plan retirement',
        'Buy a house'
      ];
    }

    chatMessages.add(ChatMessage(
      message: response,
      isUser: false,
      timestamp: DateTime.now(),
      suggestions: suggestions,
    ));
  }

  void clearChat() {
    chatMessages.clear();
  }
}