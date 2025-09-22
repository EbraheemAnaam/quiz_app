import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileController {
  Future<Map<String, dynamic>?> fetchProfile(String userId) async {
    final res = await Supabase.instance.client
        .from('profiles')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    return res;
  }
}
