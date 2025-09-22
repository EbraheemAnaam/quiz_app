import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileDrawer extends StatelessWidget {
  const ProfileDrawer({super.key});

  Future<Map<String, dynamic>?> fetchProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return null;
    final res = await Supabase.instance.client
        .from('profiles')
        .select()
        .eq('user_id', user.id)
        .maybeSingle();
    return res;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: FutureBuilder<Map<String, dynamic>?>(
        future: fetchProfile(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final profile = snapshot.data;
          final user = Supabase.instance.client.auth.currentUser;
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(profile?['id'] ?? ''),
                accountEmail: Text(user?.email ?? ''),
                currentAccountPicture: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.score),
                title: Text('Score: ${profile?['score'] ?? 'N/A'}'),
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () async {
                  await Supabase.instance.client.auth.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacementNamed('/');
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
