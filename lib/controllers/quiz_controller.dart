import 'package:supabase_flutter/supabase_flutter.dart';

class QuizController {
  Future<List<Map<String, dynamic>>> fetchQuestions() async {
    final res = await Supabase.instance.client.from('qus').select();
    return List<Map<String, dynamic>>.from(res);
  }

  Future<void> saveUserScore(String userId, int score) async {
    await Supabase.instance.client.from('profiles').upsert({
      'user_id': userId,
      'score': score,
    });
  }
}
