import 'package:flutter/material.dart';
import '../app_state.dart';
import '../models.dart';
import '../widgets/app_drawer.dart';

class SwipePage extends StatefulWidget {
  final AppState appState;
  const SwipePage({super.key, required this.appState});

  @override
  State<SwipePage> createState() => _SwipePageState();
}

class _SwipePageState extends State<SwipePage> {
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

  late List<Peer> deck;
  int index = 0;

  double dragX = 0;
  double dragRotation = 0;

  @override
  void initState() {
    super.initState();
    _refreshDeck();
  }

  void _refreshDeck() {
    deck = widget.appState.candidatesForSwipe();
    index = 0;
    dragX = 0;
    dragRotation = 0;
  }

  @override
  Widget build(BuildContext context) {
    final total = deck.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Swiping')),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.favorite_border, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Peer ${total == 0 ? 0 : (index + 1)} of $total',
                  style: const TextStyle(color: Colors.grey),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => setState(_refreshDeck),
                  child: const Text('Refresh'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: total == 0 || index >= total
                ? const Center(
                    child: Text(
                      'No more peers available.',
                      textAlign: TextAlign.center,
                    ),
                  )
                : _buildCard(deck[index]),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.close),
                    label: const Text('No'),
                    onPressed: total == 0 || index >= total
                        ? null
                        : () => _doSwipe(isYes: false, peer: deck[index]),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check),
                    label: const Text('Yes'),
                    onPressed: total == 0 || index >= total
                        ? null
                        : () => _doSwipe(isYes: true, peer: deck[index]),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildCard(Peer peer) {
    return Center(
      child: AspectRatio(
        aspectRatio: 3 / 4,
        child: Stack(
          children: [
            if (index + 1 < deck.length)
              Positioned.fill(
                child: Transform.scale(
                  scale: 0.98,
                  child: _peerCard(deck[index + 1], preview: true),
                ),
              ),
            Positioned.fill(
              child: Transform.translate(
                offset: Offset(dragX, 0),
                child: Transform.rotate(
                  angle: dragRotation,
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      setState(() {
                        dragX = details.delta.dx;
                        dragRotation = (dragX / 300) * 0.25;
                      });
                    },
                    onPanEnd: (_) {
                      final shouldYes = dragX > 120;
                      final shouldNo = dragX < -120;

                      if (shouldYes) {
                        _doSwipe(isYes: true, peer: peer);
                      } else if (shouldNo) {
                        _doSwipe(isYes: false, peer: peer);
                      } else {
                        setState(() {
                          dragX = 0;
                          dragRotation = 0;
                        });
                      }
                    },
                    child: _peerCard(peer),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _peerCard(Peer peer, {bool preview = false}) {
    final iconData = icons[peer.avatarIndex % icons.length];
    final shared = widget.appState.sharedTagsWithPeer(peer);

    return Card(
      elevation: preview ? 2 : 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.indigo.withOpacity(0.12),
                  child: Icon(iconData, size: 26, color: Colors.indigo),
                ),
                const SizedBox(width: 12),
                Text(
                  peer.name,
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const Text(
              'Shared experiences',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: peer.tags.map((t) {
                final isShared = shared.contains(t);
                return Chip(
                  label: Text(t),
                  backgroundColor: isShared
                      ? Colors.green.withOpacity(0.18)
                      : Colors.indigo.withOpacity(0.10),
                  side: isShared
                      ? const BorderSide(color: Colors.green, width: 0.8)
                      : BorderSide.none,
                );
              }).toList(),
            ),
            const Spacer(),
            if (!preview && dragX != 0)
              Align(
                alignment: Alignment.center,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    dragX > 0 ? 'YES' : 'NO',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: dragX > 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _doSwipe({required bool isYes, required Peer peer}) async {
    setState(() {
      dragX = 0;
      dragRotation = 0;
    });

    if (!isYes) {
      widget.appState.swipeNo(peer: peer);
      setState(() => index++);
      return;
    }

    final didMatch = await widget.appState.swipeYes(peer: peer);
    setState(() => index++);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          didMatch ? 'Matched with ${peer.name}' : 'No shared tags.',
        ),
      ),
    );
  }
}