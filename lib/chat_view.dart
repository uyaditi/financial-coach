import 'package:ezmoney/chat_view_model.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String? initialMessage;
  
  const ChatScreen({super.key, this.initialMessage});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _viewModel = ChatViewModel();
  final _scrollController = ScrollController();
  final _messageController = TextEditingController();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendMessage(widget.initialMessage!);
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: _viewModel.chatMessages.isEmpty 
              ? _buildEmptyState() 
              : _buildChatList(),
          ),
          if (_isProcessing) _buildTypingIndicator(),
          _buildChatInput(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1D29)),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          const Text('EZ Assistant', style: TextStyle(color: Color(0xFF1A1D29), fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Color(0xFF6B7280)),
          onPressed: () => setState(() => _viewModel.clearChat()),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)]),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 48),
            ),
            const SizedBox(height: 24),
            const Text(
              'Start a Conversation',
              style: TextStyle(color: Color(0xFF1A1D29), fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Ask me anything about your finances, investments, or financial planning!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 32),
            _buildSuggestionChips(),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChips() {
    final suggestions = [
      'How can I save more?',
      'Investment tips',
      'Plan for retirement',
      'Reduce expenses',
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: suggestions.map((s) => InkWell(
        onTap: () => _sendMessage(s),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.3)),
          ),
          child: Text(s, style: const TextStyle(color: Color(0xFF8B5CF6), fontSize: 14)),
        ),
      )).toList(),
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _viewModel.chatMessages.length,
      itemBuilder: (context, index) => _buildChatBubble(_viewModel.chatMessages[index]),
    );
  }

  Widget _buildChatBubble(ChatMessage m) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: m.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!m.isUser) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: m.isUser ? const LinearGradient(colors: [Color(0xFF3B82F6), Color(0xFF2563EB)]) : null,
                color: m.isUser ? null : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(m.isUser ? 16 : 4),
                  bottomRight: Radius.circular(m.isUser ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    m.message,
                    style: TextStyle(
                      color: m.isUser ? Colors.white : const Color(0xFF1A1D29),
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                  if (!m.isUser && m.suggestions != null && m.suggestions!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: m.suggestions!.map((s) => InkWell(
                        onTap: () => _sendMessage(s),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.3)),
                          ),
                          child: Text(s, style: const TextStyle(color: Color(0xFF8B5CF6), fontSize: 12, fontWeight: FontWeight.w600)),
                        ),
                      )).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (m.isUser) ...[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.person, color: Color(0xFF3B82F6), size: 18),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                3,
                (i) => Container(
                  width: 8,
                  height: 8,
                  margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                  decoration: const BoxDecoration(color: Color(0xFF8B5CF6), shape: BoxShape.circle),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Ask me anything...',
                    hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 15),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  style: const TextStyle(color: Color(0xFF1A1D29), fontSize: 15),
                  maxLines: null,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (v) => v.trim().isNotEmpty ? _sendMessage(v) : null,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)]),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF8B5CF6).withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: IconButton(
                onPressed: () => _messageController.text.trim().isNotEmpty ? _sendMessage(_messageController.text) : null,
                icon: const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage(String msg) {
    if (msg.trim().isEmpty) return;
    
    setState(() {
      _viewModel.addUserMessage(msg);
      _isProcessing = true;
      _messageController.clear();
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 200,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _viewModel.generateAIResponse(msg);
          _isProcessing = false;
        });

        Future.delayed(const Duration(milliseconds: 100), () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent + 200,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });
  }
}