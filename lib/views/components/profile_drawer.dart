import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quiz_app/views/screens/chat_screen.dart';

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
      child: Container(
        color: Colors.white,
        child: FutureBuilder<Map<String, dynamic>?>(
          future: fetchProfile(),
          builder: (context, snapshot) {
            final user = Supabase.instance.client.auth.currentUser;
            if (!snapshot.hasData) {
              return ListView(
                padding: EdgeInsets.zero,
                children: [
                  UserAccountsDrawerHeader(
                    accountName: const Text(
                      '',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    accountEmail: const Text(
                      '',
                      style: TextStyle(
                        color: Color.fromARGB(179, 27, 127, 241),
                      ),
                    ),
                    currentAccountPicture: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const CircleAvatar(
                        radius: 36,
                        backgroundColor: Color.fromARGB(255, 47, 120, 194),
                        child: Icon(
                          Icons.person,
                          size: 38,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    decoration: BoxDecoration(color: Colors.white),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ],
              );
            }
            final profile = snapshot.data;
            return ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text(
                    profile?['full_name'] ?? '',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  accountEmail: Text(
                    user?.email ?? '',
                    style: const TextStyle(
                      color: Color.fromARGB(179, 6, 90, 199),
                      fontSize: 15,
                    ),
                  ),
                  currentAccountPicture: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.10),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const CircleAvatar(
                      radius: 36,
                      backgroundColor: Color.fromARGB(255, 221, 230, 240),
                      child: Icon(Icons.person, size: 38, color: Colors.white),
                    ),
                  ),
                  decoration: BoxDecoration(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    elevation: 0,
                    color: Colors.white.withOpacity(0.98),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(
                            Icons.chat,
                            color: Color(0xFF42A5F5),
                          ),
                          title: const Text(
                            'محادثة الذكاء الاصطناعي',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 2,
                          ),
                          onTap: () async {
                            // جلب apiKey بشكل آمن، أو مرر قيمة فارغة إذا لم يوجد العمود
                            String apiKey = '';
                            try {
                              final user =
                                  Supabase.instance.client.auth.currentUser;
                              if (user != null) {
                                final profileRes = await Supabase
                                    .instance
                                    .client
                                    .from('profiles')
                                    .select('api_key')
                                    .eq('user_id', user.id)
                                    .maybeSingle();
                                if (profileRes != null &&
                                    profileRes['api_key'] != null) {
                                  apiKey = profileRes['api_key'] as String;
                                }
                              }
                            } catch (e) {
                              // تجاهل أي خطأ (مثل عدم وجود العمود)
                              apiKey = '';
                            }
                            if (!context.mounted) return;
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ChatScreen(apiKey: apiKey),
                              ),
                            );
                          },
                        ),
                        Divider(
                          indent: 12,
                          endIndent: 12,
                          color: Colors.grey[300],
                        ),
                        ListTile(
                          leading: const Icon(
                            Icons.score,
                            color: Color(0xFF66BB6A),
                          ),
                          title: Text(
                            'Score: 0${profile?['score'] ?? 'N/A'}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 2,
                          ),
                        ),
                        Divider(
                          indent: 12,
                          endIndent: 12,
                          color: Colors.grey[300],
                        ),
                        ListTile(
                          leading: const Icon(
                            Icons.logout,
                            color: Color(0xFFEF5350),
                          ),
                          title: const Text(
                            'Logout',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 2,
                          ),
                          onTap: () async {
                            await Supabase.instance.client.auth.signOut();
                            if (context.mounted) {
                              Navigator.of(context).pop();
                              Navigator.of(context).pushReplacementNamed('/');
                            }
                          },
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            );
          },
        ),
      ),
    );
  }
}
