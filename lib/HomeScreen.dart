import 'package:camera/camera.dart'; // 6. camera 패키지 임포트
import 'package:flutter/material.dart'; // 12번 수행시 자동으로 추가해야하는 클래스
import 'package:ssd_yolo_demo/BoundingBox.dart'; // 37번수행시 자동으로 추가해야하는 클래스
import 'package:ssd_yolo_demo/Camera.dart'; // 37번수행시 자동으로 추가해야하는 클래스
import 'package:tflite/tflite.dart'; // cf. 11번 수행시 자동으로 추가해야하는 클래스
import 'dart:math' as math; // 38번 수행시 자동으로 추가해야하는 클래스

// 4. 모델 이름 설정
const String ssd = "SSD MobileNet";

// 3. HomeScreen과 _HomeScreenState 클래스를 stateful하게 생성
class HomeScreen extends StatefulWidget {
  // 5. cameras변수를 리스트 타입으로 선언
  final List<CameraDescription> cameras;

  // 7. HomeScreen 초기화
  HomeScreen(this.cameras);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 8. _recognition, _imageHeight, _imageWidth, _model 선언
  List<dynamic> _recognitions;
  int _imageHeight = 0;
  int _imageWidth = 0;
  String _model = "";

  // 9. 모델을 생성하는 함수 만들기 async형태로...
  loadModel() async {
    // 10. 반환할 결과를 문자열로 선언
    String result;

    switch (_model) {
      // 11. _model이 ssd일 경우 tflite패키지를 이용하여 모델을 load
      //    이때 labels, model의 인자를 지정해주어야 함.
      //    그리고 사전에 assets 폴더에 위치해야 함
      //    load된 모델은 result의 변수에 담기게 됨. 이것을 출력하는 것으로 함수 종료
      case ssd:
        result = await Tflite.loadModel(
            labels: "assets/ssd_mobilenet.txt",
            model: "assets/ssd_mobilenet.tflite");
    }
    print(result);
  }

  // 34. onselectmodel 함수를 통해 모델을 지정하고 loadModel함수를 실행함
  onSelectModel(model) {
    setState(() {
      _model = model;
    });

    loadModel();
  }

  // 35. setRecognitions를 통해서 탐지된 객체, 그 높이와 너비를 state로 지정
  setRecognitions(recognitions, imageHeight, imageWidth) {
    setState(() {
      _recognitions = recognitions;
      _imageHeight = imageHeight;
      _imageWidth = imageWidth;
    });
  }

  // cf. 3번 생성시 같이 생성된 클래스 내부 기본 build 메서드
  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;

    // 12. Scaffold를 반환 body에 모델에 아무것도 지정되지 않은 문자열일 경우 빈 container를,
    //    뭐라도 있을 경우(ssd 모델일 경우) Stack 위젯을 넣어줌 (by 삼항연산자)
    return Scaffold(
      body: _model == ""
          ? Container()
          : Stack(
              children: [
                // 37. Camera위젯과 BoundingBox 위젯을 자식 위젯으로 넣어줌
                //    각 클래스에 전달해줌
                Camera(widget.cameras, _model, setRecognitions),
                BoundingBox(
                    // 38. 3항연산자를 이용하여 recognitions가 있을 경우에 전달
                    _recognitions == null ? [] : _recognitions,
                    math.max(_imageHeight, _imageWidth),
                    math.min(_imageHeight, _imageWidth),
                    screen.width,
                    screen.height,
                    _model)
              ],
            ),
      // 13. floatingActionButton 위젯 생성
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 36. 누를 경우 on selectmodel함수를 실행
          onSelectModel(ssd);
        },
        child: Icon(Icons.photo_camera),
      ),
    );
  }
}
