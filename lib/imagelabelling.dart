


import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:image_picker/image_picker.dart';

void main(){
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
  void initState() {
    // TODO: implement initState
    super.initState();
    imagePicker=ImagePicker();
    final ImageLabelerOptions options = ImageLabelerOptions(confidenceThreshold: 0.5);
    imageLabeler = ImageLabeler(options: options);
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
        doImageLabelling();
      });
    }
  }
  _imgFromGallery() async {
    XFile? pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);

    if(pickedFile!=null){
      setState(() {
        _image=File(pickedFile.path);
        doImageLabelling();
      });
    }
  }

  doImageLabelling() async {
    InputImage inputImage=InputImage.fromFile(_image!);
    final List<ImageLabel> labels = await imageLabeler.processImage(inputImage);
    result="";
    for (ImageLabel label in labels) {
      final String text = label.label;
      final int index = label.index;
      final double confidence = label.confidence;
      result+=text+"   "+confidence.toString()+"\n";
    }
    setState(() {
      result;     });
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
                        height: 400,width: 400,
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
                              margin: EdgeInsets.only(top: 8),
                              child: _image!=null?Image.file(_image!,
                                width: 335,
                                height: 495,
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

