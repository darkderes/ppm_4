import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'dart:math';
import 'dart:async';
import 'package:animated_background/animated_background.dart';

class QuestionPage extends StatefulWidget {
  const QuestionPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _QuestionPageState createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage>
    with TickerProviderStateMixin {
  String respuesta = '';
  final TextEditingController _preguntaController = TextEditingController();
  AudioPlayer audioPlayer = AudioPlayer();
  double positionY = 0;
  double screenHeight = 0;
  double screenWidth = 0;
  double ballSize = 250; // Tamaño de la bola
  SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  late Timer _timer;
  int ballTopCount = 0;
  bool ballStopped = true;

// Posición Y de la imagen

  final List<String> respuestas = [
    'Sí',
    'No',
    'Tal vez',
    'Definitivamente',
    'No lo sé',
    'Pregunta de nuevo más tarde',
  ];
  late AnimationController _rotationController;
  @override
  void initState() {
    super.initState();
    // AudioPlayer audioPlayer = AudioPlayer();
    // audioPlayer.setReleaseMode(ReleaseMode.loop);
    // audioPlayer.play(AssetSource('audios/fondo.mp3'));
    // baja el volumen
    audioPlayer.setVolume(0.1);
    accelerometerEvents.listen((event) {
      setState(() {
        if (!ballStopped) {
          positionY += event.x * 100; // Ajusta la velocidad de movimiento aquí
          positionY = positionY.clamp(
              0,
              screenHeight / 2 -
                  ballSize); // Limita la posición en la mitad superior de la pantalla
          if ((positionY == 0) && (ballTopCount < 100)) {
            // Verifica si la bola está en la parte superior de la pantalla
            ballTopCount++;

            if (ballTopCount == 100) {
              try {
                accelerometerEvents.drain();
                obtenerRespuesta();
                Navigator.pushNamed(context, '/answer', arguments: respuesta);
                _lastWords = '';
              } catch (e, stackTrace) {
                print("Error: $e");
                print("Stack Trace: $stackTrace");
              }
            } // Incrementa el contador
          }

          _restartTimer();
        } // Reinicia el temporizador
      });
    });
    AnimatedBackground(
      behaviour: RandomParticleBehaviour(),
      vsync: this,
      child: Text('Hello'),
    );
    _initSpeech();
    _startTimer();
  }

  /// This has to happen only once per app
  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {
      // ballStopped = false;
    });
  }

  // Función para iniciar el temporizador
  void _startTimer() {
    _timer = Timer(Duration(seconds: 3), () {
      // Después de 3 segundos sin movimiento, posiciona la bola en la mitad superior de la pantalla
      setState(() {
        positionY = 0;
      });
    });
  }

  // Función para reiniciar el temporizador
  void _restartTimer() {
    _timer?.cancel(); // Cancela el temporizador existente
    _startTimer(); // Inicia un nuevo temporizador
  }

  /// Manually stop the active speech recognition session
  /// Note that there are also timeouts that each platform enforces
  /// and the SpeechToText plugin supports setting timeouts on the
  /// listen method.
  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      //  ballStopped = true;
    });
  }

  /// This is the callback that the SpeechToText plugin calls when
  /// the platform returns recognized words.
  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
      ballStopped = false;
    });
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  void obtenerRespuesta() {
    setState(() {
      if (_lastWords.isNotEmpty) {
        respuesta = respuestas[Random().nextInt(respuestas.length)];
      } else {
        respuesta = '';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              height: screenHeight / 2,
              child: Stack(
                children: <Widget>[
                  Positioned(
                    top: positionY,
                    left: screenWidth / 2 - ballSize / 2,
                    child: Image.asset('assets/images/bola.png',
                        width: ballSize, height: ballSize),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    // If listening is active show the recognized words
                    _speechToText.isListening
                        ? 'Hablando...'
                        : _speechEnabled
                            ? 'Tap el botón para empezar a hablar'
                            : 'Función de reconocimiento de voz no disponible',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                      // If listening is active show the recognized words
                      '$_lastWords'),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:

            // If not yet listening for speech start, otherwise stop
            _speechToText.isNotListening ? _startListening : _stopListening,
        tooltip: 'Listen',
        child: Icon(_speechToText.isNotListening ? Icons.mic_off : Icons.mic),
      ),
    );
  }
}
