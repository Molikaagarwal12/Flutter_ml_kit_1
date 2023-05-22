


import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:image_picker/image_picker.dart';

void main(){
  runApp(BarCodeScanner());
}

class BarCodeScanner extends StatefulWidget {
  const BarCodeScanner({Key? key}) : super(key: key);

  @override
  State<BarCodeScanner> createState() => _BarCodeScannerState();
}

class _BarCodeScannerState extends State<BarCodeScanner> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late ImagePicker imagePicker;
  File? _image;
  String result="Results will be shown here";
  dynamic imageLabeler;
  @override
  dynamic barcodeScanner;
  void initState() {
    // TODO: implement initState
    super.initState();
    final List<BarcodeFormat> formats = [BarcodeFormat.all];
    barcodeScanner = BarcodeScanner(formats: formats);
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
  _imgFromCamera() async {
    XFile? pickedFile = await imagePicker.pickImage(source: ImageSource.camera);
    _image=File(pickedFile!.path);
    if(pickedFile!=null){
      setState(() {
        _image;
        doBarCodeScanning();
      });
    }
  }
  _imgFromGallery() async {
    XFile? pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if(pickedFile!=null){
      setState(() {
        _image=File(pickedFile.path);
        doBarCodeScanning();
      });
    }
  }

  doBarCodeScanning() async {
    InputImage inputImage=InputImage.fromFile(_image!);
    final List<Barcode> barcodes = await barcodeScanner.processImage(inputImage);

    for (Barcode barcode in barcodes) {
      final BarcodeType type = barcode.type;
      final Rect? boundingBox = barcode.boundingBox;
      final String? displayValue = barcode.displayValue;
      final String? rawValue = barcode.rawValue;

      // See API reference for complete list of supported types
      switch (type) {
        case BarcodeType.wifi:
          BarcodeWifi? barcodeWifi = barcode.value as BarcodeWifi;
          result="wifi:"+ barcodeWifi.password!;
          break;
        case BarcodeType.url:
          BarcodeUrl? barcodeUrl = barcode.value as BarcodeUrl;
          result="Url:"+barcodeUrl.url!;
          break;
      }
      setState(() {
        result;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Container(
        decoration: BoxDecoration(
            image: DecorationImage(image: NetworkImage('https://images.pexels.com/photos/6373688/pexels-photo-6373688.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1'),fit: BoxFit.cover
            )
        ),
        child: Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(width: 100,),
                Container(
                  margin: EdgeInsets.only(top: 100),
                  child: Stack(
                    children: [
                      Image.network('https://images.pexels.com/photos/6202036/pexels-photo-6202036.jpeg',
                        height: 350,width: 350,
                      ),
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              primary: Colors.transparent,
                              shadowColor: Colors.transparent
                          ),
                          onPressed: _imgFromGallery,
                          onLongPress: _imgFromCamera,
                          child: Container(
                              margin: EdgeInsets.only(top: 12),
                              child: _image!=null?Image.file(_image!,
                                width: 325,
                                height: 325,
                                fit: BoxFit.fill,
                              ):Container(
                                width: 340,
                                height: 330,
                                child: Icon(Icons.camera_alt,
                                  color: Colors.black,
                                  size: 100,),
                              )
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 20),
                  child: Text(result,textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold),),
                )
              ],
            ),
          ),
          backgroundColor: Colors.transparent,
        ),
      ),
    );
  }
}

