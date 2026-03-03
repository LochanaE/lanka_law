import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:lanka_law/theme.dart';
import 'package:lanka_law/models/chat_thread.dart';
import 'package:lanka_law/services/threads_service.dart';
import 'package:lanka_law/screen_widgets/chat.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  Future<List<ChatThread>>? _threadsFuture;

  @override
  void initState() {
    super.initState();
    _loadThreads();
  }

  void _loadThreads() {
    final threadsService = Provider.of<ThreadsService>(context, listen: false);
    setState(() {
      _threadsFuture = threadsService.listThreads();
    });
  }

  Future<void> _createNewThread() async {
    final threadsService = Provider.of<ThreadsService>(context, listen: false);
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
      final newThread = await threadsService.createThread();
      if (mounted) {
        Navigator.pop(context); // Dismiss loading dialogue
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => chat(
              threadId: newThread.id,
              threadTitle: newThread.title,
            ),
          ),
        );
        _loadThreads(); // Reload after returning
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Dismiss loading dialogue
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create chat: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "AI Legal Assistant Chats",
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
      ),
      body: FutureBuilder<List<ChatThread>>(
        future: _threadsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Text('Error loading chats:', textAlign: TextAlign.center, style: GoogleFonts.inter(color: Colors.red)),
                   Padding(
                     padding: const EdgeInsets.all(16.0),
                     child: Text(snapshot.error.toString(), textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 12)),
                   ),
                   const SizedBox(height: 16),
                   ElevatedButton(
                     onPressed: _loadThreads,
                     child: const Text('Retry'),
                   ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.chat_bubble_outline_rounded, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    "No chats yet",
                    style: GoogleFonts.inter(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Create a new chat to get started",
                    style: GoogleFonts.inter(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final threads = snapshot.data!;
          // Sort threads by updatedAt descending just in case the backend doesn't
          threads.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

          return RefreshIndicator(
            onRefresh: () async {
              _loadThreads();
              await _threadsFuture;
            },
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: threads.length,
              itemBuilder: (context, index) {
                final thread = threads[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    child: const Icon(Icons.chat_bubble_rounded, color: AppTheme.primaryColor),
                  ),
                  title: Text(
                    thread.title,
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodyLarge?.color),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    "Last updated: ${thread.updatedAt.toLocal().toString().split('.')[0]}",
                    style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => chat(
                          threadId: thread.id,
                          threadTitle: thread.title,
                        ),
                      ),
                    );
                    _loadThreads(); // Refresh when returning
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewThread,
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text("New Chat", style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
