import 'dart:math';

String generateId([int length = 12]) {
  const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final rand = Random();
  return List.generate(length, (_) => chars[rand.nextInt(chars.length)]).join();
}

class AppUser {
  final String id;
  final String email;

  String name;
  int avatarIndex;
  List<String> tags;

  AppUser({
    required this.id,
    required this.email,
    required this.name,
    required this.avatarIndex,
    required this.tags,
  });
}

class Peer {
  final String id;
  final String name;
  final int avatarIndex;
  final List<String> tags;

  Peer({
    required this.id,
    required this.name,
    required this.avatarIndex,
    required this.tags,
  });
}

class Message {
  final String id;
  final String peerId;
  final String from;
  final String text;
  final DateTime time;

  Message({
    required this.id,
    required this.peerId,
    required this.from,
    required this.text,
    required this.time,
  });
}