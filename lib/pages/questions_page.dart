import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'dart:math';
import 'dart:async';
import '../data/respuestas.dart';

class QuestionPage extends StatefulWidget {
  const QuestionPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _QuestionPageState createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage>
    with TickerProviderStateMixin {
  AudioPlayer audioPlayer = AudioPlayer();
  double positionY = 0;
  double screenHeight = 0;
  double screenWidth = 0;
  double ballSize = 250; // Tamaño de la bola
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = '';
  late Timer _timer;
  int ballTopCount = 0;
  bool ballStopped = true;

// Posición Y de la imagen

  @override
  void initState() {
    super.initState();
    AudioPlayer audioPlayer = AudioPlayer();
    audioPlayer.setReleaseMode(ReleaseMode.release);

    accelerometerEvents.listen((event) {
      setState(() {
        if (!ballStopped) {
          positionY += event.y * 100; // Ajusta la velocidad de movimiento aquí
          positionY = positionY.clamp(
              0,
              screenHeight / 2 -
                  ballSize); // Limita la posición en la mitad superior de la pantalla
          if ((positionY == 0) && (ballTopCount >= 0 && ballTopCount <= 100)) {
            // Verifica si la bola está en la parte superior de la pantalla
            ballTopCount++;
            audioPlayer.play(AssetSource('audios/touch.mp3'));

            if ((_lastWords.isNotEmpty) && (ballTopCount > 6)) {
              try {
                accelerometerEvents.drain();
                Navigator.pushNamed(context, '/answer',
                        arguments: obtenerRespuesta())
                    .then((value) => {
                          ballTopCount = 0,
                        });
                _lastWords = '';
                ballTopCount = 0;
                audioPlayer.stop();
              } catch (e, stackTrace) {
                print("Error: $e");
                print("Stack Trace: $stackTrace");
              }
            } // Incrementa el contador
          } else {
            // ballTopCount = 0;
          }

          _restartTimer();
        } // Reinicia el temporizador
      });
    });
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
    _timer = Timer(const Duration(seconds: 3), () {
      // Después de 3 segundos sin movimiento, posiciona la bola en la mitad superior de la pantalla
      setState(() {
        //  positionY = 0;
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
      ballStopped = true;
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

  String obtenerRespuesta() {
    if (_lastWords.isNotEmpty) {
      return respuestas[Random().nextInt(respuestas.length)];
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
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
          child: CuerpoQuestion(
              screenHeight: screenHeight,
              positionY: positionY,
              screenWidth: screenWidth,
              ballSize: ballSize,
              speechToText: _speechToText,
              speechEnabled: _speechEnabled,
              lastWords: _lastWords),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:

            // If not yet listening for speech start, otherwise stop
            _speechToText.isNotListening ? _startListening : _stopListening,
        tooltip: 'Listen',
        backgroundColor: const Color.fromARGB(255, 248, 247, 247),
        child: Icon(
          _speechToText.isNotListening ? Icons.mic_off : Icons.mic,
          color: Colors.green,
        ),
      ),
    );
  }
}

class CuerpoQuestion extends StatelessWidget {
  const CuerpoQuestion({
    super.key,
    required this.screenHeight,
    required this.positionY,
    required this.screenWidth,
    required this.ballSize,
    required SpeechToText speechToText,
    required bool speechEnabled,
    required String lastWords,
  })  : _speechToText = speechToText,
        _speechEnabled = speechEnabled,
        _lastWords = lastWords;

  final double screenHeight;
  final double positionY;
  final double screenWidth;
  final double ballSize;
  final SpeechToText _speechToText;
  final bool _speechEnabled;
  final String _lastWords;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(
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
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                // If listening is active show the recognized words
                _speechToText.isListening
                    ? 'Hablando...'
                    : _speechEnabled
                        ? _lastWords.isNotEmpty
                            ? 'agite el telefono'
                            : 'Presione el botón microfono para hacer una pregunta'
                        : 'El reconocimiento de voz no está disponible',
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                // If listening is active show the recognized words
                _lastWords,
                style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
