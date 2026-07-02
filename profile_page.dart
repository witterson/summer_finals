import 'package:flutter/material.dart';
import '../app_state.dart';
import '../widgets/app_drawer.dart';

class ProfilePage extends StatefulWidget {
  final AppState appState;
  const ProfilePage({super.key, required this.appState});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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

  final List<String> commonTags = const [
    'ADHD', 'Autism', 'Depression', 'Anxiety', 'Bipolar', 'PTSD',
    'OCD', 'Stress', 'Burnout', 'Sleep', 'Trauma', 'Grief',
  ];

  late TextEditingController nameController;
  final tagController = TextEditingController();

  int selectedAvatarIndex = 0;
  late List<String> selectedTags;

  @override
  void initState() {
    super.initState();
    final u = widget.appState.currentUser;

    selectedAvatarIndex = u?.avatarIndex ?? 0;
    selectedTags = List<String>.from(u?.tags ?? []);
    nameController = TextEditingController(text: u?.name ?? '');
  }

  @override
  void dispose() {
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
      appBar: AppBar(title: const Text('Profile / Tags')),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              'Customize your profile',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Display name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Choose your profile icon',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              children: List.generate(icons.length, (i) {
                final selected = i == selectedAvatarIndex;
                return GestureDetector(
                  onTap: () => setState(() => selectedAvatarIndex = i),
                  child: CircleAvatar(
                    radius: selected ? 30 : 26,
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
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.appState.updateProfile(
                    name: nameController.text,
                    avatarIndex: selectedAvatarIndex,
                    tags: selectedTags,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile updated')),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Save changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}