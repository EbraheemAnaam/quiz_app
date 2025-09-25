import 'package:flutter/material.dart';
import '../components/questions_summary.dart';
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
    final List<Map<String, dynamic>> supabaseQuestions =
        List<Map<String, dynamic>>.from(res);
    for (var i = 0; i < widget.chosenAnswers.length; i++) {
      final q = i < supabaseQuestions.length ? supabaseQuestions[i] : null;
      summary.add({
        'questions_index': i,
        'question': q != null ? (q['q'] ?? '') : '',
        'correct_answer':
            q != null &&
                q['c'] != null &&
                q['a'] != null &&
                (q['a'] as int) < (q['c'] as List).length
            ? (q['c'][q['a']] ?? '')
            : '',
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

        final themeColor = const Color(0xFF7A46D4);
        final correctColor = Colors.green[400]!;
        final wrongColor = Colors.red[400]!;
        final bgColor = Colors.white;
        final isTablet = MediaQuery.of(context).size.width > 600;

        return Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 80 : 16,
                vertical: isTablet ? 40 : 16,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Score Card
                  Card(
                    color: themeColor,
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 32,
                        horizontal: 24,
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Quiz Completed!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isTablet ? 28 : 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.1,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 24,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: [
                                BoxShadow(
                                  color: themeColor.withOpacity(0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              '$numCorrectQuestions / $numTotalQuestions',
                              style: TextStyle(
                                color: themeColor,
                                fontWeight: FontWeight.bold,
                                fontSize: isTablet ? 28 : 20,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Correct Answers',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: isTablet ? 16 : 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Summary Card
                  Card(
                    color: bgColor,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: QuestionsSummary(summary),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                        ),
                        icon: const Icon(Icons.restart_alt),
                        onPressed: widget.onRestart,
                        label: const Text('Restart Quiz'),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          foregroundColor: themeColor,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 2,
                        ),
                        icon: const Icon(Icons.home),
                        onPressed: () {
                          Navigator.of(
                            context,
                          ).popUntil((route) => route.isFirst);
                        },
                        label: const Text('Go Home'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Placeholder for results_screen.dart (to be moved here)
