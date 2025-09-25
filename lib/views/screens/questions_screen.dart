import 'package:flutter/material.dart';
import '../components/answer_button.dart';
import 'package:quiz_app/controllers/quiz_controller.dart';

class QuestionsScreen extends StatefulWidget {
  const QuestionsScreen({
    super.key,
    required this.onSelectAnswer,
    required this.onComplete,
    required this.selectedAnswers,
  });

  final void Function(String answer) onSelectAnswer;
  final void Function() onComplete;
  final List<String> selectedAnswers;

  @override
  State<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  var currentQuestionIndex = 0;
  List<Map<String, dynamic>>? questions;
  bool loading = true;
  String? error;
  final QuizController _quizController = QuizController();

  @override
  void initState() {
    super.initState();
    fetchQuestions();
  }

  Future<void> fetchQuestions() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final res = await _quizController.fetchQuestions();
      setState(() {
        questions = res;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        loading = false;
      });
    }
  }

  void answerQuestion(String selectedAnswer) {
    widget.onSelectAnswer(selectedAnswer);
    setState(() {
      currentQuestionIndex++;
    });
    if (questions != null && currentQuestionIndex >= questions!.length) {
      widget.onComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return Center(child: Text('Error: $error'));
    }
    if (questions == null || questions!.isEmpty) {
      return const Center(child: Text('No questions found'));
    }
    if (currentQuestionIndex >= questions!.length) {
      // سيتم الانتقال تلقائياً إلى النتائج عبر onComplete
      return const SizedBox.shrink();
    }
    final current = questions![currentQuestionIndex];
    final String questionText = current['q'] ?? '';
    final List choices = current['c'] ?? [];

    final totalQuestions = questions!.length;
    final progress = currentQuestionIndex + 1;

    final themeColor = const Color(0xFF1976D2); // Light blue primary
    final bgGradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFBBDEFB), // Light blue 100
        Color(0xFF90CAF9), // Light blue 200
        Color(0xFF1976D2), // Blue 700
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 600;
        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(gradient: bgGradient),
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 60 : 12,
                  vertical: isTablet ? 40 : 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Progress Bar
                    Padding(
                      padding: const EdgeInsets.only(bottom: 18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          LinearProgressIndicator(
                            value: progress / totalQuestions,
                            backgroundColor: Colors.white.withOpacity(0.25),
                            color: themeColor,
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: Text(
                              'سؤال $progress من $totalQuestions',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: isTablet ? 18 : 14,
                                letterSpacing: 1.1,
                                fontFamily: 'Roboto',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isTablet ? 24 : 12),
                    // Question Card
                    Card(
                      elevation: 10,
                      shadowColor: themeColor.withOpacity(0.25),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 32 : 18,
                          vertical: isTablet ? 32 : 18,
                        ),
                        child: Text(
                          questionText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: themeColor,
                            fontSize: isTablet ? 28 : 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Montserrat',
                            height: 1.3,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Answer Options
                    ...choices.map<Widget>((answer) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          elevation: 5,
                          shadowColor: themeColor.withOpacity(0.18),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            splashColor: themeColor.withOpacity(0.13),
                            highlightColor: themeColor.withOpacity(0.07),
                            onTap: () => answerQuestion(answer.toString()),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: isTablet ? 22 : 16,
                                horizontal: isTablet ? 18 : 12,
                              ),
                              child: Center(
                                child: Text(
                                  answer.toString(),
                                  style: TextStyle(
                                    color: themeColor,
                                    fontSize: isTablet ? 20 : 16,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
