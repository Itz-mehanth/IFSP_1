import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:medicinal_plant/map.dart';
import 'package:medicinal_plant/utils/global_functions.dart';

// ignore: must_be_immutable
class PlantDetailsPage extends StatefulWidget {
  String plantName = '';
  String plantDescription = '';
  String scientificName = '';
  String family = '';
  List<String> imageUrls = [];

  PlantDetailsPage(
      {super.key,
      required this.plantName,
      required this.plantDescription,
      required this.scientificName,
      required this.family});

  @override
  _PlantDetailsPage createState() => _PlantDetailsPage();
}

class _PlantDetailsPage extends State<PlantDetailsPage> {
  @override
  void initState() {
    super.initState();
    fetchRandomImageUrls(widget.plantName);
  }

  Future<void> fetchRandomImageUrls(String plantName) async {
    try {
      print("Fetching plant images...");
      final FirebaseStorage storage = FirebaseStorage.instanceFor(
        bucket: 'gs://medicinal-plant-82aa9.appspot.com',
      );

      final ListResult result =
          await storage.ref().child('images').child(plantName).listAll();
      final List<Reference> allFiles = result.items;

      if (allFiles.isEmpty) {
        throw Exception('No images found for plant: $plantName');
      }

      final List<Future<String>> urlFutures = allFiles.map((file) async {
        return await file.getDownloadURL();
      }).toList();

      final List<String> urls = await Future.wait(urlFutures);

      setState(() {
        widget.imageUrls = urls;
      });
      for (var url in urls) {
        print(url);
      }
    } catch (e) {
      print('Error fetching image URLs: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Column(children: [
          Center(
              child: Container(
            height: 3,
            width: 40,
            decoration: const BoxDecoration(color: Colors.black54),
          )),
          Expanded(
            flex: 1,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.imageUrls.length,
              itemBuilder: (context, index) {
                return Image.network(
                  widget.imageUrls[index],
                  errorBuilder: (context, error, stackTrace) {
                    return const TranslatedText('Error loading image');
                  },
                  fit: BoxFit.fill,
                );
              },
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TranslatedText(
                      widget.plantName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.plantDescription,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const TranslatedText(
                              'SCIENTIFIC NAME:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 80, 255, 85),
                              ),
                            ),
                            Text(
                              widget.scientificName,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const TranslatedText(
                              'FAMILY:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 80, 255, 85),
                              ),
                            ),
                            TranslatedText(
                              widget.family,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(5),
            height: 50,
            decoration: const BoxDecoration(color: Colors.white),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const MapPage([[12.751824,80.23277]]))
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 0, 255, 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map, size: 18, color: Colors.white),
                  SizedBox(width: 5), // Space between icon and text
                  TranslatedText(
                    'View in map',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 30,
          )
        ]),
      ),
    );
  }
}
