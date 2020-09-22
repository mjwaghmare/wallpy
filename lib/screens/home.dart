import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:wallpy/constants.dart';
import 'package:wallpy/data/data.dart';
import 'package:wallpy/models/categorie_model.dart';
import 'package:wallpy/models/photos_model.dart';
import 'package:wallpy/screens/search_view.dart';
import 'package:wallpy/widgets/widgets.dart';

import 'categorie_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<CategorieModel> categories = new List();

  int noOfImageToLoad = 30;
  List<WallpaperModel> photos = new List();

  getTrendingWallpaper() async {
    await http.get(
        "https://api.pexels.com/v1/curated?per_page=$noOfImageToLoad&page=1",
        headers: {"Authorization": Constants.API_KEY}).then((value) {
      Map<String, dynamic> jsonData = jsonDecode(value.body);
      jsonData["photos"].forEach((element) {
        // print(element);
        WallpaperModel wallpaperModel = new WallpaperModel();
        wallpaperModel = WallpaperModel.fromMap(element);
        photos.add(wallpaperModel);
        print(wallpaperModel.toString() + "  " + wallpaperModel.src.portrait);
      });

      setState(() {});
    });
  }

  TextEditingController searchController = new TextEditingController();

  ScrollController _scrollController = new ScrollController();

  @override
  void initState() {
    getTrendingWallpaper();
    categories = getCategories();
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        noOfImageToLoad = noOfImageToLoad + 30;
        getTrendingWallpaper();
      }
    });
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: brandName(),
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Color(0xFFf5f8fd),
                borderRadius: BorderRadius.circular(30),
              ),
              margin: EdgeInsets.symmetric(horizontal: 24.0),
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: "search wallpapers..",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  InkWell(
                      onTap: () {
                        if (searchController.text != "") {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SearchView(
                                        search: searchController.text,
                                      )));
                        }
                      },
                      child: Icon(Icons.search)),
                ],
              ),
            ),
            const SizedBox(height: 10.0),
            developerName(),
            const SizedBox(height: 16.0),
            Container(
              height: 80,
              child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 24.0),
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    return WallpaperCategoryTile(
                      categorie: categories[index].categorieName,
                      imgUrl: categories[index].imgUrl,
                    );
                  }),
            ),
            const SizedBox(height: 16.0),
            wallPaper(photos, context),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Photos provided By ",
                  style: TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                      fontFamily: 'Overpass'),
                ),
                GestureDetector(
                  onTap: () {
                    _launchURL("https://www.pexels.com/");
                  },
                  child: Container(
                      child: Text(
                    "Pexels",
                    style: TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                        fontFamily: 'Overpass'),
                  )),
                )
              ],
            ),
            SizedBox(
              height: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget developerName() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          "Made with ",
          style: TextStyle(color: Colors.black87, fontFamily: 'Overpass'),
        ),
        Text(
          "❤️ ",
          style: TextStyle(color: Colors.red, fontFamily: 'Overpass'),
        ),
        Text(
          "by ",
          style: TextStyle(color: Colors.black87, fontFamily: 'Overpass'),
        ),
        GestureDetector(
          onTap: () {},
          /*_launchURL(
              "https://www.linkedin.com/in/manoj-waghmare-90a883124"),*/
          child: Text(
            "Manoj Waghmare",
            style: TextStyle(color: Colors.deepOrange, fontFamily: 'Overpass'),
          ),
        )
      ],
    );
  }
}

class WallpaperCategoryTile extends StatelessWidget {
  final String imgUrl, categorie;

  WallpaperCategoryTile({@required this.imgUrl, @required this.categorie});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => CategorieScreen(
                      categorie: categorie,
                    )));
      },
      child: Container(
        margin: EdgeInsets.only(right: 4),
        child: Stack(
          children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imgUrl,
                  height: 50,
                  width: 100,
                  fit: BoxFit.cover,
                )),
            Container(
              height: 50,
              width: 100,
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                categorie,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 15),
              ),
            )
          ],
        ),
      ),
    );
  }
}
