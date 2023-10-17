import 'package:flutter/material.dart';
import 'package:ppm_4/pages/answer_page.dart';
import 'package:ppm_4/pages/questions_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: "/",
      routes: {
        "/": (context) => const QuestionPage(),
        "/answer": (context) => AnswerPage(
            answer: ModalRoute.of(context)!.settings.arguments.toString()),
      },
    );
  }
}
