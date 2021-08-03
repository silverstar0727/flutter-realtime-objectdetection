import 'package:flutter/material.dart'; // 20번 수행시 자동으로 추가해야하는 클래스
import 'package:camera/camera.dart'; // 22번 수행시 자동으로 추가해야하는 클래스
import 'package:tflite/tflite.dart';
import 'dart:math' as math;

// 21. callback 변수를 지정.
typedef void Callback(List<dynamic> list, int h, int w);

// 20. stateful 형태로 camera class 생성
class Camera extends StatefulWidget {
  // 22. cameras, setrecognitions, model 변수선언
  final List<CameraDescription> cameras;
  final Callback setRecognitions;
  final String model;

  // 23. 클래스 초기화
  Camera(this.cameras, this.model, this.setRecognitions);

  @override
  _CameraState createState() => new _CameraState();
}

// cf. 20번에서 함께 생성
class _CameraState extends State<Camera> {
  // 24. controller와 isdetecting 선언
  CameraController controller;
  bool isDetecting = false;

  // 27. initstate overriding
  @override
  void initState() {
    super.initState();

    // 28. cameras가 없거나, 카메라의 길이가 1 미만일때 오류를 출력함
    if (widget.cameras == null || widget.cameras.length < 1) {
      print('No camera is found');
    } else {
      // 존재할 경우엔 cameracontroller 위젯으로부터 controller 객체 생성
      controller = new CameraController(
        widget.cameras[0],
        ResolutionPreset.high,
      );
      // 29. contorller 초기화
      controller.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});

        // 30. controller를 통해 이미지 스트림 실행
        controller.startImageStream((CameraImage img) {
          if (!isDetecting) {
            isDetecting = true;

            int startTime = new DateTime.now().millisecondsSinceEpoch;

            // 31. tflite의 detectobjectonframe 메서드를 이용하여 이미지를 구성
            Tflite.detectObjectOnFrame(
              bytesList: img.planes.map((plane) {
                return plane.bytes;
              }).toList(),
              model: "SSDMobileNet",
              imageHeight: img.height,
              imageWidth: img.width,
              imageMean: 127.5,
              imageStd: 127.5,
              numResultsPerClass: 1,
              threshold: 0.4,
            ).then((recognitions) {
              int endTime = new DateTime.now().millisecondsSinceEpoch;
              print("Detection took ${endTime - startTime}");

              widget.setRecognitions(recognitions, img.height, img.width);

              isDetecting = false;
            });
          }
        });
      });
    }
  }

  // 32. dispose 메서드 오버라이딩
  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  // 25. build 메서드 오버라이딩
  @override
  Widget build(BuildContext context) {
    // 26. controller가 존재하지 않거나, 초기화되지 않았을 경우 비어있는 컨테이너를 반환
    if (controller == null || !controller.value.isInitialized) {
      return Container();
    }

    // 33. 예측 결과에 대해서 박스를 만들기
    var tmp = MediaQuery.of(context).size;
    var screenH = math.max(tmp.height, tmp.width);
    var screenW = math.min(tmp.height, tmp.width);
    tmp = controller.value.previewSize;
    var previewH = math.max(tmp.height, tmp.width);
    var previewW = math.min(tmp.height, tmp.width);
    var screenRatio = screenH / screenW;
    var previewRatio = previewH / previewW;

    return OverflowBox(
      maxHeight:
          screenRatio > previewRatio ? screenH : screenW / previewW * previewH,
      maxWidth:
          screenRatio > previewRatio ? screenH / previewH * previewW : screenW,
      child: CameraPreview(controller),
    );
  }
}
