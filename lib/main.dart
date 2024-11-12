import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/robotController.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: '{SOLID}3D'),
      
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //bool arrowShow = false;
  String iconPath = "assets/dot.png";
  double iconRotationAngle = 0.0;
  late FocusNode _focusNode;
  final ValueNotifier<String> detectedInput = ValueNotifier("");
  final ValueNotifier<int> timerValue = ValueNotifier(0); // Timer countdown value
  Timer? countdownTimer; // Timer to control the countdown
  RobotController robotController = RobotController();

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.requestFocus(); // Request focus once at initialization
  }

  void _startCountdown(int seconds) {
    timerValue.value = seconds;
    countdownTimer?.cancel(); // Cancel any rexisting timer
    countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (timerValue.value > 1) {
        timerValue.value--;
      } else {
        timer.cancel();
        timerValue.value = 0;
        setState(() {
          iconPath = getImagePath('dot');
        });        
      }
    });
  }

  void _handleKeyPress(KeyEvent event) {
      
    //Get Action basted on key
    String key = event.logicalKey.keyLabel;
    BotAction botAction = robotController.findActionByKey(key);

    //Display STOPPED when EmergencyStop active
    if (robotController.checkEmergencyStop(botAction.name)) {
      timerValue.value = 0;
      countdownTimer?.cancel();
      detectedInput.value = "STOPPED! \n\n Press Y to unlock";
      iconPath = getImagePath('stop'); 
      setState(() {});
      return;
    }

    //Check if timer is still active
    if (timerValue.value > 0) return;
    
    
    //Check for passive key events
    if(event is KeyUpEvent) {
      detectedInput.value = "";
      iconPath = getImagePath('dot');
      setState(() {});
      return;
    }

    if (botAction.name == "QR") {
      iconPath = getImagePath(botAction.iconPath);
      _startCountdown(5);
      setState(() {});
      return;
    }

    if (detectedInput.value != botAction.label) {     
      detectedInput.value = botAction.label;
      iconPath = getImagePath(botAction.iconPath);
      iconRotationAngle = botAction.iconAngle;      
      setState(() {});
    }
  }

  String getImagePath(String pIconPath){
    return 'assets/$pIconPath.png';
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color.fromARGB(255, 2, 31, 82),
        title: Text(widget.title),
      ),
      body: KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: _handleKeyPress,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[

              Image.asset(
                'assets/3d.png',
                width: 100,
                height: 100,
              ),
              const SizedBox(height: 100),
              ValueListenableBuilder<String>(
                valueListenable: detectedInput,
                builder: (context, inputLabel, child) {
                  return Text(
                    inputLabel,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  );
                },
              ),
              const SizedBox(height: 30),

              // Timer display
              ValueListenableBuilder<int>(
                valueListenable: timerValue,
                builder: (context, value, child) {
                  return value > 0
                      ? Text(
                          'Placing QR \n Please Wait \n\n $value',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium,
                        )                        
                      : Container(); // Hide when timer is 0
                },
              ),

              const SizedBox(height: 30),

             
                Transform.rotate(
                  angle: iconRotationAngle,
                  child: Image.asset(
                    iconPath,
                    width: 100,
                    height: 100,
                  ),
                ),
              const SizedBox(height: 50),
              Text('Move analog or d pad for direction'),
              Text('Press B for emergency break'),
            ],
          ),
        ),
      ),
    );
  }
}
