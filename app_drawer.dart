import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final indigo = Colors.indigo;

    return Drawer(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            color: indigo,
            padding: const EdgeInsets.fromLTRB(16, 60, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Image.asset(
                    'assets/peerpair1.png',
                    width: 40,
                    height: 40,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'PeerPair',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          _drawerItem(context, icon: Icons.home, label: 'Home', route: '/home'),
          _drawerItem(
            context,
            icon: Icons.swipe,
            label: 'Swiping',
            route: '/swipe',
          ),
          _drawerItem(
            context,
            icon: Icons.chat_bubble_outline,
            label: 'Chatting',
            route: '/chat',
          ),
          _drawerItem(
            context,
            icon: Icons.person,
            label: 'Profile / Tags',
            route: '/profile',
          ),
          const Spacer(),
          const Divider(height: 1),
          _drawerItem(
            context,
            icon: Icons.logout,
            label: 'Logout',
            route: '/logout',
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(label, style: const TextStyle(fontSize: 16)),
      onTap: () {
        Navigator.pop(context);
        final current = ModalRoute.of(context)?.settings.name;
        if (current == route) return;
        Navigator.pushNamed(context, route);
      },
    );
  }
}
