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
        .eq('user_id', user.id);
    if (res.isNotEmpty) {
      return res.last;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: FutureBuilder<Map<String, dynamic>?>(
        future: fetchProfile(),
        builder: (context, snapshot) {
          final user = Supabase.instance.client.auth.currentUser;
          if (!snapshot.hasData) {
            return ListView(
              padding: EdgeInsets.zero,
              children: const [
                UserAccountsDrawerHeader(
                  accountName: Text(''),
                  accountEmail: Text(''),
                  currentAccountPicture: CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                ),
                ListTile(title: Text('Loading...')),
              ],
            );
          }
          final profile = snapshot.data;
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                accountName: const Text(''),
                accountEmail: Text(user?.email ?? ''),
                currentAccountPicture: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.chat),
                title: const Text('محادثة الذكاء الاصطناعي'),
                onTap: () {
                  Navigator.of(context).pushNamed('/chat');
                },
              ),
              ListTile(
                leading: const Icon(Icons.score),
                title: Text('Score: 0${profile?['score'] ?? 'N/A'}'),
              ),
              const Divider(),
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
