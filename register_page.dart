import 'package:flutter/material.dart';
import '../app_state.dart';

class RegisterPage extends StatefulWidget {
  final AppState appState;
  const RegisterPage({super.key, required this.appState});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final tagController = TextEditingController();

  int avatarIndex = 0;

  final List<String> commonTags = const [
    'ADHD', 'Autism', 'Depression', 'Anxiety', 'Bipolar', 'PTSD',
    'OCD', 'Stress', 'Burnout', 'Sleep', 'Trauma', 'Grief',
  ];

  final List<String> selectedTags = [];

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

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    tagController.dispose();
    super.dispose();
  }

  bool _isSelected(String tag) {
    return selectedTags.any((t) => t.toLowerCase() == tag.toLowerCase());
  }

  void _toggleTag(String tag) {
    final existing = selectedTags.firstWhere(
      (t) => t.toLowerCase() == tag.toLowerCase(),
      orElse: () => '',
    );
    setState(() {
      if (existing.isNotEmpty) {
        selectedTags.remove(existing);
      } else {
        selectedTags.add(tag);
      }
    });
  }

  void _addTypedTag() {
    final typed = tagController.text.trim();
    if (typed.isEmpty) return;

    final common = commonTags.firstWhere(
      (t) => t.toLowerCase() == typed.toLowerCase(),
      orElse: () => '',
    );

    if (common.isNotEmpty) {
      if (!_isSelected(common)) {
        setState(() => selectedTags.add(common));
      }
    } else {
      if (!_isSelected(typed)) {
        setState(() => selectedTags.add(typed));
      }
    }

    tagController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              'Create your account',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Choose a profile icon',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              children: List.generate(icons.length, (i) {
                final selected = i == avatarIndex;
                return GestureDetector(
                  onTap: () => setState(() => avatarIndex = i),
                  child: CircleAvatar(
                    radius: selected ? 26 : 24,
                    backgroundColor:
                        selected ? Colors.indigo : Colors.grey.shade300,
                    child: Icon(
                      icons[i],
                      size: selected ? 26 : 24,
                      color: selected ? Colors.white : Colors.black54,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            const Text(
              'Select your tags',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: commonTags.map((tag) {
                final selected = _isSelected(tag);
                return FilterChip(
                  label: Text(tag),
                  selected: selected,
                  onSelected: (_) => _toggleTag(tag),
                  selectedColor: Colors.indigo.withOpacity(0.20),
                  checkmarkColor: Colors.indigo,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: tagController,
                    onSubmitted: (_) => _addTypedTag(),
                    decoration: const InputDecoration(
                      labelText: 'Add a tag',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addTypedTag,
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (selectedTags.any((t) =>
                !commonTags.any((c) => c.toLowerCase() == t.toLowerCase()))) ...[
              const Text(
                'Your custom tags',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: selectedTags
                    .where((t) => !commonTags
                        .any((c) => c.toLowerCase() == t.toLowerCase()))
                    .map(
                      (t) => Chip(
                        label: Text(t),
                        onDeleted: () => setState(() => selectedTags.remove(t)),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final email = emailController.text.trim();
                  final name = nameController.text.trim();

                  final error = await widget.appState.register(
                    email: email,
                    name: name.isEmpty ? 'New User' : name,
                    avatarIndex: avatarIndex,
                    tags: selectedTags,
                  );

                  if (!mounted) return;

                  if (error != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(error)),
                    );
                  } else {
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/home', (r) => false);
                  }
                },
                child: const Text('Create account'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}