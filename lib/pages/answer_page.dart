import 'package:flutter/material.dart';

class AnwserPage extends StatefulWidget {
  String answer;
  AnwserPage({super.key, required this.answer});

  @override
  State<AnwserPage> createState() => _AnwserPageState();
}

class _AnwserPageState extends State<AnwserPage> with TickerProviderStateMixin {
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RotationTransition(
                turns: Tween(begin: 0.0, end: 1.0).animate(_rotationController),
                child: Image.asset('assets/images/bola.png',
                    width: 200, height: 200)),
            Text(
              widget.answer,
              style: const TextStyle(fontSize: 30),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Regresar'),
            ),
          ],
        ),
      ),
    );
  }
}
