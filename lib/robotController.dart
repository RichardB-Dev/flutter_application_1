import 'dart:math';
import 'package:http/http.dart' as http;
import 'dart:convert'; // For JSON encoding and decoding if needed

class RobotController {

  bool emergencyStopActive = false;

  List<BotAction> actionList = [
    BotAction('Up', 'Up', 'Arrow Up', 'arrow1',true, 0.0, 1,0,0),      
    BotAction('Down', 'Down', 'Arrow Down', 'arrow1', true, pi, -1,0,0),
    BotAction('Right', 'Right', 'Arrow Right', 'arrow1', true, pi/2, 0,1,0),
    BotAction('Left', 'Left', 'Arrow Left', 'arrow1', true, -pi/2, 0,-1,0),    
    
    BotAction('RotateRight', 'Rotate Right', 'Game Button Right 1', 'turnright', true, 0, 0,0,1),    
    BotAction('RotateLeft', 'Rotate Left', 'Game Button Left 1', 'turnleft', true, 0, 0,0,-1),    

    BotAction('QR', '', 'Game Button A', 'qr', false, 0.0, 0,0,0),    
    BotAction('Break', 'Emergency Break', 'Game Button B', 'stop', false, 0.0, 0,0,0),    
    BotAction('BreakUnlock', 'Emergency Break Release', 'Game Button Y', 'dot', false, 0.0, 0,0,0)
  ];
  

  bool checkEmergencyStop(String key) {
    if (key == "BreakUnlock") {
      emergencyStopActive = false;
      return false;
    }
    else if (key == "Break") {
      emergencyStopActive = true;     
    }

    if(emergencyStopActive){
      sendPostRequest(findActionByKey('Break'));
    }
    return emergencyStopActive;
  }


 BotAction findActionByKey(String keyIdentifier) {
    try {
      return actionList.firstWhere(
        (action) => action.keyIdentifier == keyIdentifier
      );
    } catch (e) {
      BotAction botAction = BotAction.empty();
      //botAction.label = keyIdentifier;
      return botAction;
    }
  }

  //-- Note --
  //I dont know how you do your movement but just an example
  Future<void> sendPostRequest(BotAction botAction) async {
    final url = Uri.parse("http://192.168.1.60:8080/bot/sendmovement");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "X": botAction.moveX,
        "Y": botAction.moveY,
        "ROTATE": botAction.moveRotate,
      }),
    ); 
    if (response.statusCode == 200) {
      //...
    } else {
      //...
    }
  }


}


class BotAction {
  String name;
  String label;
  String keyIdentifier;

  String iconPath;
  bool iconShow;
  double iconAngle;  
  
  double moveX;
  double moveY;
  double moveRotate;

  BotAction(this.name, this.label, this.keyIdentifier, this.iconPath, this.iconShow, this.iconAngle, this. moveX, this. moveY, this. moveRotate);

  BotAction.empty()
        : name = '',
          label = '',
          keyIdentifier = '',
          iconPath = '',
          iconShow = false,
          iconAngle = 0.0,
          moveX = 0.0,
          moveY = 0.0,
          moveRotate = 0.0;
  
}

 






