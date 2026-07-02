import 'package:flutter/material.dart';
import '../app_state.dart';
import '../models.dart';
import '../widgets/app_drawer.dart';

class ChatPage extends StatefulWidget {
  final AppState appState;
  const ChatPage({super.key, required this.appState});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<IconData> icons = const [
    Icons.psychology_alt,
    Icons.self_improvement,
    Icons.nightlight_round,
    Icons.sentiment_satisfied,
    Icons.extension,
    Icons.spa,
    Icons.headset_mic,
    Icons.handshake,
  ];

  Peer? selectedPeer;

  final TextEditingController messageController = TextEditingController();
  final TextEditingController reportReasonController = TextEditingController();

  @override
  void dispose() {
    messageController.dispose();
    reportReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final matched = widget.appState.visibleMatchedPeers;

    return Scaffold(
      appBar: AppBar(title: const Text('Chatting')),
      drawer: const AppDrawer(),
      body: matched.isEmpty
          ? const Center(child: Text('No matches yet.'))
          : Row(
              children: [
                SizedBox(
                  width: 270,
                  child: ListView.builder(
                    itemCount: matched.length,
                    itemBuilder: (context, i) {
                      final peer = matched[i];
                      final isSelected = selectedPeer?.id == peer.id;
                      final iconData = icons[peer.avatarIndex % icons.length];

                      return ListTile(
                        selected: isSelected,
                        leading: CircleAvatar(
                          backgroundColor: Colors.indigo.withOpacity(0.12),
                          child: Icon(iconData, color: Colors.indigo),
                        ),
                        title: Text(peer.name),
                        subtitle: Text(
                          _lastMessagePreview(peer.id),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => setState(() => selectedPeer = peer),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: selectedPeer == null
                      ? const Center(child: Text('Select a chat'))
                      : _buildChatRoom(selectedPeer!),
                ),
              ],
            ),
    );
  }

  String _lastMessagePreview(String peerId) {
    final msgs = widget.appState.getMessagesForPeer(peerId);
    if (msgs.isEmpty) return 'Say hi';
    return msgs.last.text;
  }

  Widget _buildChatRoom(Peer peer) {
    final messages = widget.appState.getMessagesForPeer(peer.id);
    final iconData = icons[peer.avatarIndex % icons.length];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.indigo.withOpacity(0.12),
                child: Icon(iconData, color: Colors.indigo),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  peer.name,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                tooltip: 'Report',
                onPressed: () => _showReportDialog(peer),
                icon: const Icon(Icons.flag_outlined),
              ),
              IconButton(
                tooltip: 'Block',
                onPressed: () => _showBlockDialog(peer),
                icon: const Icon(Icons.block_outlined),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: messages.length,
            itemBuilder: (context, i) {
              final msg = messages[i];
              final isMe = msg.from == 'me';

              return Align(
                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  constraints: const BoxConstraints(maxWidth: 520),
                  decoration: BoxDecoration(
                    color: isMe
                        ? Colors.indigo.withOpacity(0.15)
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Text(msg.text, style: const TextStyle(fontSize: 15)),
                      const SizedBox(height: 4),
                      Text(
                        _timeLabel(msg.time),
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: messageController,
                  decoration: const InputDecoration(
                    hintText: 'Type a message',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  widget.appState.sendMessage(
                    peer: peer,
                    text: messageController.text,
                  );
                  messageController.clear();
                },
                child: const Text('Send'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _timeLabel(DateTime dt) {
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  Future<void> _showReportDialog(Peer peer) async {
    reportReasonController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Report ${peer.name}'),
          content: TextField(
            controller: reportReasonController,
            decoration: const InputDecoration(
              labelText: 'Reason',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final reason = reportReasonController.text.trim();
                widget.appState.reportPeer(peer: peer, reason: reason);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Report submitted')),
                );
              },
              child: const Text('Report'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showBlockDialog(Peer peer) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Block ${peer.name}?'),
          content: const Text('They will be removed from your chat list.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                widget.appState.blockPeer(peer: peer);
                setState(() {
                  if (selectedPeer?.id == peer.id) selectedPeer = null;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User blocked')),
                );
              },
              child: const Text('Block'),
            ),
          ],
        );
      },
    );
  }
}