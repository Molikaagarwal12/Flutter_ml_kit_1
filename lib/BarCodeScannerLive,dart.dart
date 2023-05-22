import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_flutter/livefeedapplication.dart';

late List<CameraDescription> _cameras;


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _cameras = await availableCameras();
  runApp(const CameraScreen());
}

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {

  late CameraController controller;
  CameraImage? img;
  String result="Results to be shown here";
  dynamic barCodeScanner;
  bool isBusy=false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final List<BarcodeFormat> formats = [BarcodeFormat.all];
    barCodeScanner = BarcodeScanner(formats:formats);

    controller=CameraController(_cameras[0], ResolutionPreset.high);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      controller.startImageStream((image) => {
        if(isBusy==false){
          img = image, doBarCodeScanning(),
          isBusy=true
        },
      });
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            print("User denied camera access");
            break;
          default:
            print("Handle other errors");
            break;
        }
      }
    });
  }

  doBarCodeScanning() async{
    InputImage inputImage=getInputImage();
    final List<Barcode> barcodes = await barCodeScanner.processImage(inputImage);

    for (Barcode barcode in barcodes) {
      final BarcodeType type = barcode.type;
      final Rect? boundingBox = barcode.boundingBox;
      final String? displayValue = barcode.displayValue;
      final String? rawValue = barcode.rawValue;

      // See API reference for complete list of supported types
      switch (type) {
        case BarcodeType.wifi:
          BarcodeWifi barcodeWifi = barcode.value as BarcodeWifi;
          result="WiFi:"+ barcodeWifi.password!;
          break;
        case BarcodeType.url:
          BarcodeUrl barcodeUrl = barcode.value as BarcodeUrl;
          result="Url:"+barcodeUrl.url!;
          break;
      }
    }
    setState(() {
      isBusy=false;
      result;
    });
  }


  InputImage getInputImage(){
    final WriteBuffer allBytes=WriteBuffer();
    for(final Plane plane in img!.planes){
      allBytes.putUint8List(plane.bytes);
    }
    final bytes=allBytes.done().buffer.asUint8List();
    final Size imageSize=Size(img!.width.toDouble(),img!.height.toDouble());
    final camera=_cameras[1];
    final imageRotations=InputImageRotationValue.fromRawValue(camera.sensorOrientation);
    final inputImageFormat=InputImageFormatValue.fromRawValue(img!.format.raw);

    final planeData=img!.planes.map(
          (Plane plane){
        return InputImagePlaneMetadata(bytesPerRow: plane.bytesPerRow,height: plane.height,width: plane.width);
      },).toList();
    final inputImageData=InputImageData(size: imageSize,
        imageRotation: imageRotations!, inputImageFormat: inputImageFormat!, planeData: planeData);
    final inputImage=InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);
    return inputImage;
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Stack(
          fit: StackFit.expand,
          children: [
            CameraPreview(controller),
            Container(
              margin: EdgeInsets.only(left: 10,bottom: 10),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  result, style: TextStyle(color: Colors.white,fontSize: 25),
                ),
              ),
            )
          ],
        )
    );
  }
}
