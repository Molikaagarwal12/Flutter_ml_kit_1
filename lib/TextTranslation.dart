import 'package:flutter/material.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

void main(){
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Text Translation",
        theme: ThemeData(
            primarySwatch: Colors.blue
        ),
        home: MyHomePage(title:"Text Translation HomePage")
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key,required this.title}) : super(key: key);
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController textEditingController=TextEditingController();
  String result='Translated text....';

  dynamic  modelManager;
  dynamic languageIdentifier;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    languageIdentifier = LanguageIdentifier(confidenceThreshold: 0.5);
    modelManager = OnDeviceTranslatorModelManager();
    checkAndDownloadModel();
  }
  bool isEnglishDownloaded=false;
  bool isHindiDownloaded=false;
  dynamic onDeviceTranslator;

  checkAndDownloadModel() async{
    print("Check Model Start");
    isEnglishDownloaded = await
    modelManager.isModelDownloaded(TranslateLanguage.english.bcpCode);
    isHindiDownloaded = await
    modelManager.isModelDownloaded(TranslateLanguage.hindi.bcpCode);

    if(!isEnglishDownloaded){
      isEnglishDownloaded= await
      modelManager.downloadModel(TranslateLanguage.english.bcpCode);
    }
    if(!isHindiDownloaded){
      isHindiDownloaded= await
      modelManager.downloadModel(TranslateLanguage.hindi.bcpCode);
    }
    // final TranslateLanguage sourceLanguage;
    // final TranslateLanguage targetLanguage;
    if(isEnglishDownloaded && isHindiDownloaded) {
      onDeviceTranslator = OnDeviceTranslator
        (sourceLanguage: TranslateLanguage.english,
          targetLanguage: TranslateLanguage.hindi);
    }
    print("Check Model End");
  }

  translateText(String text) async{
    if(isEnglishDownloaded && isHindiDownloaded) {
      final String response = await onDeviceTranslator.translateText(text);
      setState(() {
        result=response;
      });
    }
    identifyLanguages(result);
  }

  identifyLanguages(String text) async{
    final String response = await languageIdentifier.identifyLanguage(text);
    textEditingController.text+="($response)";
    final String response2 = await languageIdentifier.identifyLanguage(result);
    setState(() {
      result+="($response2)";
    });
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Container(
            color: Colors.black12,
            child: Column(
              children: [
                Container(
                  color: Colors.red,
                  margin: EdgeInsets.only(top: 20,left: 10,right: 10),
                  height: 50,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text("English",
                        style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                      Container(height: 48,width: 1,color: Colors.white,),
                      Text("Hindi",
                        style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 20,left: 2,right: 2),
                  width: double.infinity,
                  height: 250,
                  child: Card(
                    color: Colors.white,
                    child: Padding(
                      padding: EdgeInsets.all(8),
                      child: TextField(
                        controller: textEditingController,
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          hintText: 'Type Text here....',
                          filled: true,
                          border: InputBorder.none,
                        ),
                        style: TextStyle(color: Colors.black),
                        maxLines: 100,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 15,left: 13,right: 13),
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        textStyle: TextStyle(color: Colors.white),
                        primary: Colors.green
                    ),
                    child: Text("Translate"),
                    onPressed: (){
                      translateText(textEditingController.text);
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 15,left: 10,right: 10),
                  width: double.infinity,
                  height: 250,
                  child: Card(
                    color: Colors.white,
                    child: Container(
                      padding: EdgeInsets.all(15),
                      child: Text(
                        result,
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

