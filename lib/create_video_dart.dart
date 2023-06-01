import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'main.dart';

class CreateVideo extends StatefulWidget {
  const CreateVideo({Key? key}) : super(key: key);

  @override
  State<CreateVideo> createState() => _CreateVideoState();
}

String? path;

class _CreateVideoState extends State<CreateVideo> {
  late CameraController controller;
  late Future<void> initializeControllerFuture;
  bool isDisabled = false;
  late int _selectedCameraIndex = 0;

  @override
  void initState() {
    super.initState();
    controller = CameraController(cameras![0], ResolutionPreset.high);
    initializeControllerFuture = controller.initialize();
  }

  void _onSwitchCamera() {
    if (cameras != null && cameras!.isNotEmpty) {
      _selectedCameraIndex = (_selectedCameraIndex + 1) % cameras!.length;
      controller!.dispose();
      controller = CameraController(
        cameras![_selectedCameraIndex],
        ResolutionPreset.high,
      );
      controller!.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
        future: initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                Container(
                  alignment: Alignment.center,
                  child: CameraPreview(controller),
                ),
                Align(
                    alignment: Alignment.bottomCenter,
                    child: !controller.value.isRecordingVideo
                        ? RawMaterialButton(
                            onPressed: () async {
                              try {
                                await initializeControllerFuture;
                                path = join(
                                    (await getApplicationDocumentsDirectory())
                                        .path,
                                    "${DateTime.now()}.mp4");
                                setState(() {
                                  controller.startVideoRecording();
                                  isDisabled = true;
                                  isDisabled = !isDisabled;
                                });
                              } catch (e) {
                                print(e);
                              }
                            },
                            padding: const EdgeInsets.all(10.0),
                            shape: const CircleBorder(),
                            child: const Icon(
                              Icons.camera,
                              size: 50.0,
                              color: Colors.yellow,
                            ),
                          )
                        : null),
                Align(
                  alignment: Alignment.bottomRight,
                  child: controller.value.isRecordingVideo
                      ? RawMaterialButton(
                          onPressed: () {
                            setState(() {
                              if (controller.value.isRecordingVideo) {
                                controller.startVideoRecording();
                                isDisabled = false;
                                isDisabled = !isDisabled;
                              }
                            });
                          },
                          padding: EdgeInsets.all(10),
                          shape: const CircleBorder(),
                          child: const Icon(
                            Icons.stop,
                            size: 50.0,
                            color: Colors.red,
                          ),
                        )
                      : null,
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () {
                      _onSwitchCamera();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Container(
                        height: 50,
                        width: 50,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.green),
                        child: const Center(
                          child: Text(
                            "Switch camera",
                            style: TextStyle(fontSize: 10),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }
}
