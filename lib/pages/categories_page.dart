import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../const.dart';
import 'products_from_collection.dart';

class CategoriesPage extends StatefulWidget {
  // const CategoriesPage({}) : super(key: key);

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  List<dynamic> collections = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCollections();
  }

  Future<void> fetchCollections() async {
    final String storefrontApiAccessToken = kStorefrontApiAccessTokken;
    final String url = kShopifyDomain;
    final String query = '''
      {
        collections(first: 50) {
          edges {
            node {
              id
              title
              image {
                originalSrc
              }
            }
          }
        }
      }
    ''';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'X-Shopify-Storefront-Access-Token': storefrontApiAccessToken,
        },
        body: jsonEncode({'query': query}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> collectionEdges =
            data['data']['collections']['edges'];
        setState(() {
          collections = collectionEdges
              .map((edge) => edge['node'])
              .where((node) => node != null)
              .toList();
          isLoading = false; // Set loading state to false after data is fetched
        });
      } else {
        print('Failed to fetch collections: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Failed to fetch collections: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: 20, left: 16, right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'ALL CATEGORIES',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Karla',
                ),
              ),
              SizedBox(height: 16),
              Expanded(
                child: isLoading // Check loading state
                    ? Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.black),
                        ),
                      )
                    : GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                        ),
                        itemCount: collections.length,
                        itemBuilder: (ctx, index) {
                          final collection = collections[index];
                          final collectionId = collection['id'];
                          final collectionName = collection['title'];
                          final imageSrc = collection['image']?['originalSrc'];
                          final title = collection['title'];

                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: () {
                                print(collectionName);
                                print(collectionId);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ProductsByCollection(
                                      collectionId: collectionId,
                                      collectionName: collectionName,
                                    ),
                                  ),
                                );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 120,
                                    width: 120,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      image: DecorationImage(
                                        image: imageSrc != null
                                            ? Image.network(imageSrc).image
                                            : AssetImage(
                                                'assets/images/no-image-icon.png'),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    title,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontFamily: 'Karla',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Remaining code...
}
