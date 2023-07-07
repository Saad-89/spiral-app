

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spiral_app/pages/product_details.dart';

import '../const.dart';
import '../utils/fav_product_storage.dart';

class Product {
  final String id;
  final String title;
  final String price;
  final String imageUrl;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.imageUrl,
  });
}

const String storefrontAPIBaseUrl = kShopifyDomain;
const String storefrontAPIAccessToken = kStorefrontApiAccessTokken;

Future<List<Product>> getProductDetails(List<String> productIds) async {
  final query = '''
    query GetProductDetails(\$ids: [ID!]!) {
      nodes(ids: \$ids) {
        ... on Product {
          id
          title
          priceRange {
            minVariantPrice {
              amount
              currencyCode
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
    ''';

  final variables = {
    'ids': productIds,
  };

  final body = {
    'query': query,
    'variables': variables,
  };

  final response = await http.post(
    Uri.parse(storefrontAPIBaseUrl),
    headers: {
      'Content-Type': 'application/json',
      'X-Shopify-Storefront-Access-Token': storefrontAPIAccessToken,
    },
    body: jsonEncode(body),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final productsData = data['data']['nodes'];

    List<Product> products = [];

    for (var productData in productsData) {
      final id = productData['id'];
      final title = productData['title'];
      final price = productData['priceRange']['minVariantPrice']['amount'];
      final imageUrl = productData['images']['edges'][0]['node']['originalSrc'];

      final product = Product(
        id: id,
        title: title,
        price: price,
        imageUrl: imageUrl,
      );
      products.add(product);
    }

    return products;
  } else {
    throw Exception('Failed to fetch product details');
  }
}

class FavPage extends StatefulWidget {
  @override
  State<FavPage> createState() => _FavPageState();
}

class _FavPageState extends State<FavPage> {
  List<String> favoriteProductIds = [];
  List<Product> favoriteProducts = [];
  bool isLoading = true;

  Future<void> fetchFavItems() async {
    List<String> productIds =
        await FavoriteProductStorage.getFavoriteProductIDs();
    List<Product> products = await getProductDetails(productIds);

    setState(() {
      favoriteProductIds = productIds;
      favoriteProducts = products;
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchFavItems();
  }

  bool isProductFavorite(String productId) {
    return favoriteProductIds.contains(productId);
  }

  void toggleFavorite(String productId) async {
    setState(() {
      if (isProductFavorite(productId)) {
        favoriteProductIds.remove(productId);
        favoriteProducts.removeWhere((product) => product.id == productId);
      } else {
        favoriteProductIds.add(productId);
      }
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favoriteProductIDs', favoriteProductIds);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: 20, left: 8, right: 8),
          child: Container(
            child: Column(
              children: [
                Text(
                  'My Favourites',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      fontFamily: 'Karla'),
                ),
                SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: isLoading
                      ? Center(
                          child: CircularProgressIndicator(
                          color: Colors.black,
                        ))
                      : favoriteProducts.isEmpty
                          ? Center(
                              child: Text(
                                'No favorite products',
                                style: TextStyle(
                                  fontFamily: 'Karla',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: favoriteProducts.length,
                              itemBuilder: (context, index) {
                                final product = favoriteProducts[index];

                                return Container(
                                  color: Colors.white,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10),
                                    child: Column(
                                      children: [
                                        Container(
                                          width:
                                              MediaQuery.of(context).size.width,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.black, width: 2),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: Colors.white,
                                          ),
                                          child: Column(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          ProductDetails(
                                                              productId:
                                                                  product.id),
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  height: 200,
                                                  child: Image.network(
                                                      product.imageUrl),
                                                ),
                                              ),
                                              SizedBox(height: 10),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      'Price: \$${product.price}',
                                                      style: TextStyle(
                                                        fontFamily: 'Karla',
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        toggleFavorite(
                                                            product.id);
                                                      },
                                                      child: Icon(
                                                        isProductFavorite(
                                                                product.id)
                                                            ? Icons.favorite
                                                            : Icons
                                                                .favorite_border,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: 15),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 15),
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
      ),
    );
  }
}
