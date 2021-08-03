import 'package:camera/camera.dart'; //17번 수행시 자동으로 추가해야하는 클래스
import 'package:flutter/material.dart'; // 15번 수행시 자동으로 추가해야하는 클래스
import 'package:ssd_yolo_demo/HomeScreen.dart'; //18번 수행시 자동으로 추가해야하는 클래스

// 14. cameras 변수에 마찬가지로 리스트형태로 선언
List<CameraDescription> cameras;

//  15. state less로 메인함수를 정하는데 비동기식으로 지정
Future<Null> main() async {
  // 16. widgetflutterbinding 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // 17. 카메라 실행을 시도해보고 안된다면 에러메시지를 출력
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error $e.code \n Error Message: $e.message');
  }

  runApp(new MainScreen());
}

// 18. stateless 형태로 mainscreen class 선언 후 HomeScreen에 cameras를 넘겨줌
class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(cameras),
    );
  }
}
