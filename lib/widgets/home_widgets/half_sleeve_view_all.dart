import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../const.dart';
import '../../pages/product_details.dart';
import '../../utils/fav_product_storage.dart';

class HalfSleevesViewAll extends StatefulWidget {
  HalfSleevesViewAll({
    Key? key,
  }) : super(key: key);

  @override
  _HalfSleevesViewAllState createState() => _HalfSleevesViewAllState();
}

class _HalfSleevesViewAllState extends State<HalfSleevesViewAll> {
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

    final String query = '''
      {
        collection(id: "gid://shopify/Collection/163283107875") {
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

  Future<bool> isProductFavorite(String productId) async {
    List<String> favoriteProductIDs =
        await FavoriteProductStorage.getFavoriteProductIDs();
    return favoriteProductIDs.contains(productId);
  }

  void toggleFavorite(String productId) async {
    bool isFavorite = favoriteProducts.contains(productId);

    if (isFavorite) {
      await FavoriteProductStorage.deleteProductFromFavorites(productId);
      setState(() {
        favoriteProducts.remove(productId); // Update favoriteProducts list
      });
    } else {
      await FavoriteProductStorage.addFavoriteProductID(productId);
      setState(() {
        favoriteProducts.add(productId); // Update favoriteProducts list
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          'HALF SLEEVE',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Karla',
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back_ios,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 8, right: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
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
                                          onTap: () =>
                                              toggleFavorite(productId),
                                          child: FutureBuilder<bool>(
                                            future:
                                                isProductFavorite(productId),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return Icon(
                                                  Icons.favorite_border,
                                                  color: Colors.black,
                                                );
                                              }
                                              final isFavorite =
                                                  snapshot.data ?? false;
                                              return Icon(
                                                isFavorite
                                                    ? Icons.favorite
                                                    : Icons.favorite_border,
                                                color: isFavorite
                                                    ? Colors.black
                                                    : null,
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 8),
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
