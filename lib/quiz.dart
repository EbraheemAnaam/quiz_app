import 'package:flutter/material.dart';
import 'package:quiz_app/data/questions.dart';
import 'package:quiz_app/screens/questions_screen.dart';
import 'package:quiz_app/screens/results_screen.dart';
import 'package:quiz_app/screens/start_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quiz_app/screens/auth_screen.dart';
import 'package:quiz_app/screens/add_question_screen.dart';
import 'package:quiz_app/components/profile_drawer.dart';

class Quiz extends StatefulWidget {
  const Quiz({super.key});

  @override
  State<Quiz> createState() => _QuizState();
}

class _QuizState extends State<Quiz> {
  List<String> selectedAnswers = [];
  var activeScreen = 'start-screen';

  void switchScreen() {
    setState(() {
      selectedAnswers = [];
      activeScreen = 'questions-screen';
    });
  }

  void chooseAnswer(String answer) {
    selectedAnswers.add(answer);
  }

  void goToResults() {
    setState(() {
      activeScreen = 'results-screen';
    });
  }

  void restartQuiz() {
    setState(() {
      selectedAnswers = [];
      activeScreen = 'questions-screen';
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget screenWidget = StartScreen(switchScreen);

    if (activeScreen == 'questions-screen') {
      screenWidget = QuestionsScreen(
        onSelectAnswer: chooseAnswer,
        onComplete: goToResults,
        selectedAnswers: selectedAnswers,
      );
    }

    if (activeScreen == 'results-screen') {
      screenWidget = ResultsScreen(
        chosenAnswers: selectedAnswers,
        onRestart: restartQuiz,
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Builder(
        builder: (context) => Scaffold(
          drawer: const ProfileDrawer(),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromARGB(255, 122, 70, 212),
                  Color.fromARGB(255, 71, 38, 128),
                ],
              ),
            ),
            child: screenWidget,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              // تحقق من حالة تسجيل الدخول باستخدام supabase
              final session =
                  await Supabase.instance.client.auth.currentSession;
              if (session == null) {
                // إذا لم يكن مسجلاً، انتقل إلى صفحة تسجيل الدخول
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => const AuthScreen()));
              } else {
                // إذا كان مسجلاً، انتقل إلى صفحة إضافة سؤال
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AddQuestionScreen()),
                );
              }
            },
            child: const Icon(Icons.add),
            tooltip: 'Add Question',
          ),
        ),
      ),
    );
  }
}
