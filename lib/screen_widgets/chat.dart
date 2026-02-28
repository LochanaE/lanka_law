import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lanka_law/theme.dart';
import 'package:lanka_law/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:lanka_law/services/language_provider.dart';
import 'package:lanka_law/models/chat_message.dart';
import 'package:lanka_law/services/chat_service.dart';

class chat extends StatefulWidget {
  const chat({super.key});

  @override
  State<chat> createState() => _chatState();
}

class _chatState extends State<chat> {
  final List<ChatMessage> messages = [];
  bool _initialized = false;
  bool _isLoading = false;
  final ChatService _chatService = ChatService();

  final TextEditingController inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      messages.add(ChatMessage(text: AppLocalizations.of(context)!.welcomeMessage, isUser: false));
      _initialized = true;
    }
  }

  @override
  void dispose() {
    inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void sendMessage() async {
    final text = inputController.text.trim();
    if (text.isEmpty) return;
    
    setState(() {
      messages.add(ChatMessage(text: text, isUser: true));
      inputController.clear();
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final responseMessage = await _chatService.sendMessage(text);
      if (mounted) {
        setState(() {
          messages.add(responseMessage);
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          messages.add(ChatMessage(
            text: e.toString().replaceAll('Exception: ', ''),
            isUser: false,
          ));
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.appTitle,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: AppTheme.primaryColor,
          ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: Theme.of(context).iconTheme,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey.shade200,
            height: 1.0,
          ),
        ),
        actions: const [
          ThemeToggle(),
          SizedBox(width: 8),
          LanguageToggle(),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20),
              itemCount: messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == messages.length) {
                  return const Padding(
                    padding: EdgeInsets.only(bottom: 16.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                }
                return ChatBubble(
                  message: messages[index].text,
                  isUser: messages[index].isUser,
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9),
            child: SuggestedTopicsRow(
              topics: [
                AppLocalizations.of(context)!.topicMarriage,
                AppLocalizations.of(context)!.topicLand,
                AppLocalizations.of(context)!.topicEPF
              ],
              onTopicSelected: (topic) {
                inputController.text = topic;
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: inputController,
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.chatHint,
                            hintStyle: GoogleFonts.inter(color: Colors.grey),
                            filled: true,
                            fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            suffixIcon: inputController.text.isNotEmpty 
                              ? IconButton(icon: const Icon(Icons.clear, size: 16), onPressed: inputController.clear)
                              : null,
                          ),
                          onSubmitted: (_) => sendMessage(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: const BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                          onPressed: sendMessage,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.disclaimer,
                    style: GoogleFonts.inter(fontSize: 10, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isUser;

  const ChatBubble({super.key, required this.message, required this.isUser});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.accentColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy_rounded, size: 16, color: AppTheme.accentColor),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: isUser ? AppTheme.primaryColor : (Theme.of(context).brightness == Brightness.dark ? AppTheme.primaryLight : Colors.white),
                gradient: isUser ? AppTheme.primaryGradient : null,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message,
                style: GoogleFonts.inter(
                  color: isUser ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (isUser) ...[
             const SizedBox(width: 8),
             const CircleAvatar(
               radius: 16,
               backgroundColor: AppTheme.backgroundColor,
               child: Icon(Icons.person, size: 16, color: AppTheme.primaryColor),
             ),
          ],
        ],
      ),
    );
  }
}

class LanguageToggle extends StatelessWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<Locale>(
      onSelected: (Locale locale) {
        Provider.of<LanguageProvider>(context, listen: false).setLocale(locale);
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<Locale>>[
        const PopupMenuItem<Locale>(
          value: Locale('en'),
          child: Text('English'),
        ),
        const PopupMenuItem<Locale>(
          value: Locale('si'),
          child: Text('සිංහල'),
        ),
        const PopupMenuItem<Locale>(
          value: Locale('ta'),
          child: Text('தமிழ்'),
        ),
      ],
      offset: const Offset(0, 40),
      child: Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.primaryColor.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                const Icon(Icons.language, size: 16, color: AppTheme.primaryColor),
                const SizedBox(width: 4),
                Text(
                  _getLanguageCode(context),
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getLanguageCode(BuildContext context) {
    final locale = Provider.of<LanguageProvider>(context).locale;
    switch (locale.languageCode) {
      case 'si':
        return 'SI';
      case 'ta':
        return 'TA';
      default:
        return 'EN';
    }
  }
}

class ThemeToggle extends StatelessWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppTheme.themeNotifier,
      builder: (context, mode, child) {
        final isDark = mode == ThemeMode.dark;
        return IconButton(
          icon: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () => AppTheme.toggleTheme(),
        );
      },
    );
  }
}

class SuggestedTopicsRow extends StatelessWidget {
  final List<String> topics;
  final Function(String) onTopicSelected;
  
  const SuggestedTopicsRow({
    super.key, 
    required this.topics,
    required this.onTopicSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: topics
            .map(
              (t) => Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ActionChip(
                  label: Text(t),
                  labelStyle: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                  backgroundColor: Colors.white,
                  side: BorderSide(color: AppTheme.primaryColor.withOpacity(0.2)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  onPressed: () => onTopicSelected(t),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
