import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import 'models.dart';

class AppState extends ChangeNotifier {
  final Map<String, AppUser> _usersByEmail = {};

  AppUser? currentUser;

  final List<Peer> candidates = [
    Peer(id: 'p1', name: 'Sam', avatarIndex: 0, tags: ['ADHD', 'Anxiety']),
    Peer(id: 'p2', name: 'Ava', avatarIndex: 1, tags: ['Autism', 'Overthinking']),
    Peer(id: 'p3', name: 'Noah', avatarIndex: 2, tags: ['Depression', 'Sleep']),
    Peer(id: 'p4', name: 'Mia', avatarIndex: 3, tags: ['Stress', 'Burnout']),
    Peer(id: 'p5', name: 'Ethan', avatarIndex: 4, tags: ['Trauma', 'Grounding']),
    Peer(id: 'p6', name: 'Lily', avatarIndex: 5, tags: ['Bipolar', 'Mood']),
    Peer(id: 'p7', name: 'Zoe', avatarIndex: 6, tags: ['ADHD', 'Sleep']),
  ];

  final Set<String> _blockedPeerIds = {};
  final Set<String> _reportedPeerIds = {};
  final Set<String> _seenPeerIds = {};

  final List<Peer> matchedPeers = [];

  final Map<String, List<Message>> conversations = {};

  bool isBlocked(String peerId) => _blockedPeerIds.contains(peerId);

  String _normTag(String t) => t.trim().toLowerCase();

  List<String> sharedTagsWithPeer(Peer peer) {
    if (currentUser == null) return [];

    final userTagsLower = currentUser!.tags.map(_normTag).toSet();
    return peer.tags.where((tag) => userTagsLower.contains(_normTag(tag))).toList();
  }

  bool hasSharedTags(Peer peer) => sharedTagsWithPeer(peer).isNotEmpty;

  List<Peer> candidatesForSwipe() {
    if (currentUser == null) return [];

    final matchedIds = matchedPeers.map((p) => p.id).toSet();

    return candidates.where((peer) {
      if (isBlocked(peer.id)) return false;
      if (matchedIds.contains(peer.id)) return false;
      if (_seenPeerIds.contains(peer.id)) return false;
      if (!hasSharedTags(peer)) return false;
      return true;
    }).toList();
  }

  List<Peer> get visibleMatchedPeers {
    return matchedPeers.where((p) => !_blockedPeerIds.contains(p.id)).toList();
  }

  List<Message> getMessagesForPeer(String peerId) {
    return conversations[peerId] ?? [];
  }

  Future<String?> register({
    required String email,
    required String name,
    required int avatarIndex,
    required List<String> tags,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final key = email.trim().toLowerCase();
    if (_usersByEmail.containsKey(key)) {
      return 'Email already registered';
    }

    final user = AppUser(
      id: generateId(),
      email: key,
      name: name.trim().isEmpty ? 'New User' : name.trim(),
      avatarIndex: avatarIndex,
      tags: tags.map((t) => t.trim()).where((t) => t.isNotEmpty).toList(),
    );

    _usersByEmail[user.email] = user;
    currentUser = user;
    notifyListeners();
    return null;
  }

  Future<String?> login({required String email}) async {
    await Future.delayed(const Duration(milliseconds: 250));

    final key = email.trim().toLowerCase();
    if (!_usersByEmail.containsKey(key)) {
      return 'No account found for that email';
    }

    currentUser = _usersByEmail[key];
    notifyListeners();
    return null;
  }

  void logout() {
    currentUser = null;
    matchedPeers.clear();
    conversations.clear();
    _blockedPeerIds.clear();
    _reportedPeerIds.clear();
    _seenPeerIds.clear();
    notifyListeners();
  }

  void updateProfile({
    required String name,
    required int avatarIndex,
    required List<String> tags,
  }) {
    if (currentUser == null) return;

    currentUser!
      ..name = name.trim().isEmpty ? 'User' : name.trim()
      ..avatarIndex = avatarIndex
      ..tags = tags.map((t) => t.trim()).where((t) => t.isNotEmpty).toList();

    notifyListeners();
  }

  void swipeNo({required Peer peer}) {
    _seenPeerIds.add(peer.id);
    notifyListeners();
  }

  Future<bool> swipeYes({required Peer peer}) async {
    if (_blockedPeerIds.contains(peer.id)) return false;

    final shared = sharedTagsWithPeer(peer);
    if (shared.isEmpty) return false;

    _seenPeerIds.add(peer.id);

    final alreadyMatched = matchedPeers.any((p) => p.id == peer.id);
    if (alreadyMatched) return false;

    matchedPeers.add(peer);

    conversations.putIfAbsent(peer.id, () => []);
    conversations[peer.id]!.add(
      Message(
        id: generateId(),
        peerId: peer.id,
        from: 'peer',
        text: _initialPeerMessage(shared),
        time: DateTime.now(),
      ),
    );

    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));
    conversations[peer.id]!.add(
      Message(
        id: generateId(),
        peerId: peer.id,
        from: 'peer',
        text: 'Want to share what helps you cope lately?',
        time: DateTime.now(),
      ),
    );

    notifyListeners();
    return true;
  }

  String _initialPeerMessage(List<String> sharedTags) {
    final tag = sharedTags.first;
    return 'Hey! We both relate to "$tag". How are you doing today?';
  }

  void sendMessage({required Peer peer, required String text}) {
    if (currentUser == null) return;

    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    conversations.putIfAbsent(peer.id, () => []);
    conversations[peer.id]!.add(
      Message(
        id: generateId(),
        peerId: peer.id,
        from: 'me',
        text: trimmed,
        time: DateTime.now(),
      ),
    );

    notifyListeners();

    Future.delayed(const Duration(seconds: 1), () {
      if (_blockedPeerIds.contains(peer.id)) return;

      final replies = [
        'That makes sense. Thanks for sharing.',
        'I relate. What usually triggers it for you?',
        'That sounds tough. Do you have any coping strategies?',
        'You are not alone. Want to try something together, like journaling?',
      ];

      final rand = Random();
      conversations[peer.id]!.add(
        Message(
          id: generateId(),
          peerId: peer.id,
          from: 'peer',
          text: replies[rand.nextInt(replies.length)],
          time: DateTime.now(),
        ),
      );

      notifyListeners();
    });
  }

  void reportPeer({required Peer peer, required String reason}) {
    _reportedPeerIds.add(peer.id);
    notifyListeners();
  }

  void blockPeer({required Peer peer}) {
    _blockedPeerIds.add(peer.id);
    matchedPeers.removeWhere((p) => p.id == peer.id);
    conversations.remove(peer.id);
    notifyListeners();
  }

  bool isReported(String peerId) => _reportedPeerIds.contains(peerId);
}