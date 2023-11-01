// ignore_for_file: prefer_foreach

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:minio_new/minio.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final minio = Minio(
    endPoint: 's3-ap-northeast-1.amazonaws.com',
    region: 'ap-northeast-1',

    //
    accessKey: 'AKIA34XYAHBV2VZORD5Q',
    secretKey: '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',
    //
  );

  ///
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('タイトル')),
      body: Column(
        children: [
          ///

          Center(
            child: FutureBuilder(
              future: getImage(),
              builder: (BuildContext context, AsyncSnapshot<Image> snapshot) {
                if (snapshot.hasData) {
                  return Center(child: snapshot.data);
                } else {
                  return const Center(
                    child: Text('データが取得できていません'),
                  );
                }
              },
            ),
          ),

          ///

          const SizedBox(height: 30),
          GestureDetector(
            onTap: uploadImage,
            child: const Icon(Icons.ac_unit_outlined),
          ),
          const SizedBox(height: 30),

          ///

          ElevatedButton(
            onPressed: galleryUpload,
            child: const Text('ギャラリー'),
          ),

          ///

          ElevatedButton(
            onPressed: cameraUpload,
            child: const Text('カメラ'),
          ),
        ],
      ),
    );
  }

  ///
  Future<Image> getImage() async {
    final stream = await minio.getObject('s3test20230128toyoda', 'aotoyo.png');

    final memory = <int>[];

    await for (final value in stream) {
      memory.addAll(value);
    }

    return Image.memory(Uint8List.fromList(memory));
  }

  ///
  Future<void> uploadImage() async {
    final byteData = await rootBundle.load('assets/images/20231031_160819638.jpg');

    final imageBytes = Stream<Uint8List>.value(
      byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
    );

    await minio.putObject('s3test20230128toyoda', '${DateTime.now()}.png', imageBytes);
  }

  ///
  Future<void> galleryUpload() async {
    final imagePicker = ImagePicker();

    final file = await imagePicker.pickImage(source: ImageSource.gallery);

    final fileExtension = file!.path.substring(file.path.lastIndexOf('.'));

    final newFileName = '${DateTime.now()}$fileExtension';

    final imageFile = File(file.path);

    final imageRaw = await imageFile.readAsBytes();

    await minio.putObject('s3test20230128toyoda', newFileName, Stream.value(imageRaw));
  }

  ///
  Future<void> cameraUpload() async {
    final imagePicker = ImagePicker();

    final file = await imagePicker.pickImage(source: ImageSource.camera);

    final fileExtension = file!.path.substring(file.path.lastIndexOf('.'));

    final newFileName = '${DateTime.now()}$fileExtension';

    final imageFile = File(file.path);

    final imageRaw = await imageFile.readAsBytes();

    await minio.putObject('s3test20230128toyoda', newFileName, Stream.value(imageRaw));
  }
}
