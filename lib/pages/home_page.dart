import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';

import '../const.dart';
import '../utils/firebase_services.dart';
import '../utils/shopify_cart_apis.dart';
import '../widgets/carousel_widget.dart';
import '../widgets/home_widgets/full_sleeve_products.dart';
import '../widgets/home_widgets/half_sleeves_products.dart';
import '../widgets/home_widgets/home_collections.dart';
import 'search_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> products = [];
  List<String> favoriteProducts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    // await Future.delayed(
    //     Duration(seconds: 2)); // Simulating a delay of 2 seconds

    // Perform API call here to fetch data
    final String storefrontApiAccessToken = kStorefrontApiAccessTokken;
    final String url = kShopifyDomain;

    final String query = '''
    {
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
        await Future.delayed(Duration(seconds: 2));
        final data = jsonDecode(response.body);

        final List<dynamic> productEdges = data['data']['products']['edges'];

        setState(() {
          products = productEdges
              .map((edge) => edge['node'])
              .where((node) => node != null)
              .toList();
        });
      } else {
        print('Failed to fetch products: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Failed to fetch products: $error');
    }

    setState(() {
      isLoading = false; // Set isLoading to false after fetching data
    });
  }

  Color getFavoriteIconColor(String productId) {
    if (favoriteProducts.contains(productId)) {
      return Colors.red; // Set the color to red if it's a favorite
    } else {
      return Colors.white; // Use the default color if it's not a favorite
    }
  }

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

  FirebaseServices firebaseServices = FirebaseServices();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: isLoading
            ? Container(
                color: Colors.white12,
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
                ),
              )
            : SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(width: 16),
                          FutureBuilder<String?>(
                            future: FirebaseServices().getUserFirstName(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator(
                                    color: Colors.black);
                              } else if (snapshot.hasError) {
                                return Text('Error: ${snapshot.error}');
                              } else {
                                final firstName = snapshot.data;
                                return firstName == null
                                    ? Expanded(
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              'Hello, Dear!',
                                              style: TextStyle(
                                                fontFamily: 'Karla',
                                                fontSize: 30,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Expanded(
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              'Welcome, $firstName',
                                              style: TextStyle(
                                                fontFamily: 'Karla',
                                                fontSize: 30,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                              }
                            },
                          ),
                          SizedBox(width: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            height: 45,
                            child: IconButton(
                              onPressed: () async {
                                dynamic cartId = await ShopifyAPI.createCart();
                                print(cartId);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MySearchPage(),
                                  ),
                                );
                              },
                              icon: SvgPicture.asset(
                                'assets/svg/search.svg',
                                width: 20,
                                height: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(width: 16),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Text(
                        'NEW ARRIVAL',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Karla',
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: CarouselWigdet(),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Text(
                        'COLLECTIONS',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'Karla',
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: CollectionWidget(),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: FullSleevesProducts(),
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: HalfSleevesProductsViewAll(),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
      ),
    );
  }
}
