

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../const.dart';
import '../utils/fav_product_storage.dart';
import 'product_details.dart';

class ProductsByCollection extends StatefulWidget {
  String collectionId;
  String collectionName;

  ProductsByCollection(
      {Key? key, required this.collectionId, required this.collectionName})
      : super(key: key);

  @override
  _ProductsByCollectionState createState() => _ProductsByCollectionState();
}

class _ProductsByCollectionState extends State<ProductsByCollection> {
  List<dynamic> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final String storefrontApiAccessToken = kStorefrontApiAccessTokken;
    final String url = kShopifyDomain;
    final String collectionId = widget.collectionId;

    final String query = '''
      {
        collection(id: "$collectionId") {
          products(first: 50) {
            edges {
              node {
                id
                title
                priceRange {
                  minVariantPrice {
                    amount
                  }
                }
                images(first: 1) {
                  edges {
                    node {
                      originalSrc
                    }
                  }
                }
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
        final List<dynamic> productEdges =
            data['data']['collection']['products']['edges'];
        setState(() {
          products = productEdges
              .map((edge) => edge['node'])
              .where((node) => node != null)
              .toList();
          isLoading = false; // Set loading state to false
        });
      } else {
        print('Failed to fetch products: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Failed to fetch products: $error');
    }
  }

  List<String> favoriteProducts = [];

  bool isProductFavorite(String productId) {
    return favoriteProducts.contains(productId);
  }

  void toggleFavorite(String productId) {
    setState(() {
      if (isProductFavorite(productId)) {
        favoriteProducts.remove(productId);
      } else {
        favoriteProducts.add(productId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.arrow_back_ios_new_outlined)),
                  GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.category_outlined,
                        size: 28,
                      )),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ScrollableWidgets(
                      icon: Icons.local_shipping,
                      text_1: 'Free shipping on order above 1500',
                      text_2: 'Delivery within 4 days',
                    ),
                    SizedBox(
                      width: 12,
                    ),
                    ScrollableWidgets(
                      icon: Icons.currency_exchange,
                      text_1: '30 days Money Back Guarantee',
                      text_2: 'We provide 30 days Money back Guarantee',
                    ),
                    SizedBox(
                      width: 12,
                    ),
                    ScrollableWidgets(
                      icon: Icons.turn_slight_right,
                      text_1: 'Hassle-free exchange',
                      text_2: 'Exchange at your door step',
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                '${widget.collectionName}'.toUpperCase(),
                style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Karla',
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10,
              ),
              Expanded(
                child: isLoading // Show circular progress indicator if loading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Colors.black,
                        ),
                      )
                    : GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio:
                              0.7, // Adjust the value for card aspect ratio
                        ),
                        itemCount: products.length,
                        itemBuilder: (ctx, index) {
                          final product = products[index];
                          final productId = product['id'];
                          final imageEdges = product['images']?['edges'] ?? [];
                          final imageSrc =
                              imageEdges[0]?['node']?['originalSrc'];

                          final title = product['title'];
                          final price = product['priceRange']
                                  ?['minVariantPrice']['amount'] ??
                              '';

                          return GestureDetector(
                            onTap: () {
                              print(productId);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetails(
                                    productId: productId,
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    8), // Increase border radius
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Center(
                                      child: imageSrc != null
                                          ? Image.network(
                                              imageSrc,
                                              fit: BoxFit.cover,
                                            )
                                          : Container(),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      title,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Karla',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'RS $price',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontFamily: 'Karla',
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () async {
                                            toggleFavorite(
                                                productId); // Toggle favorite status
                                            await FavoriteProductStorage
                                                .addFavoriteProductID(
                                                    productId);
                                          },
                                          child: Icon(
                                            isProductFavorite(productId)
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 8,
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
}

class ScrollableWidgets extends StatelessWidget {
  IconData icon;
  String text_1;
  String text_2;
  ScrollableWidgets(
      {super.key,
      required this.icon,
      required this.text_1,
      required this.text_2});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Icon(
                icon,
                size: 32,
                color: Colors.white,
              ),
              Text(
                text_1,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Karla',
                  color: Colors.white,
                ),
              ),
              Text(
                text_2,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Karla',
                  color: Colors.white,
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
