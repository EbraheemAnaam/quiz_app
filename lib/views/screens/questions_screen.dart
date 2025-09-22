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

    return Center(
      child: Container(
        margin: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              textAlign: TextAlign.center,
              questionText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            ...choices.map((answer) {
              return AnswerButton(
                text: answer.toString(),
                onTap: () {
                  answerQuestion(answer.toString());
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}
