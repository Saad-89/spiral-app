import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../const.dart';
import '../../pages/product_details.dart';
import '../../utils/fav_product_storage.dart';
import 'half_sleeve_view_all.dart';

class HalfSleevesProductsViewAll extends StatefulWidget {
  HalfSleevesProductsViewAll({
    Key? key,
  }) : super(key: key);

  @override
  _HalfSleevesProductsViewAllState createState() =>
      _HalfSleevesProductsViewAllState();
}

class _HalfSleevesProductsViewAllState
    extends State<HalfSleevesProductsViewAll> {
  List<dynamic> products = [];

  @override
  void initState() {
    super.initState();
    fetchProducts('gid://shopify/Collection/163283107875');
  }

  Future<void> fetchProducts(String collectionId) async {
    final String storefrontApiAccessToken = kStorefrontApiAccessTokken;
    final String url = kShopifyDomain;

    final String query = '''
    query {
      collection(id: "$collectionId") {
        products(first: 8) {
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
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'HALF SLEEVE',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontFamily: 'Karla',
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HalfSleevesViewAll()));
              },
              child: Text(
                'VIEW ALL',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 15,
                  fontFamily: 'Karla',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          height: 1040,
          child: GridView.builder(
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7, // Adjust the value for card aspect ratio
            ),
            // products.length
            itemCount: products.length,
            itemBuilder: (ctx, index) {
              final product = products[index];
              final productId = product['id'];
              final imageEdges = product['images']?['edges'] ?? [];
              final imageSrc = imageEdges[0]?['node']?['originalSrc'];

              final title = product['title'];
              final price =
                  product['priceRange']?['minVariantPrice']?['amount'] ?? '';

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
                    borderRadius:
                        BorderRadius.circular(8), // Increase border radius
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
                            fontFamily: 'Karla',
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.bold,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              onTap: () => toggleFavorite(productId),
                              child: FutureBuilder<bool>(
                                future: isProductFavorite(productId),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Icon(
                                      Icons.favorite_border,
                                      color: Colors.black,
                                    );
                                  }
                                  final isFavorite = snapshot.data ?? false;
                                  return Icon(
                                    isFavorite
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: isFavorite ? Colors.black : null,
                                  );
                                },
                              ),
                            ),
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
    );
  }
}
