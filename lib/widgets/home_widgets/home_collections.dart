import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../const.dart';
import '../../pages/products_from_collection.dart';

class CollectionWidget extends StatefulWidget {
  @override
  _CollectionWidgetState createState() => _CollectionWidgetState();
}

class _CollectionWidgetState extends State<CollectionWidget> {
  final collectionIds = [
    'gid://shopify/Collection/163283107875',
    'gid://shopify/Collection/163229761571',
    'gid://shopify/Collection/267935842339',
    'gid://shopify/Collection/166059048995'
  ];

  List<dynamic> collections = [];

  @override
  void initState() {
    super.initState();
    fetchCollections();
  }

  Future<void> fetchCollections() async {
    try {
      final url = kShopifyDomain;
      final headers = {
        'Content-Type': 'application/json',
        'X-Shopify-Storefront-Access-Token': kStorefrontApiAccessTokken,
      };

      final collectionIdString = collectionIds.map((id) => '"$id"').join(',');

      final body = json.encode({
        'query': '''
        query {
          nodes(ids: [$collectionIdString]) {
            ... on Collection {
              id
              title
              image {
                originalSrc
              }
            }
          }
        }
        ''',
      });

      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final fetchedCollections = data['data']['nodes'];

        setState(() {
          collections = fetchedCollections;
        });
      } else {
        throw Exception('Failed to fetch collections');
      }
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: collections.length,
        itemBuilder: (BuildContext context, int index) {
          final collection = collections[index];
          final id = collection['id'];
          final imageUrl = collection['image'] != null
              ? collection['image']['originalSrc']
              : null;
          // final title = collection['title'];
          final collectionName = collection['title'];

          return Container(
            width: 74,
            height: 100,
            margin: EdgeInsets.all(8),
            child: Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      print(id);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductsByCollection(
                            collectionId: id,
                            collectionName: collectionName,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      height: 60,
                      width: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: imageUrl != null
                              ? Image.network(imageUrl).image
                              : AssetImage('assets/images/no-image-icon.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // imageUrl != null
                    //     ? Image.network(
                    //         imageUrl,
                    //         fit: BoxFit.cover,
                    //       )
                    //     : Image.asset(
                    //         'assets/images/no-image-icon.png',
                    //       ),
                  ),
                ),
                // SizedBox(height: 8),
                // Text(
                //   title,
                //   style: TextStyle(
                //     fontSize: 16,
                //     fontWeight: FontWeight.bold,
                //   ),
                // ),
              ],
            ),
          );
        },
      ),
    );
  }
}
