import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tuple/tuple.dart';

import 'chatbot_page.dart';

class ClassifierScreen extends StatefulWidget {
  @override
  _ClassifierScreenState createState() => _ClassifierScreenState();
}

class _ClassifierScreenState extends State<ClassifierScreen> {
  Interpreter? _interpreter;
  File? _imageFile;
  String _prediction = "No image selected";
  String _classificationDetails = "";

  final List<String> classLabels = [
    "Battery", "Biological","brown-glass", "Cardboard", "Clothes", "Glass",
    "green-glass", "Metal", "Paper", "Plastic", "Shoes", "Trash", "white-glass"
  ];

  Map<String, Tuple3<String, String, String>> wasteClassification = {
    "Battery": Tuple3("Non-Biodegradable", "Not Reusable", "Recyclable"),
    "Biological": Tuple3("Biodegradable", "Not Reusable", "Not Recyclable"),
    "brown-glass": Tuple3("Non-Biodegradable", "Not Reusable", "Recyclable"),
    "Cardboard": Tuple3("Biodegradable", "Reusable", "Recyclable"),
    "Clothes": Tuple3("Non-Biodegradable", "Reusable", "Recyclable"),
    "Glass": Tuple3("Non-Biodegradable", "Not Reusable", "Recyclable"),
    "green-glass": Tuple3("Non-Biodegradable", "Not Reusable", "Recyclable"),
    "Metal": Tuple3("Non-Biodegradable", "Reusable", "Recyclable"),
    "Paper": Tuple3("Biodegradable", "Reusable", "Recyclable"),
    "Plastic": Tuple3("Non-Biodegradable", "Reusable", "Recyclable"),
    "Shoes": Tuple3("Non-Biodegradable", "Reusable", "Not Recyclable"),
    "Trash": Tuple3("Non-Biodegradable", "Not Reusable", "Not Recyclable"),
    "white-glass": Tuple3("Non-Biodegradable", "Not Reusable", "Recyclable"),
  };

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/mobilenetv2_trash_classifier.tflite');
      print("✅ Model loaded successfully!");
    } catch (e) {
      print("❌ Error loading model: $e");
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile == null) return;

    setState(() {
      _imageFile = File(pickedFile.path);
      _prediction = "Classifying...";
      _classificationDetails = "";
    });

    _classifyImage(_imageFile!);
  }

  Future<void> _classifyImage(File imageFile) async {
    if (_interpreter == null) {
      setState(() => _prediction = "❌ Model not loaded!");
      return;
    }

    Uint8List imageBytes = await imageFile.readAsBytes();
    img.Image? inputImage = img.decodeImage(imageBytes);
    if (inputImage == null) {
      setState(() => _prediction = "Error processing image.");
      return;
    }

    inputImage = img.copyResize(inputImage, width: 224, height: 224);

    var input = List.generate(1, (i) =>
        List.generate(224, (j) =>
            List.generate(224, (k) =>
                List.filled(3, 0.0)
            )
        )
    );

    for (int y = 0; y < 224; y++) {
      for (int x = 0; x < 224; x++) {
        final pixel = inputImage.getPixel(x, y) as img.PixelUint8;
        input[0][y][x][0] = pixel.r / 255.0;
        input[0][y][x][1] = pixel.g / 255.0;
        input[0][y][x][2] = pixel.b / 255.0;
      }
    }

    var output = List.filled(13, 0).reshape([1, 13]);

    _interpreter!.run(input, output);

    if(_interpreter!.getOutputTensor(0).type == TensorType.uint8){
      output = output.cast<int>().map((e) => e/255.0).toList();
    }

    int predictedClass = output[0].indexOf(output[0].cast<double>().reduce((double curr, double next) => curr > next ? curr : next));

    String predictedLabel = classLabels[predictedClass];
    var properties = wasteClassification[predictedLabel];
    if(predictedLabel=="brown-glass" || predictedLabel=="green-glass" || predictedLabel=="white-glass"){
      predictedLabel = "Glass";
    }

    setState(() {
      _prediction = "Predicted: $predictedLabel";
      _classificationDetails = properties != null
          ? "Biodegradability: ${properties.item1}\nReusable: ${properties.item2}\nRecyclable: ${properties.item3}"
          : "No data available.";
    });
  }

  void _sendToChatbot() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatBotPage(initialQuery: "$_prediction\n$_classificationDetails"),
      ),
    );
  }

  @override
  void dispose() {
    _interpreter?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.green[50],
      appBar: AppBar(
        title: Text("Waste Classifier", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    children: [
                      _imageFile != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          _imageFile!,
                          width: screenWidth * 0.8,
                          height: screenWidth * 0.8,
                          fit: BoxFit.cover,
                        ),
                      )
                          : Icon(Icons.image, size: screenWidth * 0.5, color: Colors.grey[400]),
                      SizedBox(height: 15),
                      Text(
                        _prediction,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      if (_classificationDetails.isNotEmpty)
                        Text(
                          _classificationDetails,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 25),
              Wrap(
                spacing: 15,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: Icon(Icons.camera_alt, color: Colors.white),
                    label: Text("Capture Image", style: TextStyle(fontSize: 16)),
                    onPressed: () => _pickImage(ImageSource.camera),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: Icon(Icons.image, color: Colors.white),
                    label: Text("Pick from Gallery", style: TextStyle(fontSize: 16)),
                    onPressed: () => _pickImage(ImageSource.gallery),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blueAccent,
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: Icon(Icons.chat, color: Colors.white),
                label: Text("Ask Chatbot about Disposal", style: TextStyle(fontSize: 16)),
                onPressed: _sendToChatbot,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
