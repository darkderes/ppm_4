import 'package:flutter/material.dart';

class AnswerPage extends StatefulWidget {
  String answer;
  AnswerPage({super.key, required this.answer});

  @override
  State<AnswerPage> createState() => _AnswerPageState();
}

class _AnswerPageState extends State<AnswerPage> with TickerProviderStateMixin {
  double rotationAngle = 0.0;
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      duration:
          const Duration(seconds: 4), // Puedes ajustar la velocidad de rotación
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 5.5,
            colors: [
              Color(0xFF167016), // Color verde brillante
              Colors.white, // Color blanco
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RotationTransition(
                  turns:
                      Tween(begin: 0.0, end: 1.0).animate(_rotationController),
                  child: Image.asset('assets/images/bola.png',
                      width: 200, height: 200)),
              Text(
                widget.answer,
                style: const TextStyle(fontSize: 30, color: Colors.white),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        const Color.fromARGB(255, 13, 13, 14)),
                    fixedSize:
                        MaterialStateProperty.all<Size>(const Size(200, 60)),
                  ),
                  child: const Text('Regresar')),
            ],
          ),
        ),
      ),
    );
  }
}
