import 'package:flutter/material.dart';
import 'package:quiz_app/components/questions_summary.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({
    super.key,
    required this.chosenAnswers,
    required this.onRestart,
  });

  final void Function() onRestart;
  final List<String> chosenAnswers;

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  Future<List<Map<String, Object>>> getSummaryData() async {
    final List<Map<String, Object>> summary = [];
    final res = await Supabase.instance.client.from('qus').select();
    final List<Map<String, dynamic>> supabaseQuestions = List<Map<String, dynamic>>.from(res);
    for (var i = 0; i < widget.chosenAnswers.length; i++) {
      final q = i < supabaseQuestions.length ? supabaseQuestions[i] : null;
      summary.add({
        'questions_index': i,
        'question': q != null ? (q['q'] ?? '') : '',
        'correct_answer': q != null && q['c'] != null && q['a'] != null && (q['a'] as int) < (q['c'] as List).length ? (q['c'][q['a']] ?? '') : '',
        'user_answer': widget.chosenAnswers[i],
      });
    }
    return summary;
  }

  Future<void> setUserScore(int score) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    await Supabase.instance.client.from('profiles').upsert({
      'user_id': user.id,
      'score': score,
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, Object>>>(
      future: getSummaryData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final summary = snapshot.data!;
        final numTotalQuestions = summary.length;
        final numCorrectQuestions = summary.where((data) {
          return data['user_answer'] == data['correct_answer'];
        }).length;

        // حفظ النتيجة في profiles
        setUserScore(numCorrectQuestions);

        return SizedBox(
          width: double.infinity,
          child: Container(
            margin: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  textAlign: TextAlign.center,
                  'You answered $numCorrectQuestions out of $numTotalQuestions questions correctly!',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),
                QuestionsSummary(summary),
                const SizedBox(height: 30),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.restart_alt),
                  onPressed: widget.onRestart,
                  label: const Text('Restart Quiz!'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
