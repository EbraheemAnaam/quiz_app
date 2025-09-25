import 'package:flutter/material.dart';
import 'package:quiz_app/controllers/chat_controller.dart';

class ChatScreen extends StatefulWidget {
  final String apiKey;
  const ChatScreen({super.key, required this.apiKey});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _loading = false;
  String? _error;
  late ChatController _chatController;

  @override
  void initState() {
    super.initState();
    _chatController = ChatController(apiKey: widget.apiKey);
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _loading = true;
      _error = null;
      _controller.clear();
    });
    try {
      final response = await _chatController.sendMessage(
        text,
        history: _messages.where((m) => m['role'] != 'error').toList(),
      );
      setState(() {
        _messages.add({'role': 'assistant', 'content': response});
      });
    } catch (e) {
      setState(() {
        _messages.add({'role': 'error', 'content': e.toString()});
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = const Color.fromARGB(255, 7, 116, 224);
    final bgGradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color.fromARGB(255, 48, 128, 209), Color.fromARGB(255, 10, 104, 197), Color.fromARGB(255, 134, 174, 228)],
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat with AI'),
        backgroundColor: themeColor,
        elevation: 2,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: bgGradient),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 18,
                  ),
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    final isUser = msg['role'] == 'user';
                    final isError = msg['role'] == 'error';
                    return Row(
                      mainAxisAlignment: isUser
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        if (!isUser)
                          CircleAvatar(
                            backgroundColor: themeColor.withValues(alpha: 0.15),
                            child: const Icon(
                              Icons.smart_toy,
                              color: Color(0xFF1976D2),
                            ),
                          ),
                        Flexible(
                          child: Container(
                            margin: EdgeInsets.only(
                              left: isUser ? 40 : 8,
                              right: isUser ? 8 : 40,
                              top: 6,
                              bottom: 6,
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color: isError
                                  ? Colors.red[100]
                                  : isUser
                                  ? Colors.white
                                  : themeColor.withOpacity(0.10),
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(18),
                                topRight: const Radius.circular(18),
                                bottomLeft: Radius.circular(isUser ? 18 : 4),
                                bottomRight: Radius.circular(isUser ? 4 : 18),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              msg['content'] ?? '',
                              style: TextStyle(
                                color: isError
                                    ? Colors.red[800]
                                    : isUser
                                    ? themeColor
                                    : Colors.black87,
                                fontWeight: isUser
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                fontStyle: isError
                                    ? FontStyle.italic
                                    : FontStyle.normal,
                                fontSize: 15,
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ),
                        ),
                        if (isUser)
                          CircleAvatar(
                            backgroundColor: themeColor.withOpacity(0.15),
                            child: const Icon(
                              Icons.person,
                              color: Color(0xFF1976D2),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              Container(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'Type your message...',
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(fontSize: 16),
                        onSubmitted: (_) => _sendMessage(),
                        enabled: !_loading,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: themeColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: themeColor.withValues(alpha: 0.18),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: _loading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.send, color: Colors.white),
                        onPressed: _loading ? null : _sendMessage,
                        tooltip: 'Send',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
